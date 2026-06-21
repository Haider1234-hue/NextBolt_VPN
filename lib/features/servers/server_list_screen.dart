import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/constants/app_strings.dart';
import '../../services/vpn_service.dart';
import '../../features/home/home_controller.dart';
import '../../models/server_model.dart';
import 'server_tile.dart';

class ServerListScreen extends StatefulWidget {
  const ServerListScreen({super.key});

  @override
  State<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends State<ServerListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VpnService>().fetchServers();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ServerModel> _filtered(List<ServerModel> servers) {
    if (_query.isEmpty) return servers;
    return servers.where((s) =>
      s.countryName.toLowerCase().contains(_query.toLowerCase()) ||
      s.city.toLowerCase().contains(_query.toLowerCase()) ||
      s.serverName.toLowerCase().contains(_query.toLowerCase()),
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text(AppStrings.servers),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: Consumer<VpnService>(
        builder: (ctx, vpnService, _) {

          // ── Loading ──────────────────────────────────────
          if (vpnService.isLoadingServers) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.cyan),
                  SizedBox(height: AppSizes.md),
                  Text(
                    'Loading servers...',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // ── Error ────────────────────────────────────────
          if (vpnService.serverError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.disconnected,
                      size: 56,
                    ),
                    const SizedBox(height: AppSizes.md),
                    Text(
                      vpnService.serverError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: AppSizes.lg),
                    ElevatedButton.icon(
                      onPressed: () => vpnService.fetchServers(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          // ── Empty ────────────────────────────────────────
          if (vpnService.servers.isEmpty) {
            return const Center(
              child: Text(
                'No servers available.',
                style: TextStyle(color: AppColors.textHint),
              ),
            );
          }

          // ── Server List ──────────────────────────────────
          final controller    = ctx.read<HomeController>();
          final freeServers    = _filtered(vpnService.freeServers);
          final premiumServers = _filtered(vpnService.premiumServers);

          return Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    hintText: AppStrings.searchServers,
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),

              // Count badges
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSizes.md,
                  right: AppSizes.md,
                  bottom: AppSizes.sm,
                ),
                child: Row(
                  children: [
                    _Badge(
                      label: '${vpnService.servers.length} servers',
                      color: AppColors.cyan,
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      label: '${vpnService.freeServers.length} free',
                      color: AppColors.connected,
                    ),
                  ],
                ),
              ),

              // List
              Expanded(
                child: ListView(
                  children: [
                    if (freeServers.isNotEmpty) ...[
                      const _SectionHeader(AppStrings.freeServers),
                      ...freeServers.map(
                        (s) => ServerTile(
                          server: s,
                          isSelected:
                              controller.selectedServer?.id == s.id,
                          onTap: () {
                            controller.selectServer(s);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                    if (premiumServers.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.sm),
                      const _SectionHeader(
                        AppStrings.premiumServers,
                        trailing: Icon(
                          Icons.lock,
                          color: Color(0xFFFFD700),
                          size: 14,
                        ),
                      ),
                      ...premiumServers.map(
                        (s) => ServerTile(
                          server: s,
                          isSelected:
                              controller.selectedServer?.id == s.id,
                          onTap: () => Navigator.pushNamed(
                            context, '/premium'),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionHeader(this.title, {this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md + 2,
        vertical: AppSizes.sm,
      ),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textHint,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing!,
          ],
        ],
      ),
    );
  }
}