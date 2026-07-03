import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Wraps any widget so a TV remote (D-pad) can focus and activate it.
///
/// - Draws a cyan glow border when focused via keyboard/remote.
/// - D-pad centre / Enter / Space fires [onTap].
/// - Touch events are handled by the child as normal (InkWell / GestureDetector).
class TvFocusable extends StatefulWidget {
  const TvFocusable({
    super.key,
    required this.child,
    this.onTap,
    this.autofocus = false,
    this.focusNode,
    this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool autofocus;
  final FocusNode? focusNode;

  /// Border radius used for the focus glow ring.
  /// Defaults to [AppSizes.radiusMd].
  final BorderRadius? borderRadius;

  @override
  State<TvFocusable> createState() => _TvFocusableState();
}

class _TvFocusableState extends State<TvFocusable> {
  late final FocusNode _node;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _node = widget.focusNode ?? FocusNode(debugLabel: 'TvFocusable');
    _node.addListener(_onFocus);
  }

  @override
  void dispose() {
    _node.removeListener(_onFocus);
    if (widget.focusNode == null) _node.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() => _focused = _node.hasFocus);
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent && widget.onTap != null) {
      final k = event.logicalKey;
      if (k == LogicalKeyboardKey.select ||
          k == LogicalKeyboardKey.enter ||
          k == LogicalKeyboardKey.numpadEnter ||
          k == LogicalKeyboardKey.space) {
        widget.onTap!();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        widget.borderRadius ?? BorderRadius.circular(AppSizes.radiusMd);

    return Focus(
      focusNode: _node,
      autofocus: widget.autofocus,
      onKeyEvent: _onKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: _focused
            ? BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: AppColors.cyan, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              )
            : BoxDecoration(borderRadius: radius),
        child: widget.child,
      ),
    );
  }
}
