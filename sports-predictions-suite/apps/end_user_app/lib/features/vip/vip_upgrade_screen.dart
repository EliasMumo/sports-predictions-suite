import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../src/services/vip_service.dart';

class VIPUpgradeScreen extends ConsumerStatefulWidget {
  /// RevenueCat offering ID specific to this VIP category.
  /// If null, falls back to the default/current offering.
  final String? offeringId;

  /// Display title shown in the header (e.g. "Correct Score VIP").
  final String? categoryTitle;

  const VIPUpgradeScreen({super.key, this.offeringId, this.categoryTitle});

  @override
  ConsumerState<VIPUpgradeScreen> createState() => _VIPUpgradeScreenState();
}

class _VIPUpgradeScreenState extends ConsumerState<VIPUpgradeScreen> {
  bool _isProcessing = false;
  String? _errorMessage;
  bool _isMonthly = true; // default to monthly (best value)

  String _friendlyOfferingsError(Object error) {
    final raw = error.toString();
    if (raw.contains('REVENUECAT_PUBLIC_API_KEY')) {
      return 'Subscriptions are temporarily unavailable because billing is not configured in this build.';
    }
    return 'Failed to load subscription plans. Please try again.';
  }

  String _friendlyPurchaseError(Object error) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('item you were attempting to purchase could not be found') ||
        raw.contains('item unavailable')) {
      return 'This build is not recognized by Google Play Billing. Install the app from the Play Internal Testing link, then try again.';
    }
    return error.toString();
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final success = await ref.read(vipServiceProvider).purchase(package);
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('VIP subscription activated! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _isProcessing = false;
            _errorMessage = 'Purchase was cancelled.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = _friendlyPurchaseError(e);
        });
      }
    }
  }

  Future<void> _restore() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });
    try {
      final restored = await ref.read(vipServiceProvider).restorePurchases();
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restored
                ? 'VIP restored successfully!'
                : 'No previous VIP subscription found.'),
            backgroundColor: restored ? Colors.green : Colors.orange,
          ),
        );
        if (restored) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle = widget.categoryTitle ?? 'VIP Access';
    final offeringsAsync = ref.watch(offeringsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Unlock ${widget.categoryTitle ?? "VIP"}'),
        elevation: 0,
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          final offering = widget.offeringId != null
              ? (offerings.all[widget.offeringId] ?? offerings.current)
              : offerings.current;

          if (offering == null || offering.availablePackages.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No subscription plans available right now.\nPlease check back later.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // Split packages into weekly and monthly
          final weeklyPkg = offering.availablePackages
              .cast<Package?>()
              .firstWhere(
                (p) =>
                    p!.packageType == PackageType.weekly ||
                    p.storeProduct.identifier.contains('weekly'),
                orElse: () => null,
              );
          final monthlyPkg = offering.availablePackages
              .cast<Package?>()
              .firstWhere(
                (p) =>
                    p!.packageType == PackageType.monthly ||
                    p.storeProduct.identifier.contains('monthly'),
                orElse: () => null,
              );

          return _buildContent(weeklyPkg, monthlyPkg, displayTitle);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _friendlyOfferingsError(error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(offeringsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
      Package? weeklyPkg, Package? monthlyPkg, String categoryTitle) {
    final hasBothPlans = weeklyPkg != null && monthlyPkg != null;
    final selectedPkg = _isMonthly
        ? (monthlyPkg ?? weeklyPkg)
        : (weeklyPkg ?? monthlyPkg);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade800, Colors.amber.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium,
                    size: 56, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  categoryTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Unlock exclusive VIP predictions',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Benefits ─────────────────────────────────────────
          _benefit(Icons.insights, 'Expert Analysis',
              'Hand-picked by our prediction team'),
          _benefit(Icons.bolt, 'Early Access',
              'Get tips before anyone else'),
          _benefit(Icons.notifications_active, 'Priority Alerts',
              'Instant push notifications'),
          _benefit(Icons.block, 'Ad-Free', 'Clean, distraction-free experience'),

          const SizedBox(height: 28),

          // ── Weekly / Monthly toggle ───────────────────────────
          if (hasBothPlans) ...[
            const Text(
              'Choose your billing cycle',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(
                  value: false,
                  label: Column(
                    children: [
                      const Text('Weekly',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(weeklyPkg.storeProduct.priceString,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  icon: const Icon(Icons.calendar_view_week),
                ),
                ButtonSegment(
                  value: true,
                  label: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Monthly',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('SAVE',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 9)),
                          ),
                        ],
                      ),
                        Text(monthlyPkg.storeProduct.priceString,
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
              selected: {_isMonthly},
              onSelectionChanged: (value) =>
                  setState(() => _isMonthly = value.first),
            ),
            const SizedBox(height: 20),
          ],

          // ── Selected plan card + subscribe button ─────────────
          if (selectedPkg != null) _buildPlanCard(selectedPkg),

          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 12),
          TextButton(
            onPressed: _isProcessing ? null : _restore,
            child: const Text('Restore Purchases'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'Subscriptions renew automatically. Cancel anytime in your Play Store account.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _benefit(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.amber.shade600, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Package package) {
    final product = package.storeProduct;
    final isMonthly = _isMonthly &&
        (package.packageType == PackageType.monthly ||
            product.identifier.contains('monthly'));

    return Card(
      color: Colors.amber.shade900.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade700, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isMonthly ? 'Monthly Plan' : 'Weekly Plan',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (isMonthly)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Best Value',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade400),
                ),
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    isMonthly ? '/ month' : '/ week',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : () => _purchasePackage(package),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Subscribe Now'),
            ),
          ],
        ),
      ),
    );
  }
}
