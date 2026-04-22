// All VIP providers are now in src/services/vip_service.dart
// Re-export them here for backward compatibility.
export '../services/vip_service.dart'
    show
        vipServiceProvider,
        customerInfoProvider,
        isVipProvider,
        offeringsProvider,
        entitlementId;
