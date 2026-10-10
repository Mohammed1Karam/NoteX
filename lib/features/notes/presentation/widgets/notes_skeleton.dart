import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// هيكل تحميل نابض بشكل بطاقات الملاحظات.
class NotesSkeleton extends StatefulWidget {
  const NotesSkeleton({super.key});

  @override
  State<NotesSkeleton> createState() => _NotesSkeletonState();
}

class _NotesSkeletonState extends State<NotesSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget card(double height) => Container(
          height: height,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(24),
          ),
        );

    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(children: [card(170), card(120), card(150)])),
            const SizedBox(width: 12),
            Expanded(
                child: Column(children: [card(120), card(190), card(110)])),
          ],
        ),
      ),
    );
  }
}
