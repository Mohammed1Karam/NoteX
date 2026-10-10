import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// زر أيقونة دائري بخلفية شبه شفافة، يناسب الخلفيات الملوّنة.
class CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Color? color;
  final Color? background;

  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: background ?? Colors.white.withValues(alpha: 0.6),
      shape: CircleBorder(
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 21, color: color ?? AppColors.textPrimary),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
