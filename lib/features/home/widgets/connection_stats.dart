import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/app_utils.dart';
import '../../../models/vpn_status.dart';

class ConnectionStats extends StatelessWidget {
  final VpnStatus status;

  const ConnectionStats({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: status.isConnected ? 1.0 : 0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(child: _StatItem(
              icon: Icons.arrow_downward_rounded,
              iconColor: AppColors.connected,
              label: 'Download',
              value: AppUtils.formatSpeed(status.downloadSpeed),
            )),
            Container(width: 1, height: 36, color: AppColors.divider),
            Expanded(child: _StatItem(
              icon: Icons.arrow_upward_rounded,
              iconColor: AppColors.cyan,
              label: 'Upload',
              value: AppUtils.formatSpeed(status.uploadSpeed),
            )),
            Container(width: 1, height: 36, color: AppColors.divider),
            Expanded(child: _StatItem(
              icon: Icons.access_time_rounded,
              iconColor: AppColors.purple,
              label: 'Duration',
              value: AppUtils.formatDuration(status.sessionSeconds),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: AppSizes.iconMd),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}