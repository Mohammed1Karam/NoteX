import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_messenger.dart';
import '../../../../core/utils/text_stats.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../../../../core/widgets/confirm_sheet.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/color_picker_row.dart';

class NoteEditorPage extends StatefulWidget {
  final Note? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final NotesController _controller = Get.find<NotesController>();

  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final int _initialColor;
  late int _colorIndex;
  bool _saving = false;

  bool get _isEdit => widget.note != null;

  bool get _hasChanges {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (!_isEdit) return title.isNotEmpty || content.isNotEmpty;
    return title != widget.note!.title.trim() ||
        content != widget.note!.content.trim() ||
        _colorIndex != _initialColor;
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController =
        TextEditingController(text: widget.note?.content ?? '');
    _initialColor = widget.note?.colorIndex ?? 1;
    _colorIndex = _initialColor;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      AppMessenger.show(
        AppStrings.emptyNoteError,
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await _controller.updateNote(
          widget.note!.copyWith(
            title: title,
            content: content,
            colorIndex: _colorIndex,
          ),
        );
      } else {
        await _controller.addNote(
          title: title,
          content: content,
          colorIndex: _colorIndex,
        );
      }
    } catch (_) {
      if (mounted) setState(() => _saving = false);
      AppMessenger.show(AppStrings.saveError,
          icon: Icons.error_outline_rounded);
      return;
    }

    Get.back();
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    if (_saving) return;
    final leave = !_hasChanges ||
        await showConfirmSheet(
          icon: Icons.edit_off_rounded,
          title: AppStrings.discardTitle,
          message: AppStrings.discardMessage,
          confirmLabel: AppStrings.discard,
          cancelLabel: AppStrings.keepEditing,
        );
    if (leave && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.noteAccent(_colorIndex);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightPageOverlay,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          color: AppColors.noteColor(_colorIndex),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    title: _isEdit ? AppStrings.editNote : AppStrings.newNote,
                    saving: _saving,
                    onClose: () => Navigator.maybePop(context),
                    onSave: _save,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            autofocus: !_isEdit,
                            textInputAction: TextInputAction.next,
                            maxLines: null,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: AppStrings.titleHint,
                              hintStyle: TextStyle(color: AppColors.hint),
                            ),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 44,
                              height: 4,
                              decoration: BoxDecoration(
                                color: accent,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _contentController,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              keyboardType: TextInputType.multiline,
                              style: TextStyle(
                                fontSize: 16.5,
                                height: 1.9,
                                color: AppColors.textPrimary
                                    .withValues(alpha: 0.88),
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: AppStrings.contentHint,
                                hintStyle: TextStyle(color: AppColors.hint),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _Toolbar(
                    colorIndex: _colorIndex,
                    onColorChanged: (i) => setState(() => _colorIndex = i),
                    text: Listenable.merge(
                        [_titleController, _contentController]),
                    stats: () =>
                        '${_titleController.text} ${_contentController.text}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final bool saving;
  final VoidCallback onClose;
  final VoidCallback onSave;

  const _TopBar({
    required this.title,
    required this.saving,
    required this.onClose,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          CircleIconButton(icon: Icons.close_rounded, onPressed: onClose),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: saving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.7),
              foregroundColor: AppColors.cream,
              minimumSize: const Size(96, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: saving
                  ? const SizedBox(
                      key: ValueKey('saving'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: AppColors.cream,
                      ),
                    )
                  : const Row(
                      key: ValueKey('save'),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_rounded, size: 19),
                        SizedBox(width: 6),
                        Text(
                          AppStrings.save,
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// شريط سفلي عائم: اختيار اللون + عدّاد الكلمات والأحرف.
class _Toolbar extends StatelessWidget {
  final int colorIndex;
  final ValueChanged<int> onColorChanged;
  final Listenable text;
  final String Function() stats;

  const _Toolbar({
    required this.colorIndex,
    required this.onColorChanged,
    required this.text,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: AppColors.softShadow(AppColors.noteAccent(colorIndex)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                size: 17,
                color: AppColors.noteAccent(colorIndex),
              ),
              const SizedBox(width: 6),
              Text(
                AppColors.noteColorNames[colorIndex],
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: text,
                builder: (_, __) {
                  final value = stats();
                  return Text(
                    '${AppStrings.wordsCount(TextStats.words(value))} · '
                    '${AppStrings.charsCount(TextStats.chars(value))}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.hint,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          ColorPickerRow(
            selectedIndex: colorIndex,
            onChanged: onColorChanged,
          ),
        ],
      ),
    );
  }
}
