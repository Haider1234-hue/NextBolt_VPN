import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentIndex < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      _OnboardSlide(
        title: l10n.onboardTitle1,
        body: l10n.onboardBody1,
        icon: Icons.security_rounded,
        glowColor: AppColors.cyan,
      ),
      _OnboardSlide(
        title: l10n.onboardTitle2,
        body: l10n.onboardBody2,
        icon: Icons.public_rounded,
        glowColor: AppColors.purple,
      ),
      _OnboardSlide(
        title: l10n.onboardTitle3,
        body: l10n.onboardBody3,
        icon: Icons.verified_user_rounded,
        glowColor: AppColors.connected,
      ),
    ];
    final isLast = _currentIndex == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppColors.bgGradient),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: AnimatedOpacity(
                      opacity: isLast ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: isLast
                          ? const SizedBox(width: 48, height: 48)
                          : TextButton(
                              onPressed: _onSkip,
                              child: Text(
                                l10n.skip,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (idx) {
                      setState(() => _currentIndex = idx);
                    },
                    itemCount: slides.length,
                    itemBuilder: (ctx, i) {
                      final s = slides[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.xl,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: s.glowColor.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: s.glowColor.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: s.glowColor.withValues(alpha: 0.2),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(s.icon, color: s.glowColor, size: 72),
                            ),
                            const SizedBox(height: 48),
                            Text(
                              s.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              s.body,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.lg,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          slides.length,
                          (idx) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 6),
                            height: 6,
                            width: idx == _currentIndex ? 18 : 6,
                            decoration: BoxDecoration(
                              color: idx == _currentIndex
                                  ? AppColors.cyan
                                  : AppColors.divider,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.purple, AppColors.cyan],
                          ),
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusFull),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                          ),
                          onPressed: _onNext,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLast ? l10n.getStarted : l10n.next,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardSlide {
  final String title;
  final String body;
  final IconData icon;
  final Color glowColor;

  const _OnboardSlide({
    required this.title,
    required this.body,
    required this.icon,
    required this.glowColor,
  });
}
