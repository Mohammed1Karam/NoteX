import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/note.dart';
import 'note_hero_surface.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;

  /// true: بطاقة عريضة لعرض القائمة، false: بطاقة الشبكة
  final bool wide;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.wide = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.noteColor(note.colorIndex);
    final accent = AppColors.noteAccent(note.colorIndex);
    final hasTitle = note.title.trim().isNotEmpty;
    final hasContent = note.content.trim().isNotEmpty;
    final radius = BorderRadius.circular(NoteHeroSurface.cardRadius);

    return Stack(
      children: [
        Positioned.fill(
          child: NoteHeroSurface(
            noteId: note.id,
            color: color,
            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            shadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        // شريط لوني جانبي رفيع يعطي هوية لكل ملاحظة
        PositionedDirectional(
          start: 0,
          top: 22,
          child: Container(
            width: 4,
            height: wide ? 34 : 26,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadiusDirectional.horizontal(
                end: Radius.circular(4),
              ).resolve(Directionality.of(context)),
            ),
          ),
        ),
        Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            splashColor: accent.withValues(alpha: 0.12),
            highlightColor: accent.withValues(alpha: 0.06),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasTitle ? note.title : AppStrings.untitled,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: wide ? 17 : 16,
                      fontWeight: FontWeight.w800,
                      height: 1.4,
                      color: hasTitle
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (hasContent) ...[
                    const SizedBox(height: 6),
                    Text(
                      note.content,
                      maxLines: wide ? 3 : 7,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.65,
                        color: AppColors.textPrimary.withValues(alpha: 0.68),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 13, color: accent),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          DateFormatter.relative(note.updatedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
