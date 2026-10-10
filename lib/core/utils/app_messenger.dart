import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// رسائل سريعة (SnackBar) من أي مكان، حتى بعد إغلاق الصفحة الحالية.
class AppMessenger {
  AppMessenger._();

  static final GlobalKey<ScaffoldMessengerState> key =
      GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    IconData icon = Icons.check_circle_rounded,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = key.currentState;
    if (messenger == null) return;

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 4),
          content: Row(
            children: [
              Icon(icon, color: AppColors.cream, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          action: actionLabel == null
              ? null
              : SnackBarAction(
                  label: actionLabel,
                  textColor: AppColors.accent,
                  onPressed: onAction ?? () {},
                ),
        ),
      );
  }
}
