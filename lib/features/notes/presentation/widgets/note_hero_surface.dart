import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

/// خلفية الملاحظة المشتركة بين البطاقة وصفحة التفاصيل.
/// تنتقل بـ Hero فتتمدّد البطاقة لتصبح الصفحة كاملة مع تنعيم الزوايا تدريجيًا.
class NoteHeroSurface extends StatelessWidget {
  static const double cardRadius = 24;

  final String noteId;
  final Color color;
  final double radius;
  final BoxBorder? border;
  final List<BoxShadow>? shadow;

  const NoteHeroSurface({
    super.key,
    required this.noteId,
    required this.color,
    this.radius = cardRadius,
    this.border,
    this.shadow,
  });

  static String tagFor(String id) => 'note-surface-$id';

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tagFor(noteId),
      // قيمة الأنيميشن: 0 = البطاقة، 1 = الصفحة (بالاتجاهين)
      flightShuttleBuilder: (_, animation, __, ___, ____) => AnimatedBuilder(
        animation: animation,
        builder: (_, __) => DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              lerpDouble(cardRadius, 0, animation.value)!,
            ),
          ),
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: border,
          boxShadow: shadow,
        ),
      ),
    );
  }
}
