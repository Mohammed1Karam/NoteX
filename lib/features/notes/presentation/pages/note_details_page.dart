import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_messenger.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/text_stats.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/note_hero_surface.dart';
import 'note_editor_page.dart';

class NoteDetailsPage extends GetView<NotesController> {
  final String noteId;
  const NoteDetailsPage({super.key, required this.noteId});

  Future<void> _delete(Note note) async {
    final confirmed = await showConfirmSheet(
      icon: Icons.delete_outline_rounded,
      title: AppStrings.deleteTitle,
      message: AppStrings.deleteMessage,
      confirmLabel: AppStrings.delete,
    );
    if (!confirmed) return;

    Get.back();
    await controller.deleteNote(note.id);
    AppMessenger.show(
      AppStrings.noteDeleted,
      icon: Icons.delete_outline_rounded,
      actionLabel: AppStrings.undo,
      onAction: () => controller.restoreNote(note),
    );
  }

  void _copy(Note note) {
    final text = [note.title.trim(), note.content.trim()]
        .where((s) => s.isNotEmpty)
        .join('\n\n');
    Clipboard.setData(ClipboardData(text: text));
    AppMessenger.show(AppStrings.noteCopied, icon: Icons.copy_rounded);
  }

  void _edit(Note note) => Get.to(
        () => NoteEditorPage(note: note),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 380),
      );

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final matches = controller.notes.where((n) => n.id == noteId);
      if (matches.isEmpty) {
        return const Scaffold(backgroundColor: AppColors.background);
      }

      final note = matches.first;
      final color = AppColors.noteColor(note.colorIndex);
      final accent = AppColors.noteAccent(note.colorIndex);
      final hasTitle = note.title.trim().isNotEmpty;
      final words = TextStats.words('${note.title} ${note.content}');

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: AppTheme.lightPageOverlay,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _edit(note),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.cream,
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            icon: const Icon(Icons.edit_rounded, size: 20),
            label: const Text(
              AppStrings.edit,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child:
                    NoteHeroSurface(noteId: note.id, color: color, radius: 0),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onPressed: Get.back,
                          ),
                          const Spacer(),
                          CircleIconButton(
                            tooltip: AppStrings.copy,
                            icon: Icons.copy_rounded,
                            onPressed: () => _copy(note),
                          ),
                          const SizedBox(width: 10),
                          CircleIconButton(
                            tooltip: AppStrings.delete,
                            icon: Icons.delete_outline_rounded,
                            color: AppColors.danger,
                            onPressed: () => _delete(note),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 120),
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 160),
                          offsetY: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasTitle ? note.title : AppStrings.untitled,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.35,
                                  color: hasTitle
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _MetaChip(
                                    icon: Icons.event_rounded,
                                    label: DateFormatter.full(note.createdAt),
                                    accent: accent,
                                  ),
                                  _MetaChip(
                                    icon: Icons.history_rounded,
                                    label:
                                        DateFormatter.relative(note.updatedAt),
                                    accent: accent,
                                  ),
                                  _MetaChip(
                                    icon: Icons.notes_rounded,
                                    label: AppStrings.wordsCount(words),
                                    accent: accent,
                                  ),
                                  _MetaChip(
                                    icon: Icons.timer_outlined,
                                    label: AppStrings.readingTime(words),
                                    accent: accent,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Container(
                                width: 44,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: accent,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 22),
                              SelectableText(
                                note.content,
                                style: TextStyle(
                                  fontSize: 16.5,
                                  height: 1.95,
                                  color: AppColors.textPrimary
                                      .withValues(alpha: 0.88),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
