import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

// ──────────────────────────────────────────────────────────
// RevenueCat configuration
// ──────────────────────────────────────────────────────────

/// RevenueCat public SDK key (Google Play).
///
/// Pass this at build time:
/// flutter build appbundle --dart-define=REVENUECAT_PUBLIC_API_KEY=goog_...
const String revenueCatPublicApiKey = String.fromEnvironment(
  'REVENUECAT_PUBLIC_API_KEY',
  defaultValue: '',
);

/// Entitlement identifier configured in RevenueCat dashboard.
///
/// Override at build time if needed:
/// --dart-define=REVENUECAT_ENTITLEMENT_ID=VIP
const String entitlementId = String.fromEnvironment(
  'REVENUECAT_ENTITLEMENT_ID',
  defaultValue: 'VIP',
);

bool _hasVipEntitlement(CustomerInfo info) {
  final active = info.entitlements.active;
  // Keep fallback for legacy lowercase entitlement IDs in older dashboards.
  return active.containsKey(entitlementId) ||
      active.containsKey('VIP') ||
      active.containsKey('vip');
}

/// Product IDs (must match Play Console + RevenueCat products).
const String tenPlusWeeklyId = '10_plus_weekly';
const String tenPlusMonthlyId = '10_plus_monthly';
const String htFtFixedWeeklyId = 'ht_ft_fixed_weekly';
const String htFtFixedMonthlyId = 'ht_ft_fixed_monthly';
const String overUnderWeeklyId = 'over_under_weekly';
const String overUnderMonthlyId = 'over_under_monthly';
const String vipCombinedWeeklyId = 'vip_combined_weekly';
const String vipCombinedMonthlyId = 'vip_combined_monthly';

/// Maps each category offeringId to its weekly + monthly product IDs.
const Map<String, List<String>> categoryProductIds = {
  '10_plus': [tenPlusWeeklyId, tenPlusMonthlyId],
  'ht_ft_fixed': [htFtFixedWeeklyId, htFtFixedMonthlyId],
  'over_under': [overUnderWeeklyId, overUnderMonthlyId],
  'vip_combined': [vipCombinedWeeklyId, vipCombinedMonthlyId],
};

// ──────────────────────────────────────────────────────────
// VIP Service (RevenueCat)
// ──────────────────────────────────────────────────────────

class VIPService {
  static bool _initialized = false;
  static bool _available = false;

  bool get isConfigured => _available;

  /// Call once at app startup (before any purchase logic).
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (revenueCatPublicApiKey.isEmpty) {
      debugPrint(
        '[VIPService] Missing REVENUECAT_PUBLIC_API_KEY. App will run with purchases disabled.',
      );
      _available = false;
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      final config = PurchasesConfiguration(revenueCatPublicApiKey);
      await Purchases.configure(config);
      _available = true;
      debugPrint('[VIPService] RevenueCat configured');
    } on PlatformException catch (e) {
      _available = false;
      debugPrint('[VIPService] RevenueCat configure failed: $e');
    } catch (e) {
      _available = false;
      debugPrint('[VIPService] RevenueCat unexpected init error: $e');
    }
  }

  /// Identify the user so RevenueCat links purchases to them.
  Future<void> login(String userId) async {
    if (!_available) return;
    await Purchases.logIn(userId);
    debugPrint('[VIPService] Logged in as $userId');
  }

  /// Log out (anonymous user after this).
  Future<void> logout() async {
    if (!_available) return;
    await Purchases.logOut();
  }

  /// Check whether the user currently has the VIP entitlement.
  Future<bool> isVip() async {
    if (!_available) return false;
    try {
      final info = await Purchases.getCustomerInfo();
      return _hasVipEntitlement(info);
    } catch (e) {
      debugPrint('[VIPService] Error checking VIP: $e');
      return false;
    }
  }

  /// Return the offerings configured in RevenueCat.
  Future<Offerings> getOfferings() async {
    if (!_initialized) {
      await initialize();
    }
    if (!_available) {
      throw StateError(
        'RevenueCat is not configured. Set REVENUECAT_PUBLIC_API_KEY via --dart-define.',
      );
    }
    return await Purchases.getOfferings();
  }

  /// Purchase a specific package.
  Future<bool> purchase(Package package) async {
    if (!_available) return false;
    try {
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);
      return result.customerInfo.activeSubscriptions
          .contains(package.storeProduct.identifier);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      debugPrint(
        '[VIPService] Purchase failed for ${package.storeProduct.identifier} '
        '(code: $errorCode, message: ${e.message})',
      );
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        debugPrint('[VIPService] Purchase cancelled');
        return false;
      }
      rethrow;
    }
  }

  /// Restore purchases (e.g. after reinstall).
  Future<bool> restorePurchases() async {
    if (!_available) return false;
    try {
      final info = await Purchases.restorePurchases();
      final allVipProducts =
          categoryProductIds.values.expand((ids) => ids).toSet();
      return allVipProducts
          .any((id) => info.activeSubscriptions.contains(id));
    } catch (e) {
      debugPrint('[VIPService] Restore error: $e');
      return false;
    }
  }

  /// Stream that emits whenever customer info changes (purchase, expiry, etc.)
  Stream<CustomerInfo> get customerInfoStream {
    if (!_available) {
      return const Stream<CustomerInfo>.empty();
    }
    final controller = StreamController<CustomerInfo>.broadcast();
    void listener(CustomerInfo info) => controller.add(info);
    Purchases.addCustomerInfoUpdateListener(listener);
    controller.onCancel = () {
      Purchases.removeCustomerInfoUpdateListener(listener);
    };
    return controller.stream;
  }
}

// ──────────────────────────────────────────────────────────
// Riverpod providers
// ──────────────────────────────────────────────────────────

/// Singleton VIP service.
final VIPService _vipServiceSingleton = VIPService();

final vipServiceProvider = Provider<VIPService>((ref) {
  return _vipServiceSingleton;
});

/// Stream of customer info changes.
final customerInfoProvider = StreamProvider<CustomerInfo>((ref) {
  return ref.watch(vipServiceProvider).customerInfoStream;
});

/// Whether the current user has ANY active VIP subscription.
final isVipProvider = Provider<bool>((ref) {
  final infoAsync = ref.watch(customerInfoProvider);
  return infoAsync.when(
    data: (info) => _hasVipEntitlement(info),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Available offerings from RevenueCat.
/// Whether the user has an active subscription for a specific category.
final isVipForCategoryProvider =
    Provider.family<bool, String>((ref, offeringId) {
  final infoAsync = ref.watch(customerInfoProvider);
  return infoAsync.when(
    data: (info) {
      final productIds = categoryProductIds[offeringId];
      if (productIds == null) return false;
      return productIds
          .any((id) => info.activeSubscriptions.contains(id));
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

final offeringsProvider = FutureProvider<Offerings>((ref) async {
  return ref.watch(vipServiceProvider).getOfferings();
});
