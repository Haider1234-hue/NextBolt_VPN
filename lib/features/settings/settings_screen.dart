import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _killSwitch = false;
  bool _autoConnect = false;
  String _selectedProtocol = 'WireGuard';
  String _selectedLanguage = 'English';

  final List<String> _protocols = ['WireGuard', 'OpenVPN', 'IKEv2'];
  final List<String> _languages = ['English', 'Español', 'Deutsch', 'Français'];

  void _showProtocolSelector() {
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
                  trailing: _selectedProtocol == proto
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.cyan)
                      : null,
                  onTap: () {
                    setState(() => _selectedProtocol = proto);
                    Navigator.pop(ctx);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector() {
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
                  trailing: _selectedLanguage == lang
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.cyan)
                      : null,
                  onTap: () {
                    setState(() => _selectedLanguage = lang);
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
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text(AppStrings.settings),
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
          // ── GENERAL SECTION ──────────────────────────────────
          _buildSectionHeader(AppStrings.general),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.flash_on_rounded,
              iconColor: AppColors.cyan,
              title: AppStrings.autoConnect,
              subtitle: AppStrings.autoConnectSub,
              value: _autoConnect,
              onChanged: (val) => setState(() => _autoConnect = val),
            ),
            const Divider(),
            _buildOptionTile(
              icon: Icons.language_rounded,
              iconColor: AppColors.purple,
              title: AppStrings.language,
              value: _selectedLanguage,
              onTap: _showLanguageSelector,
            ),
          ]),
          const SizedBox(height: AppSizes.lg),

          // ── SECURITY SECTION ──────────────────────────────────
          _buildSectionHeader(AppStrings.security),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.gpp_bad_rounded,
              iconColor: AppColors.disconnected,
              title: AppStrings.killSwitch,
              subtitle: AppStrings.killSwitchSub,
              value: _killSwitch,
              onChanged: (val) => setState(() => _killSwitch = val),
            ),
            const Divider(),
            _buildOptionTile(
              icon: Icons.lan_rounded,
              iconColor: AppColors.cyan,
              title: AppStrings.protocol,
              subtitle: AppStrings.protocolSub,
              value: _selectedProtocol,
              onTap: _showProtocolSelector,
            ),
          ]),
          const SizedBox(height: AppSizes.lg),

          // ── SUPPORT & LEGAL SECTION ───────────────────────────
          _buildSectionHeader(AppStrings.support),
          _buildCard([
            _buildActionTile(
              icon: Icons.star_rate_rounded,
              iconColor: const Color(0xFFFFD700),
              title: AppStrings.rateUs,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for rating us!'),
                    backgroundColor: AppColors.cyan,
                  ),
                );
              },
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.headset_mic_rounded,
              iconColor: AppColors.cyan,
              title: AppStrings.contactSupport,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Support Ticket...'),
                  ),
                );
              },
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.policy_rounded,
              iconColor: AppColors.purple,
              title: AppStrings.privacyPolicy,
              onTap: () {},
            ),
            const Divider(),
            _buildActionTile(
              icon: Icons.description_rounded,
              iconColor: AppColors.purple,
              title: AppStrings.termsOfService,
              onTap: () {},
            ),
          ]),
          const SizedBox(height: AppSizes.xl),

          // ── APP VERSION FOOTER ───────────────────────────────
          const Center(
            child: Column(
              children: [
                Text(
                  AppStrings.appName,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${AppStrings.appVersion} 1.0.0 (Build 42)',
                  style: TextStyle(
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
      child: Column(
        children: children,
      ),
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
