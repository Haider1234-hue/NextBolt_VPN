import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/vpn_status.dart';
import '../models/server_model.dart';

class VpnService extends ChangeNotifier {
  VpnStatus _status = VpnStatus.initial;
  ServerModel? _selectedServer;
  List<ServerModel> _servers = [];
  bool _isLoadingServers = false;
  String? _serverError;
  Timer? _sessionTimer;
  Timer? _speedTimer;

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
    if (_selectedServer == null) return;
    if (_status.isConnecting) return;
    _updateState(VpnState.connecting);
    await _simulateConnect();
  }

  // ── Disconnect ────────────────────────────────────────────
  Future<void> disconnect() async {
    if (_status.isDisconnected) return;
    _updateState(VpnState.disconnecting);
    await _simulateDisconnect();
  }

  // ── Toggle ────────────────────────────────────────────────
  Future<void> toggle() async {
    if (_status.isConnected) {
      await disconnect();
    } else if (_status.isDisconnected) {
      await connect();
    }
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

  // ── Private: mock connection flow ─────────────────────────
  Future<void> _simulateConnect() async {
    await Future.delayed(const Duration(seconds: 3));
    _status = _status.copyWith(
      state: VpnState.connected,
      currentIp: _selectedServer!.host,
      originalIp: '203.0.113.42',
      sessionSeconds: 0,
    );
    notifyListeners();
    _startSessionTimer();
    _startSpeedSimulator();
  }

  Future<void> _simulateDisconnect() async {
    _stopTimers();
    await Future.delayed(const Duration(seconds: 1));
    _status = VpnStatus.initial;
    notifyListeners();
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

  void _startSpeedSimulator() {
    _speedTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final dl = 300000 + (DateTime.now().millisecond * 1500);
      final ul = 80000  + (DateTime.now().millisecond * 400);
      _status = _status.copyWith(downloadSpeed: dl, uploadSpeed: ul);
      notifyListeners();
    });
  }

  void _stopTimers() {
    _sessionTimer?.cancel();
    _speedTimer?.cancel();
    _sessionTimer = null;
    _speedTimer = null;
  }

  void _updateState(VpnState state) {
    _status = _status.copyWith(state: state);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
  }
}