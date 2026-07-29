import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'vpn_service.dart';

/// Manages Google Play Billing (Android) and StoreKit (iOS) subscriptions.
///
/// Product IDs must be created in Google Play Console under
/// Monetize → Subscriptions with these exact IDs:
///   nextboltvpn_weekly   — billed weekly
///   nextboltvpn_monthly  — billed monthly
///   nextboltvpn_yearly   — billed yearly
///
/// Each product needs at least one "base plan" configured in Play Console
/// before it will appear in queryProductDetails responses.
class IapService extends ChangeNotifier {
  static const String weeklyId  = 'nextboltvpn_weekly';
  static const String monthlyId = 'nextboltvpn_monthly';
  static const String yearlyId  = 'nextboltvpn_yearly';

  static const Set<String> _ids = {weeklyId, monthlyId, yearlyId};

  // Fallback prices shown when the store hasn't returned real prices yet.
  static const Map<String, String> fallbackPrices = {
    weeklyId:  '\$2.99',
    monthlyId: '\$7.99',
    yearlyId:  '\$39.99',
  };

  VpnService _vpnService;

  bool _storeAvailable = false;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  bool get storeAvailable => _storeAvailable;
  bool get loading => _loading;
  bool get purchasing => _purchasing;
  String? get error => _error;
  List<ProductDetails> get products => _products;

  IapService(this._vpnService) {
    _init();
  }

  void updateVpnService(VpnService vpn) {
    _vpnService = vpn;
  }

  Future<void> _init() async {
    _storeAvailable = await InAppPurchase.instance.isAvailable();
    if (!_storeAvailable) {
      _loading = false;
      notifyListeners();
      return;
    }

    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        _error = e.toString();
        _purchasing = false;
        notifyListeners();
      },
    );

    await _loadProducts();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    final response = await InAppPurchase.instance.queryProductDetails(_ids);
    // Sort by the order defined in _ids so UI order is predictable.
    final order = [weeklyId, monthlyId, yearlyId];
    _products = response.productDetails
      ..sort((a, b) => order.indexOf(a.id).compareTo(order.indexOf(b.id)));
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint(
        'IapService: products not found in store — '
        'create them in Play Console: ${response.notFoundIDs}',
      );
    }
  }

  /// Returns the store-fetched product for [id], or null if not yet loaded.
  ProductDetails? productFor(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Displays the native purchase sheet for [product].
  Future<void> buy(ProductDetails product) async {
    _error = null;
    _purchasing = true;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: product);
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      _error = e.toString();
      _purchasing = false;
      notifyListeners();
    }
  }

  /// Restores previous purchases (required by App Store / Play Store policies).
  Future<void> restore() async {
    _error = null;
    notifyListeners();
    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _vpnService.setPremiumUser(true);
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        case PurchaseStatus.error:
          _error = purchase.error?.message ?? 'Purchase failed. Please try again.';
        case PurchaseStatus.canceled:
          break; // user dismissed the sheet — no action needed
        case PurchaseStatus.pending:
          break; // payment pending (e.g. carrier billing) — wait for update
      }
    }
    _purchasing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
