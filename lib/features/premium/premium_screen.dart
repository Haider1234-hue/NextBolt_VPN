import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../services/vpn_service.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const List<String> _features = [
    '🌍  50+ countries, 500+ servers',
    '⚡  10× faster speeds',
    '🔒  No-logs guarantee',
    '📱  Unlimited devices',
    '🎮  Gaming & streaming optimized',
    '🛡️  Ad blocker included',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<VpnService>(
      builder: (context, vpn, _) {
        final isPremium = vpn.bandwidth.isPremium;
        return Scaffold(
          backgroundColor: AppColors.bgDark,
          body: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF100820), AppColors.bgDark],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: AppColors.textHint),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        child: Column(
                          children: [
                            // ── Icon ──────────────────────────────
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFD700),
                                    Color(0xFFFF8F00),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.3),
                                    blurRadius: 24,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Colors.black,
                                size: 44,
                              ),
                            ),
                            const SizedBox(height: AppSizes.md),

                            // ── Heading ───────────────────────────
                            Text(
                              isPremium ? 'Premium Active' : l10n.upgradeToPro,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isPremium
                                  ? 'You have full access to all servers and features.'
                                  : l10n.premiumTagline,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSizes.xl),

                            // ── Features ──────────────────────────
                            ..._features.map(
                              (f) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      f,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: AppSizes.xl * 2),

                            // ── Close button ─────────────────────
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.bgCard,
                                  foregroundColor: AppColors.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull,
                                    ),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  'Close',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.xl),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
