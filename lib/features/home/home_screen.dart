import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/app_utils.dart';
import '../../services/vpn_service.dart';
import '../../models/vpn_status.dart';
import 'home_controller.dart';
import 'widgets/connect_button.dart';
import 'widgets/connection_stats.dart';
import 'widgets/server_selector_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final homeController = context.read<HomeController>();
      context.read<VpnService>().fetchServers().then((_) {
        if (!mounted) return;
        homeController.ensureServerSelected();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: IndexedStack(
        index: _navIndex,
        children: const [
          _HomeTab(),
          _ServersPlaceholder(),
          _SettingsPlaceholder(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
        color: AppColors.bgCard,
      ),
      child: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.pushNamed(context, '/servers');
          } else if (i == 2) {
            Navigator.pushNamed(context, '/settings');
          } else {
            setState(() => _navIndex = i);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_outlined),
            activeIcon: Icon(Icons.shield),
            label: 'VPN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_outlined),
            activeIcon: Icon(Icons.public),
            label: 'Servers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeController>(
      builder: (ctx, controller, _) {
        final status = controller.status;
        return Container(
          decoration: const BoxDecoration(
              gradient: AppColors.bgGradient),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSizes.lg),

                        // Status label
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            status.statusLabel,
                            key: ValueKey(status.state),
                            style: TextStyle(
                              color: status.statusColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // Connect button
                        ConnectButton(
                          status: status,
                          onTap: controller.toggleConnection,
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // IP row
                        _IpRow(status: status),

                        const SizedBox(height: AppSizes.lg),

                        // Stats
                        ConnectionStats(status: status),

                        const SizedBox(height: AppSizes.md),

                        // Server selector
                        ServerSelectorTile(
                          server: controller.selectedServer,
                          onTap: () => Navigator.pushNamed(
                              context, '/servers'),
                        ),

                        const SizedBox(height: AppSizes.lg),

                        // Premium banner
                        _PremiumBanner(
                          onTap: () => Navigator.pushNamed(
                              context, '/premium'),
                        ),

                        const SizedBox(height: AppSizes.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md, vertical: AppSizes.sm),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Icon(Icons.bolt,
                color: Colors.black, size: 18),
          ),
          const SizedBox(width: 8),
          const Text(
            AppStrings.appName,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, '/premium'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFD700),
                    Color(0xFFFF8F00)
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium,
                      color: Colors.black, size: 14),
                  SizedBox(width: 4),
                  Text('PRO',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── IP Row ────────────────────────────────────────────────
class _IpRow extends StatelessWidget {
  final VpnStatus status;
  const _IpRow({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius:
            BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.cyan, size: 16),
          const SizedBox(width: 6),
          Text(
            status.isConnected
                ? (status.currentIp != null
                    ? AppUtils.maskIp(status.currentIp!)
                    : 'Verifying…')
                : (status.originalIp ?? '—'),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: status.isConnected
                  ? AppColors.connected
                      .withValues(alpha: 0.15)
                  : AppColors.disconnected
                      .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(
                  AppSizes.radiusFull),
            ),
            child: Text(
              status.isConnected
                  ? '🔒 Protected'
                  : '⚠️ Exposed',
              style: TextStyle(
                color: status.isConnected
                    ? AppColors.connected
                    : AppColors.disconnected,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Premium Banner ────────────────────────────────────────
class _PremiumBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1040),
              Color(0xFF0D1A40)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(
              color: AppColors.purple.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium,
                color: Color(0xFFFFD700), size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to Pro',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                  SizedBox(height: 2),
                  Text('Unlock 50+ servers & 10x speed',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
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
              child: const Text('Get Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder tabs ──────────────────────────────────────
class _ServersPlaceholder extends StatelessWidget {
  const _ServersPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}