import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../models/vpn_status.dart';

class ConnectButton extends StatefulWidget {
  final VpnStatus status;
  final VoidCallback onTap;

  const ConnectButton({
    super.key,
    required this.status,
    required this.onTap,
  });

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(ConnectButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.isConnecting) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _primaryColor {
    if (widget.status.isConnected)  return AppColors.connected;
    if (widget.status.isConnecting) return AppColors.connecting;
    return AppColors.disconnected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.status.isConnecting ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (_, __) {
          final scale = widget.status.isConnecting ? _pulseAnim.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: _buildButton(),
          );
        },
      ),
    );
  }

  Widget _buildButton() {
    return SizedBox(
      width: AppSizes.connectButtonSize,
      height: AppSizes.connectButtonSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: AppSizes.connectButtonSize,
            height: AppSizes.connectButtonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.25),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Middle ring
          Container(
            width: AppSizes.connectButtonSize - 24,
            height: AppSizes.connectButtonSize - 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _primaryColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
          // Inner button
          Container(
            width: AppSizes.connectButtonInner,
            height: AppSizes.connectButtonInner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.25),
                  AppColors.bgCard,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: _primaryColor, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: _buildIcon(),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    if (widget.status.isConnecting) {
      return Center(
        child: SizedBox(
          width: 36,
          height: 36,
          child: CircularProgressIndicator(
            color: _primaryColor,
            strokeWidth: 3,
          ),
        ),
      );
    }

    return Center(
      child: Icon(
        widget.status.isConnected
            ? Icons.power_settings_new
            : Icons.power_settings_new_outlined,
        size: AppSizes.connectButtonIcon,
        color: _primaryColor,
      ),
    );
  }
}