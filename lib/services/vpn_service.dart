import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wireguard_flutter_plus/wireguard_flutter_plus.dart';
import '../models/vpn_status.dart';
import '../models/server_model.dart';
import 'ip_lookup_service.dart';

class VpnService extends ChangeNotifier {
  VpnStatus _status = VpnStatus.initial;
  ServerModel? _selectedServer;
  List<ServerModel> _servers = [];
  bool _isLoadingServers = false;
  String? _serverError;
  Timer? _sessionTimer;
  Timer? _connectTimeoutTimer;

  final _wireguard = WireGuardFlutter.instance;
  bool _wireguardInitialized = false;
  StreamSubscription<VpnStage>? _stageSub;
  StreamSubscription<Map<String, dynamic>>? _trafficSub;

  // TODO(ios): providerBundleIdentifier must match a Network Extension
  // target created in Xcode (File > New > Target > Network Extension),
  // sharing an App Group with the main app. See wireguard_flutter_plus'
  // ios_setup_readme.md. Not usable on Android.
  static const String _iosProviderBundleIdentifier =
      'com.example.nextboltvpn.WGExtension';

  VpnService() {
    _stageSub = _wireguard.vpnStageSnapshot.listen(_onStageChanged);
    _trafficSub = _wireguard.trafficSnapshot.listen(_onTraffic);
    unawaited(_refreshOriginalIp());
  }

  // ── API ───────────────────────────────────────────────────
  static const String _apiUrl =
      'https://nextvpn.nextsalution.com/vpn/wireguard_api.php';

  // ── Public getters ────────────────────────────────────────
  VpnStatus get status            => _status;
  ServerModel? get selectedServer => _selectedServer;
  List<ServerModel> get servers   => _servers;
  bool get isLoadingServers       => _isLoadingServers;
  String? get serverError         => _serverError;

  List<ServerModel> get freeServers =>
      _servers.where((s) => !s.isPremium).toList();

  List<ServerModel> get premiumServers =>
      _servers.where((s) => s.isPremium).toList();

  // ── Fetch Servers from API ────────────────────────────────
  Future<void> fetchServers() async {
    _isLoadingServers = true;
    _serverError = null;
    notifyListeners();

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);

