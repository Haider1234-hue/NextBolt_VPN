import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/feature_flags.dart';

/// Tracks per-user data quotas:
/// - Free users: 500MB/day, resets at local midnight.
/// - Premium users: 100GB/month, resets on the 1st of each month.
///
/// While [FeatureFlags.premiumEnabled] is false there is no way to upgrade,
/// so quotas are lifted entirely rather than stranding users at a cap they
/// cannot lift. Usage is still tracked, just never enforced.
class BandwidthService {
  static const int freeDailyLimitBytes = 500 * 1024 * 1024;
  static const int premiumMonthlyLimitBytes = 100 * 1024 * 1024 * 1024;

  static const _kIsPremium    = 'bw_is_premium';
  static const _kDailyBytes   = 'bw_daily_bytes';
  static const _kDailyDate    = 'bw_daily_date';
  static const _kMonthlyBytes = 'bw_monthly_bytes';
  static const _kMonthlyMonth = 'bw_monthly_month';

  SharedPreferences? _prefs;
  bool isPremium = false;
  int usedBytes = 0;

  bool get isReady => _prefs != null;

  /// True when the user has no quota — either they bought Pro, or the paid
  /// tier is switched off entirely and everyone is unlimited.
  bool get isUnlimited => !FeatureFlags.premiumEnabled || isPremium;

  /// The tier's nominal quota. Meaningless while [isUnlimited] is true —
  /// check that first. Never gate behaviour on this value directly; use
  /// [isLimitReached], which already accounts for the paid tier being off.
  int get limitBytes =>
      isPremium ? premiumMonthlyLimitBytes : freeDailyLimitBytes;

  int get remainingBytes => (limitBytes - usedBytes).clamp(0, limitBytes);

  bool get isLimitReached =>
      FeatureFlags.premiumEnabled && isReady && usedBytes >= limitBytes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isPremium = _prefs!.getBool(_kIsPremium) ?? false;
    _rollover();
  }

  String get _todayKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}-${n.day}';
  }

  String get _monthKey {
    final n = DateTime.now();
    return '${n.year}-${n.month}';
  }

  /// Resets the counter when the day/month boundary has passed.
  void _rollover() {
    final prefs = _prefs;
    if (prefs == null) return;
    if (isPremium) {
      final storedMonth = prefs.getString(_kMonthlyMonth);
      if (storedMonth != _monthKey) {
        prefs.setString(_kMonthlyMonth, _monthKey);
        prefs.setInt(_kMonthlyBytes, 0);
        usedBytes = 0;
      } else {
        usedBytes = prefs.getInt(_kMonthlyBytes) ?? 0;
      }
    } else {
      final storedDay = prefs.getString(_kDailyDate);
      if (storedDay != _todayKey) {
        prefs.setString(_kDailyDate, _todayKey);
        prefs.setInt(_kDailyBytes, 0);
        usedBytes = 0;
      } else {
        usedBytes = prefs.getInt(_kDailyBytes) ?? 0;
      }
    }
  }

  /// Adds [deltaBytes] (a delta, not a cumulative total) to the current period's usage.
  Future<void> addUsage(int deltaBytes) async {
    if (deltaBytes <= 0) return;
    final prefs = _prefs;
    if (prefs == null) return;
    _rollover();
    usedBytes += deltaBytes;
    if (isPremium) {
      await prefs.setInt(_kMonthlyBytes, usedBytes);
    } else {
      await prefs.setInt(_kDailyBytes, usedBytes);
    }
  }

  Future<void> setPremium(bool value) async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    _prefs = prefs;
    isPremium = value;
    await prefs.setBool(_kIsPremium, value);
    _rollover();
  }
}
