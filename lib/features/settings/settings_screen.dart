import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const List<String> _protocols = ['WireGuard', 'OpenVPN', 'IKEv2'];
  static const List<String> _languages = ['English', 'Español', 'Deutsch', 'Français'];

  // Support URLs — update these to match your live domain paths
  static const String _privacyPolicyUrl   = 'https://nextboltvpn.com/privacy-policy';
  static const String _termsUrl           = 'https://nextboltvpn.com/terms-of-service';
  static const String _supportEmail       = 'support@nextboltvpn.com';
  // Update the package ID below once the app is published on Play Store
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.nextboltvpn';

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
              _buildSectionHeader(l10n.support),
              _buildCard([
                _buildActionTile(
                  icon: Icons.star_rate_rounded,
                  iconColor: const Color(0xFFFFD700),
                  title: l10n.rateUs,
                  onTap: () => _launchUrl(context, _playStoreUrl),
                ),
                const Divider(),
                _buildActionTile(
                  icon: Icons.headset_mic_rounded,
                  iconColor: AppColors.cyan,
                  title: l10n.contactSupport,
                  onTap: () => _launchEmail(context),
                ),
                const Divider(),
                _buildActionTile(
                  icon: Icons.policy_rounded,
                  iconColor: AppColors.purple,
                  title: l10n.privacyPolicy,
                  onTap: () => _launchUrl(context, _privacyPolicyUrl),
                ),
                const Divider(),
                _buildActionTile(
                  icon: Icons.description_rounded,
                  iconColor: AppColors.purple,
                  title: l10n.termsOfService,
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
                      '${l10n.appVersion} 1.0.0 (Build 42)',
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
    return ListTile(
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
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
    return ListTile(
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
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
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
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint,
        size: 20,
      ),
    );
  }
}
