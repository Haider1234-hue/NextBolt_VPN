import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/feature_flags.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/tv_focusable.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const List<String> _protocols = SettingsService.supportedProtocols;
  static const List<String> _languages = ['English', 'Español', 'Deutsch', 'Français'];

  static const String _privacyPolicyUrl =
      'https://nextboltvpn.com/privacy-policy.html';
  static const String _termsUrl =
      'https://nextboltvpn.com/terms-of-service.html';
  static const String _helpCenterUrl    = 'https://nextboltvpn.com/help';
  static const String _supportEmail     = 'torciaapps2.0@gmail.com';
  static const String _packageName = 'com.torcia.secure.vpn.proxy';

  /// Opens the listing straight in the Amazon Appstore app.
  static const String _amazonAppUrl = 'amzn://apps/android?p=$_packageName';

  /// Browser fallback for devices without the Appstore app installed.
  static const String _amazonWebUrl =
      'https://www.amazon.com/gp/mas/dl/android?p=$_packageName';

  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    }
  }

  /// Opens the Amazon Appstore listing so the user can leave a review.
  /// Tries the native app first and falls back to the web listing, since
  /// `amzn://` resolves to nothing when the Appstore app isn't installed.
  Future<void> _launchAmazonListing(BuildContext context) async {
    final appUri = Uri.parse(_amazonAppUrl);
    try {
      if (await canLaunchUrl(appUri) &&
          await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // Fall through to the browser listing below.
    }
    if (context.mounted) {
      await _launchUrl(context, _amazonWebUrl);
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open: $url'),
            backgroundColor: AppColors.disconnected,
          ),
        );
      }
    }
  }

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'NextBolt VPN Support',
      },
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app found. Contact: $_supportEmail'),
          ),
        );
      }
    }
  }

  void _showProtocolSelector(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Select VPN Protocol',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ..._protocols.map((proto) => ListTile(
                  title: Text(
                    proto,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: settings.protocol == proto
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.cyan)
                      : null,
                  onTap: () {
                    settings.setProtocol(proto);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, SettingsService settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Select App Language',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ..._languages.map((lang) => ListTile(
                  title: Text(
                    lang,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: settings.language == lang
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.cyan)
                      : null,
                  onTap: () {
                    settings.setLanguage(lang);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        // Wait for SharedPreferences to load before rendering toggles.
        // Without this guard, switches briefly show their initial `false`
        // default and a race-condition toggle during _load() would reset them.
        if (!settings.loaded) {
          return const Scaffold(
            backgroundColor: AppColors.bgDark,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: AppColors.bgDark,
          appBar: AppBar(
            title: Text(l10n.settings),
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  )
                : null,
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.md),
            children: [
              // ── GENERAL ──────────────────────────────────────
              _buildSectionHeader(l10n.general),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.flash_on_rounded,
                  iconColor: AppColors.cyan,
                  title: l10n.autoConnect,
                  subtitle: l10n.autoConnectSub,
                  value: settings.autoConnect,
                  onChanged: settings.setAutoConnect,
                ),
                const Divider(),
                _buildOptionTile(
                  icon: Icons.language_rounded,
                  iconColor: AppColors.purple,
                  title: l10n.language,
                  value: settings.language,
                  onTap: () => _showLanguageSelector(context, settings),
                ),
              ]),
              const SizedBox(height: AppSizes.lg),

              // ── SECURITY ─────────────────────────────────────
              _buildSectionHeader(l10n.security),
              _buildCard([
                _buildSwitchTile(
                  icon: Icons.gpp_bad_rounded,
                  iconColor: AppColors.disconnected,
                  title: l10n.killSwitch,
                  subtitle: l10n.killSwitchSub,
                  value: settings.killSwitch,
                  onChanged: settings.setKillSwitch,
                ),
                const Divider(),
                _buildOptionTile(
                  icon: Icons.lan_rounded,
                  iconColor: AppColors.cyan,
                  title: l10n.protocol,
                  subtitle: l10n.protocolSub,
                  value: settings.protocol,
                  onTap: () => _showProtocolSelector(context, settings),
                ),
              ]),
              const SizedBox(height: AppSizes.lg),

              // ── SUPPORT & LEGAL ───────────────────────────────
              // Rate Us, Contact Support, Privacy Policy and Terms stay
              // regardless of the support flag: the stores require a reachable
              // privacy policy and support contact, and Rate Us points at the
              // live Amazon listing. The entries still behind the flag point
              // at pages that don't exist yet.
              _buildSectionHeader(l10n.support),
              _buildCard([
                _buildActionTile(
                  icon: Icons.star_rate_rounded,
                  iconColor: const Color(0xFFFFD700),
                  title: l10n.rateUs,
                  subtitle: 'Enjoying the app? Leave us a review',
                  onTap: () => _launchAmazonListing(context),
                ),
                const Divider(),
                if (FeatureFlags.supportSectionEnabled) ...[
                  _buildActionTile(
                    icon: Icons.help_outline_rounded,
                    iconColor: AppColors.connecting,
                    title: 'Help Center',
                    subtitle: 'FAQs, guides & troubleshooting',
                    onTap: () => _launchUrl(context, _helpCenterUrl),
                  ),
                  const Divider(),
                  _buildActionTile(
                    icon: Icons.share_rounded,
                    iconColor: AppColors.connected,
                    title: 'Share NextBolt VPN',
                    subtitle: 'Recommend us to friends & family',
                    onTap: _shareApp,
                  ),
                  const Divider(),
                ],
                _buildActionTile(
                  icon: Icons.headset_mic_rounded,
                  iconColor: AppColors.cyan,
                  title: l10n.contactSupport,
                  subtitle: _supportEmail,
                  onTap: () => _launchEmail(context),
                ),
                const Divider(),
                _buildActionTile(
                  icon: Icons.policy_rounded,
                  iconColor: AppColors.purple,
                  title: l10n.privacyPolicy,
                  subtitle: 'How we handle your data',
                  onTap: () => _launchUrl(context, _privacyPolicyUrl),
                ),
                const Divider(),
                _buildActionTile(
                  icon: Icons.description_rounded,
                  iconColor: AppColors.purple,
                  title: l10n.termsOfService,
                  subtitle: 'Rules and conditions of use',
                  onTap: () => _launchUrl(context, _termsUrl),
                ),
              ]),
              const SizedBox(height: AppSizes.xl),

              // ── VERSION FOOTER ────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Text(
                      l10n.appName,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _version.isEmpty
                          ? l10n.appVersion
                          : '${l10n.appVersion} $_version (Build $_buildNumber)',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: AppSizes.sm),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Card(
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return TvFocusable(
      onTap: () => onChanged(!value),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 4,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
        trailing: ExcludeFocus(
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return TvFocusable(
      onTap: onTap,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 4,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    const text =
        'Stay private online with NextBolt VPN — fast, secure & easy to use.\n'
        'Download it now: https://nextboltvpn.com';
    Clipboard.setData(const ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share link copied to clipboard!'),
        backgroundColor: AppColors.connected,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return TvFocusable(
      onTap: onTap,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 4,
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              )
            : null,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textHint,
          size: 20,
        ),
      ),
    );
  }
}
