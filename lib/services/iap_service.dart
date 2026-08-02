import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'vpn_service.dart';

/// Manages subscriptions across Google Play, Amazon Appstore and StoreKit.
///
/// Uses flutter_inapp_purchase (OpenIAP) rather than the official
/// `in_app_purchase` plugin because that plugin's Android implementation is
/// Google Play Billing only. Fire OS devices have no Play Services, so Play
/// Billing cannot initialize there at all — which is why Amazon review saw a
/// purchase error. The Amazon-flavoured native backend is selected at build
/// time by the `fireOsEnabled` Gradle property; see README/build docs.
///
/// Product IDs must exist with these exact SKUs in BOTH consoles:
///   nextboltvpn_weekly   — billed weekly
///   nextboltvpn_monthly  — billed monthly
///   nextboltvpn_yearly   — billed yearly
///
/// Google Play: Monetize → Subscriptions (each needs a base plan).
/// Amazon: your app → In-App Items → Subscription, with the same SKUs.
class IapService extends ChangeNotifier {
  static const String weeklyId  = 'nextboltvpn_weekly';
  static const String monthlyId = 'nextboltvpn_monthly';
  static const String yearlyId  = 'nextboltvpn_yearly';

  static const List<String> _ids = [weeklyId, monthlyId, yearlyId];

  // Fallback prices shown when the store hasn't returned real prices yet.
  static const Map<String, String> fallbackPrices = {
    weeklyId:  '\$2.99',
    monthlyId: '\$7.99',
    yearlyId:  '\$39.99',
  };

  VpnService _vpnService;

  final FlutterInappPurchase _iap = FlutterInappPurchase.instance;

  bool _storeAvailable = false;
  bool _loading = true;
  bool _purchasing = false;
  String? _error;
  List<ProductSubscription> _products = [];
  StreamSubscription<Purchase>? _purchaseSub;
  StreamSubscription<PurchaseError>? _errorSub;

  bool get storeAvailable => _storeAvailable;
  bool get loading => _loading;
  bool get purchasing => _purchasing;
  String? get error => _error;
  List<ProductSubscription> get products => _products;

  IapService(this._vpnService) {
    _init();
  }

  void updateVpnService(VpnService vpn) {
    _vpnService = vpn;
  }

  Future<void> _init() async {
    // Listeners must be attached before the first purchase can arrive — the
    // store can replay an unfinished transaction as soon as we connect.
    _purchaseSub = _iap.purchaseUpdatedListener.listen(
      _onPurchase,
      onError: (Object e) => _fail(e.toString()),
    );
    _errorSub = _iap.purchaseErrorListener.listen(
      (e) => _fail(e.message),
    );

    try {
      _storeAvailable = await _iap.initConnection();
    } catch (e) {
      _storeAvailable = false;
      debugPrint('IapService: initConnection failed — $e');
    }

    if (!_storeAvailable) {
      _loading = false;
      notifyListeners();
      return;
    }

    await _loadProducts();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadProducts() async {
    try {
      final fetched = await _iap.fetchProducts<ProductSubscription>(
        skus: _ids,
        type: ProductQueryType.Subs,
      );
      // Sort into the order the UI presents them, ignoring store ordering.
      _products = fetched
        ..sort((a, b) => _ids.indexOf(a.id).compareTo(_ids.indexOf(b.id)));

      final missing = _ids.where((id) => !fetched.any((p) => p.id == id));
      if (missing.isNotEmpty) {
        debugPrint(
          'IapService: products missing from store — create them with these '
          'exact SKUs in Play Console AND the Amazon Developer Console: '
          '${missing.join(', ')}',
        );
      }
    } catch (e) {
      debugPrint('IapService: fetchProducts failed — $e');
    }
  }

  /// Returns the store-fetched product for [id], or null if not yet loaded.
  ProductSubscription? productFor(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Displays the native purchase sheet for [product].
  Future<void> buy(ProductSubscription product) async {
    _error = null;
    _purchasing = true;
    notifyListeners();
    try {
      await _iap.requestPurchaseWithBuilder(
        build: (builder) => builder
          ..type = ProductQueryType.Subs
          ..android.skus = [product.id]
          ..ios.sku = product.id,
      );
      // Completion arrives asynchronously on purchaseUpdatedListener /
      // purchaseErrorListener — don't clear _purchasing here.
    } catch (e) {
      _fail(e.toString());
    }
  }

  /// Restores previous purchases (required by App Store / Play / Amazon).
  Future<void> restore() async {
    _error = null;
    notifyListeners();
    try {
      final purchases = await _iap.getAvailablePurchases();
      final active = purchases.where((p) => _ids.contains(p.productId));
      if (active.isNotEmpty) {
        await _vpnService.setPremiumUser(true);
      }
      notifyListeners();
    } catch (e) {
      _fail(e.toString());
    }
  }

  Future<void> _onPurchase(Purchase purchase) async {
    if (!_ids.contains(purchase.productId)) return;

    await _vpnService.setPremiumUser(true);
    try {
      // Subscriptions are never consumable; skipping this leaves the purchase
      // unacknowledged and Play/Amazon will auto-refund it within 3 days.
      await _iap.finishTransaction(purchase: purchase, isConsumable: false);
    } catch (e) {
      debugPrint('IapService: finishTransaction failed — $e');
    }

    _purchasing = false;
    notifyListeners();
  }

  void _fail(String message) {
    _error = message;
    _purchasing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    _errorSub?.cancel();
    unawaited(_iap.endConnection());
    super.dispose();
  }
}
