import 'package:flutter/material.dart';
import '../../services/vpn_service.dart';
import '../../models/server_model.dart';
import '../../models/vpn_status.dart';

class HomeController extends ChangeNotifier {
  VpnService _vpnService;

  HomeController(this._vpnService);

  // ── Proxy getters ────────────────────────────────────────
  VpnStatus get status            => _vpnService.status;
  ServerModel? get selectedServer => _vpnService.selectedServer;
  List<ServerModel> get servers   => _vpnService.servers;
  bool get isConnected            => status.isConnected;
  bool get isConnecting           => status.isConnecting;
  bool get isLoadingServers       => _vpnService.isLoadingServers;
  String? get serverError         => _vpnService.serverError;

  /// Called by ProxyProvider when VpnService instance changes
  void updateVpnService(VpnService vpn) {
    _vpnService = vpn;
    notifyListeners();
  }

  // ── Actions ──────────────────────────────────────────────
  Future<void> toggleConnection()  => _vpnService.toggle();
  Future<void> fetchServers()      => _vpnService.fetchServers();
  void selectServer(ServerModel s) => _vpnService.selectServer(s);

  /// Best free server (first in free list from API)
  ServerModel? get bestServer {
    final free = _vpnService.freeServers;
    return free.isNotEmpty ? free.first : null;
  }

  /// Auto-select best server if none selected yet
  void ensureServerSelected() {
    if (_vpnService.selectedServer == null) {
      final best = bestServer;
      if (best != null) selectServer(best);
    }
  }

  /// WireGuard config for selected server
  String? get wireGuardConfig => _vpnService.getWireGuardConfig();
}