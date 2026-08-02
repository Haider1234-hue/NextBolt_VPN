import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/tv_focusable.dart';
import '../../services/iap_service.dart';
import '../../services/vpn_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  int _selectedPlan = 1; // 0=weekly, 1=monthly, 2=yearly

  static const List<_PlanMeta> _plans = [
    _PlanMeta(
      id: 0,
      label: 'Weekly',
      fallbackPrice: '\$2.99',
      period: '/week',
      badge: null,
      productId: IapService.weeklyId,
    ),
    _PlanMeta(
      id: 1,
      label: 'Monthly',
      fallbackPrice: '\$7.99',
      period: '/month',
      badge: null,
      productId: IapService.monthlyId,
    ),
    _PlanMeta(
      id: 2,
      label: 'Yearly',
      fallbackPrice: '\$39.99',
      period: '/year',
      badge: 'BEST VALUE',
      productId: IapService.yearlyId,
    ),
  ];

  static const List<String> _features = [
    '🌍  50+ countries, 500+ servers',
    '⚡  10× faster speeds',
    '🔒  No-logs guarantee',
    '📱  Unlimited devices',
    '🎮  Gaming & streaming optimized',
    '🛡️  Ad blocker included',
  ];

  String? _lastError;

  @override
  void initState() {
    super.initState();
    // Listen for IAP errors and premium activation after frame is built.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IapService>().addListener(_onIapChanged);
    });
  }

  @override
  void dispose() {
    context.read<IapService>().removeListener(_onIapChanged);
    super.dispose();
  }

  void _onIapChanged() {
    if (!mounted) return;
    final iap = context.read<IapService>();

    // Show error snackbar when a new error arrives.
    if (iap.error != null && iap.error != _lastError) {
      _lastError = iap.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(iap.error!),
          backgroundColor: AppColors.disconnected,
        ),
      );
    }

    // Close screen when premium activates successfully.
    if (context.read<VpnService>().bandwidth.isPremium) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium activated! Enjoy unlimited access.'),
          backgroundColor: AppColors.connected,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _onSubscribe(BuildContext context, IapService iap) async {
    final meta = _plans[_selectedPlan];
    final product = iap.productFor(meta.productId);

    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Store not available. Please check your connection and try again.',
          ),
          backgroundColor: AppColors.disconnected,
        ),
      );
      return;
    }

    await iap.buy(product);
  }

  String _priceFor(_PlanMeta meta, IapService iap) {
    final product = iap.productFor(meta.productId);
    return product?.displayPrice ?? meta.fallbackPrice;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer2<IapService, VpnService>(
      builder: (context, iap, vpn, _) {
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
                                  vertical: 5,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      f,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (!isPremium) ...[
                              const SizedBox(height: AppSizes.xl),

                              // ── Plan cards ────────────────────────
                              Row(
                                children: _plans
                                    .map(
                                      (p) => Expanded(
                                        child: TvFocusable(
                                          autofocus: p.id == 1,
                                          onTap: () => setState(
                                            () => _selectedPlan = p.id,
                                          ),
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () => _selectedPlan = p.id,
                                            ),
                                            child: _PlanCard(
                                              label: p.label,
                                              price: _priceFor(p, iap),
                                              period: p.period,
                                              badge: p.badge,
                                              selected: _selectedPlan == p.id,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: AppSizes.xl),

                              // ── Subscribe button ──────────────────
                              SizedBox(
                                width: double.infinity,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.purple,
                                        AppColors.cyan,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppSizes.radiusFull,
                                        ),
                                      ),
                                    ),
                                    onPressed: iap.purchasing
                                        ? null
                                        : () => _onSubscribe(context, iap),
                                    child: iap.purchasing
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : Text(
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

                              // ── Restore / Continue ─────────────────
                              TextButton(
                                onPressed: iap.purchasing
                                    ? null
                                    : () => iap.restore(),
                                child: Text(
                                  l10n.restorePurchase,
                                  style: const TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],

                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                isPremium ? 'Close' : l10n.continueWithFree,
                                style: const TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSizes.lg),
                            if (!isPremium)
                              const Text(
                                'Cancel anytime. Billed through Google Play.',
                                style: TextStyle(
                                  color: AppColors.textHint,
                                  fontSize: 11,
                                ),
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
      },
    );
  }
}

// ── Data ──────────────────────────────────────────────────────────────────────

class _PlanMeta {
  final int id;
  final String label;
  final String fallbackPrice;
  final String period;
  final String? badge;
  final String productId;

  const _PlanMeta({
    required this.id,
    required this.label,
    required this.fallbackPrice,
    required this.period,
    required this.badge,
    required this.productId,
  });
}

// ── Plan card widget ──────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final String label;
  final String price;
  final String period;
  final String? badge;
  final bool selected;

  const _PlanCard({
    required this.label,
    required this.price,
    required this.period,
    required this.badge,
    required this.selected,
  });

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
          if (badge != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.cyan,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ] else
            const SizedBox(height: 16),
          Text(
            price,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            period,
            style: const TextStyle(color: AppColors.textHint, fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
