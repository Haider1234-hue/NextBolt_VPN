import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/l10n/app_localizations.dart';

enum VpnState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatus {
  final VpnState state;
  final String? currentIp;
  final String? originalIp;
  final int downloadSpeed;
  final int uploadSpeed;
  final int sessionSeconds;
  final String? errorMessage;

  const VpnStatus({
    this.state = VpnState.disconnected,
    this.currentIp,
    this.originalIp,
    this.downloadSpeed = 0,
    this.uploadSpeed = 0,
    this.sessionSeconds = 0,
    this.errorMessage,
  });

  VpnStatus copyWith({
    VpnState? state,
    String? currentIp,
    String? originalIp,
    int? downloadSpeed,
    int? uploadSpeed,
    int? sessionSeconds,
    String? errorMessage,
  }) {
    return VpnStatus(
      state:          state          ?? this.state,
      currentIp:      currentIp      ?? this.currentIp,
      originalIp:     originalIp     ?? this.originalIp,
      downloadSpeed:  downloadSpeed  ?? this.downloadSpeed,
      uploadSpeed:    uploadSpeed    ?? this.uploadSpeed,
      sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      errorMessage:   errorMessage   ?? this.errorMessage,
    );
  }

  bool get isConnected    => state == VpnState.connected;
  bool get isConnecting   =>
      state == VpnState.connecting || state == VpnState.disconnecting;
  bool get isDisconnected =>
      state == VpnState.disconnected || state == VpnState.error;

  String statusLabel(AppLocalizations l10n) {
    switch (state) {
      case VpnState.disconnected:  return l10n.notConnected;
      case VpnState.connecting:    return l10n.connecting;
      case VpnState.connected:     return l10n.connected;
      case VpnState.disconnecting: return l10n.disconnecting;
      case VpnState.error:         return l10n.connectionFailed;
    }
  }

  Color get statusColor {
    switch (state) {
      case VpnState.disconnected:  return AppColors.disconnected;
      case VpnState.connecting:    return AppColors.connecting;
      case VpnState.connected:     return AppColors.connected;
      case VpnState.disconnecting: return AppColors.connecting;
      case VpnState.error:         return AppColors.disconnected;
    }
  }

  RadialGradient get glowGradient {
    switch (state) {
      case VpnState.connected:     return AppColors.connectedGlow;
      case VpnState.connecting:    return AppColors.connectingGlow;
      case VpnState.disconnecting: return AppColors.connectingGlow;
      default:                     return AppColors.disconnectedGlow;
    }
  }

  static const VpnStatus initial = VpnStatus(
    state: VpnState.disconnected,
    originalIp: '0.0.0.0',
  );
}