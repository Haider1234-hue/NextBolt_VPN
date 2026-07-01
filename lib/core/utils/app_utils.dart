import 'dart:math';

class AppUtils {
  AppUtils._();

  /// Format bytes per second into readable string: "1.2 MB/s"
  static String formatSpeed(int bytesPerSec) {
    if (bytesPerSec < 1024) return '${bytesPerSec}B/s';
    if (bytesPerSec < 1024 * 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${(bytesPerSec / (1024 * 1024)).toStringAsFixed(1)} MB/s';
  }

  /// Format seconds into HH:MM:SS string
  static String formatDuration(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    final s = totalSeconds % 60;
    return '${_twoDigit(h)}:${_twoDigit(m)}:${_twoDigit(s)}';
  }

  static String _twoDigit(int n) => n.toString().padLeft(2, '0');

  /// Format a byte count into readable string: "120 MB", "2.1 GB"
  static String formatDataSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Mask an IP for display when connected: 192.168.1.1 → 192.168.x.x
  static String maskIp(String ip) {
    final parts = ip.split('.');
    if (parts.length != 4) return ip;
    return '${parts[0]}.${parts[1]}.x.x';
  }

  /// Returns a ping quality label
  static String pingLabel(int ms) {
    if (ms < 80) return 'Excellent';
    if (ms < 150) return 'Good';
    if (ms < 250) return 'Fair';
    return 'Poor';
  }

  /// Random int in range [min, max]
  static int randomInt(int min, int max) =>
      min + Random().nextInt(max - min + 1);

  /// Country code → emoji flag
  static String countryCodeToFlag(String code) {
    return code.toUpperCase().split('').map((c) {
      return String.fromCharCode(c.codeUnitAt(0) + 127397);
    }).join();
  }
}