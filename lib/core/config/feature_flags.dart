/// Compile-time switches for optional product surfaces.
class FeatureFlags {
  const FeatureFlags._();

  /// Master switch for the paid "Pro" tier.
  ///
  /// While `false` the app ships as a single free tier: no upgrade screen,
  /// no PRO badges, no locked servers, no bandwidth quota, and the store
  /// connection is never opened.
  ///
  /// **Nothing has been deleted.** PremiumScreen, IapService, the PRO badges
  /// and the bandwidth quota logic all still exist and are still compiled —
  /// they are only skipped at their entry points. Flip this to `true` to
  /// bring the whole Pro experience back with no other code changes.
  ///
  /// When re-enabling, remember the store side still has to be in place:
  /// the nextboltvpn_{weekly,monthly,yearly} subscription SKUs must exist in
  /// Google Play Console and the Amazon Developer Console, and Amazon builds
  /// need `fireOsEnabled=true` in android/gradle.properties.
  static const bool premiumEnabled = false;

  /// Support entries in Settings: Rate Us, Contact Support, Help Center and
  /// Share. While `false` the Settings screen keeps only Privacy Policy and
  /// Terms of Service, and that section is titled "Legal" instead of
  /// "Support".
  ///
  /// The tiles and their handlers are still compiled — flip to `true` to
  /// bring them back. Privacy Policy and Terms are deliberately NOT behind
  /// this flag: both Google Play and the Amazon Appstore require a reachable
  /// privacy policy for apps that handle network traffic, so removing them
  /// would risk a policy rejection.
  static const bool supportSectionEnabled = false;
}
