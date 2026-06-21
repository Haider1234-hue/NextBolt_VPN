import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1;

  static const List<_Plan> _plans = [
    _Plan(id: 0, label: 'Weekly',  price: '\$2.99',  period: '/week',  badge: null),
    _Plan(id: 1, label: 'Monthly', price: '\$7.99',  period: '/month', badge: null),
    _Plan(id: 2, label: 'Yearly',  price: '\$39.99', period: '/year',  badge: 'BEST VALUE'),
  ];

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
                    icon: const Icon(Icons.close,
                        color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFD700),
                                Color(0xFFFF8F00)
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700)
                                    .withValues(alpha: 0.3),
                                blurRadius: 24,
                              )
                            ],
                          ),
                          child: const Icon(
                              Icons.workspace_premium,
                              color: Colors.black,
                              size: 44),
                        ),
                        const SizedBox(height: AppSizes.md),
                        const Text(
                          AppStrings.upgradeToPro,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          AppStrings.premiumTagline,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        ..._features.map(
                          (f) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5),
                            child: Row(
                              children: [
                                Text(f,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      height: 1.4,
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        Row(
                          children: _plans
                              .map((p) => Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedPlan = p.id),
                                      child: _PlanCard(
                                        plan: p,
                                        selected:
                                            _selectedPlan == p.id,
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: AppSizes.xl),
                        SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.purple,
                                  AppColors.cyan
                                ],
                              ),
                              borderRadius: BorderRadius.circular(
                                  AppSizes.radiusFull),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull),
                                ),
                              ),
                              onPressed: () {},
                              child: Text(
                                'Subscribe ${_plans[_selectedPlan].label}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            AppStrings.restorePurchase,
                            style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            AppStrings.continueWithFree,
                            style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: AppSizes.lg),
                        const Text(
                          'Cancel anytime. Billed through App Store.',
                          style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 11),
                          textAlign: TextAlign.center,
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
  }
}

class _Plan {
  final int id;
  final String label;
  final String price;
  final String period;
  final String? badge;
  const _Plan({
    required this.id,
    required this.label,
    required this.price,
    required this.period,
    required this.badge,
  });
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  const _PlanCard({required this.plan, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.purple.withValues(alpha: 0.15)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: selected ? AppColors.purple : AppColors.divider,
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (plan.badge != null) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(plan.badge!,
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 8,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 4),
          ] else
            const SizedBox(height: 16),
          Text(plan.price,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800)),
          Text(plan.period,
              style: const TextStyle(
                  color: AppColors.textHint, fontSize: 10)),
          const SizedBox(height: 4),
          Text(plan.label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}