        if (json['status'] == 'success') {
          final List data = json['data'] as List;
          _servers = data
              .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
              .toList();

          if (_selectedServer == null && freeServers.isNotEmpty) {
            _selectedServer = freeServers.first;
          }
        } else {
          _serverError = 'API returned an error. Please try again.';
        }
      } else {
        _serverError = 'Server error: ${response.statusCode}';
      }
    } on TimeoutException {
      _serverError = 'Connection timed out. Check your internet.';
    } catch (e) {
      _serverError = 'Failed to load servers: $e';
    } finally {
      _isLoadingServers = false;
      notifyListeners();
    }
  }

  // ── Server selection ─────────────────────────────────────
  void selectServer(ServerModel server) {
    _selectedServer = server;
    notifyListeners();
  }

  // ── Connect ───────────────────────────────────────────────
  Future<void> connect() async {
    final server = _selectedServer;
    if (server == null) return;
    if (!_status.isDisconnected) return;
    _updateState(VpnState.connecting);
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = Timer(const Duration(seconds: 25), _onConnectTimeout);
    try {
      if (!_wireguardInitialized) {
        await _wireguard.initialize(
          interfaceName: 'wg0',
          vpnName: 'NextBolt VPN',
        );
        _wireguardInitialized = true;
      }
      await _wireguard.startVpn(
        serverAddress: server.endpoint,
        wgQuickConfig: getWireGuardConfig()!,
        providerBundleIdentifier: _iosProviderBundleIdentifier,
      );
    } catch (e) {
      _connectTimeoutTimer?.cancel();
      _status = _status.copyWith(
        state: VpnState.error,
        errorMessage: 'Failed to start VPN: $e',
      );
      notifyListeners();
    }
  }

  // ── Disconnect ────────────────────────────────────────────
  Future<void> disconnect() async {
    if (_status.isDisconnected) return;
    _connectTimeoutTimer?.cancel();
    _updateState(VpnState.disconnecting);
    try {
      await _wireguard.stopVpn();
    } catch (e) {
      _status = _status.copyWith(
        state: VpnState.error,
        errorMessage: 'Failed to stop VPN: $e',
      );
      notifyListeners();
    }
  }

  // ── Toggle ────────────────────────────────────────────────
  Future<void> toggle() async {
    if (_status.isDisconnected) {
      await connect();
    } else {
      // Connecting or disconnecting: tapping again cancels the attempt.
      await disconnect();
    }
  }

  Future<void> _onConnectTimeout() async {
    if (!_status.isConnecting) return;
    try {
      await _wireguard.stopVpn();
    } catch (_) {}
    _status = _status.copyWith(
      state: VpnState.error,
      errorMessage: 'Connection timed out. Check the server or your network and try again.',
    );
    notifyListeners();
  }

  // ── WireGuard config ──────────────────────────────────────
  String? getWireGuardConfig() {
    final s = _selectedServer;
    if (s == null) return null;
    return '''
[Interface]
PrivateKey = ${s.privateKey}
Address = ${s.address}
DNS = ${s.dns}

[Peer]
PublicKey = ${s.publicKey}
PresharedKey = ${s.presharedKey}
Endpoint = ${s.endpoint}
AllowedIPs = ${s.allowedIps}
PersistentKeepalive = ${s.keepalive}
''';
  }

  // ── WireGuard stage/traffic callbacks ─────────────────────
  void _onStageChanged(VpnStage stage) {
    switch (stage) {
      case VpnStage.connecting:
      case VpnStage.waitingConnection:
      case VpnStage.authenticating:
      case VpnStage.reconnect:
      case VpnStage.preparing:
        _updateState(VpnState.connecting);
        break;
      case VpnStage.connected:
        _onTunnelConnected();
        break;
      case VpnStage.disconnecting:
        _updateState(VpnState.disconnecting);
        break;
      case VpnStage.disconnected:
      case VpnStage.noConnection:
      case VpnStage.exiting:
        _onTunnelDisconnected();
        break;
      case VpnStage.denied:
        _stopTimers();
        _status = _status.copyWith(
          state: VpnState.error,
          errorMessage: 'VPN permission denied',
        );
        notifyListeners();
        break;
    }
  }

  void _onTraffic(Map<String, dynamic> data) {
    if (!_status.isConnected) return;
    final dl = double.tryParse(data['downloadSpeed']?.toString() ?? '') ?? 0;
    final ul = double.tryParse(data['uploadSpeed']?.toString() ?? '') ?? 0;
    _status = _status.copyWith(
      downloadSpeed: dl.round(),
      uploadSpeed: ul.round(),
    );
    notifyListeners();
  }

  Future<void> _onTunnelConnected() async {
    _connectTimeoutTimer?.cancel();
    _status = _status.copyWith(
      state: VpnState.connected,
      currentIp: null,
      sessionSeconds: 0,
    );
    notifyListeners();
    _startSessionTimer();

    // The interface can come up before the WireGuard handshake finishes,
    // so the first IP check may run through a tunnel that isn't passing
    // traffic yet. Retry a few times before giving up.
    for (var attempt = 0; attempt < 4; attempt++) {
      if (!_status.isConnected) return;
      final ip = await IpLookupService.fetchPublicIp();
      if (ip != null) {
        if (_status.isConnected) {
          _status = _status.copyWith(currentIp: ip);
          notifyListeners();
        }
        return;
      }
      await Future.delayed(const Duration(seconds: 4));
    }
  }

  void _onTunnelDisconnected() {
    _stopTimers();
    _status = VpnStatus(
      state: VpnState.disconnected,
      originalIp: _status.originalIp,
    );
    notifyListeners();
    unawaited(_refreshOriginalIp());
  }

  Future<void> _refreshOriginalIp() async {
    final ip = await IpLookupService.fetchPublicIp();
    if (ip != null && _status.isDisconnected) {
      _status = _status.copyWith(originalIp: ip);
      notifyListeners();
    }
  }

  // ── Timers ────────────────────────────────────────────────
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _status = _status.copyWith(
        sessionSeconds: _status.sessionSeconds + 1,
      );
      notifyListeners();
    });
  }

  void _stopTimers() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _connectTimeoutTimer?.cancel();
    _connectTimeoutTimer = null;
  }

  void _updateState(VpnState state) {
    _status = _status.copyWith(state: state);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    _stageSub?.cancel();
    _trafficSub?.cancel();
    super.dispose();
  }
}