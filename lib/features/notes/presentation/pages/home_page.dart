import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/text_stats.dart';
import '../../../../core/widgets/circle_icon_button.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../domain/entities/note.dart';
import '../controllers/notes_controller.dart';
import '../widgets/color_filter_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';
import '../widgets/notes_skeleton.dart';
import 'note_details_page.dart';
import 'note_editor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final NotesController controller = Get.find<NotesController>();
  final TextEditingController _search = TextEditingController();
  bool _fabExtended = true;

  @override
  void initState() {
    super.initState();
    _search.text = controller.query.value;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openEditor() => Get.to(
        () => const NoteEditorPage(),
        transition: Transition.downToUp,
        duration: const Duration(milliseconds: 380),
      );

  void _openNote(Note note) => Get.to(
        () => NoteDetailsPage(noteId: note.id),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 420),
      );

  bool _onScroll(UserScrollNotification n) {
    final extended =
        n.direction != ScrollDirection.reverse || n.metrics.pixels < 40;
    if (n.direction != ScrollDirection.idle && extended != _fabExtended) {
      setState(() => _fabExtended = extended);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightPageOverlay,
      child: Scaffold(
        floatingActionButton: _NewNoteFab(
          extended: _fabExtended,
          onTap: _openEditor,
        ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: _onScroll,
          child: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            edgeOffset: MediaQuery.paddingOf(context).top,
            onRefresh: controller.loadNotes,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: SafeArea(
                    bottom: false,
                    child: Obx(
                      () => _Header(
                        notes: controller.notes.toList(),
                        isGrid: controller.isGrid.value,
                        onToggleView: controller.toggleView,
                      ),
                    ),
                  ),
                ),
                Obx(() {
                  final colors = controller.usedColors;
                  return SliverPersistentHeader(
                    pinned: true,
                    delegate: _SearchHeaderDelegate(
                      search: _search,
                      onChanged: controller.search,
                      filterColors: colors.length > 1 ? colors : const [],
                      selectedColor: controller.colorFilter.value,
                      onColorSelected: controller.toggleColorFilter,
                    ),
                  );
                }),
                Obx(_buildContent),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final status = controller.status.value;

    if ((status == NotesStatus.loading || status == NotesStatus.initial) &&
        controller.notes.isEmpty) {
      return const SliverToBoxAdapter(child: NotesSkeleton());
    }

    if (status == NotesStatus.failure && controller.notes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: EmptyState(
          icon: Icons.cloud_off_rounded,
          title: AppStrings.loadError,
          subtitle: AppStrings.loadErrorSubtitle,
          actionLabel: AppStrings.retry,
          actionIcon: Icons.refresh_rounded,
          onAction: controller.loadNotes,
        ),
      );
    }

    final notes = controller.filteredNotes;
    final filtering = controller.query.value.trim().isNotEmpty ||
        controller.colorFilter.value != null;

    if (notes.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: filtering
            ? const EmptyState(
                icon: Icons.search_off_rounded,
                title: AppStrings.noResults,
                subtitle: AppStrings.noResultsSubtitle,
              )
            : EmptyState(
                icon: Icons.edit_rounded,
                title: AppStrings.emptyTitle,
                subtitle: AppStrings.emptySubtitle,
                actionLabel: AppStrings.startWriting,
                onAction: _openEditor,
              ),
      );
    }

    Widget animated(int index, Widget child, String id) => FadeSlideIn(
          key: ValueKey('anim-$id'),
          delay: Duration(milliseconds: 45 * math.min(index, 10)),
          child: child,
        );

    const padding = EdgeInsets.fromLTRB(20, 6, 20, 110);

    if (!controller.isGrid.value) {
      return SliverPadding(
        padding: padding,
        sliver: SliverList.separated(
          itemCount: notes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => animated(
            i,
            NoteCard(
                note: notes[i], wide: true, onTap: () => _openNote(notes[i])),
            notes[i].id,
          ),
        ),
      );
    }

    // Masonry متوازن: كل ملاحظة تروح للعمود الأقصر حسب طولها التقديري
    final columns = [<Note>[], <Note>[]];
    final heights = [0.0, 0.0];
    for (final n in notes) {
      final target = heights[0] <= heights[1] ? 0 : 1;
      columns[target].add(n);
      heights[target] += _estimateHeight(n);
    }

    var order = 0;
    final indexOf = {for (final n in notes) n.id: order++};

    Widget column(List<Note> items) => Column(
          children: [
            for (final n in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: animated(
                  indexOf[n.id]!,
                  NoteCard(note: n, onTap: () => _openNote(n)),
                  n.id,
                ),
              ),
          ],
        );

    return SliverPadding(
      padding: padding,
      sliver: SliverToBoxAdapter(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: column(columns[0])),
            const SizedBox(width: 12),
            Expanded(child: column(columns[1])),
          ],
        ),
      ),
    );
  }

  static double _estimateHeight(Note n) {
    final titleLines = (n.title.length / 16).ceil().clamp(1, 2);
    final contentLines = n.content.trim().isEmpty
        ? 0
        : math.min(
            7,
            (n.content.length / 22).ceil() + '\n'.allMatches(n.content).length,
          );
    return 70 + titleLines * 22 + contentLines * 22.0;
  }
}

// ───────────────────────────── Header ─────────────────────────────

class _Header extends StatelessWidget {
  final List<Note> notes;
  final bool isGrid;
  final VoidCallback onToggleView;

  const _Header({
    required this.notes,
    required this.isGrid,
    required this.onToggleView,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.full(now),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      DateFormatter.greeting(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              CircleIconButton(
                tooltip: isGrid ? AppStrings.listView : AppStrings.gridView,
                background: AppColors.surface,
                icon: isGrid
                    ? Icons.view_agenda_outlined
                    : Icons.grid_view_rounded,
                onPressed: onToggleView,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SummaryCard(notes: notes),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final List<Note> notes;
  const _SummaryCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final words = notes.fold<int>(
      0,
      (sum, n) => sum + TextStats.words('${n.title} ${n.content}'),
    );
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final thisWeek = notes.where((n) => n.createdAt.isAfter(weekAgo)).length;
    // الملاحظات مرتبة من الأحدث تعديلًا
    final lastEdit = notes.isEmpty ? null : notes.first.updatedAt;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // دوائر زخرفية
          PositionedDirectional(
            end: -40,
            top: -50,
            child: _Circle(size: 160, alpha: 0.07),
          ),
          PositionedDirectional(
            end: 60,
            bottom: -70,
            child: _Circle(size: 120, alpha: 0.05),
          ),
          PositionedDirectional(
            end: 22,
            top: 20,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(
                Icons.auto_stories_rounded,
                size: 46,
                color: AppColors.accent.withValues(alpha: 0.9),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.myNotes,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cream,
                  ),
                ),
                Text(
                  lastEdit == null
                      ? AppStrings.tagline
                      : '${AppStrings.lastEdit} · ${DateFormatter.relative(lastEdit)}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.cream.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Stat(value: notes.length, label: AppStrings.statNotes),
                    const _StatDivider(),
                    _Stat(value: words, label: AppStrings.statWords),
                    const _StatDivider(),
                    _Stat(value: thisWeek, label: AppStrings.statWeek),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double alpha;
  const _Circle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.cream.withValues(alpha: alpha),
        ),
      );
}

class _Stat extends StatelessWidget {
  final int value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              '$v',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.cream,
                height: 1.2,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.cream.withValues(alpha: 0.65),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 34,
        margin: const EdgeInsetsDirectional.only(end: 16),
        color: AppColors.cream.withValues(alpha: 0.15),
      );
}

// ───────────────────────── Search (pinned) ─────────────────────────

class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  static const double _searchHeight = 72;
  static const double _filtersHeight = 48;

  final TextEditingController search;
  final ValueChanged<String> onChanged;
  final List<int> filterColors;
  final int? selectedColor;
  final ValueChanged<int?> onColorSelected;

  _SearchHeaderDelegate({
    required this.search,
    required this.onChanged,
    required this.filterColors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  bool get _hasFilters => filterColors.isNotEmpty;

  @override
  double get minExtent => _searchHeight + (_hasFilters ? _filtersHeight : 0);

  @override
  double get maxExtent => minExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: overlaps
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: _SearchField(controller: search, onChanged: onChanged),
          ),
          if (_hasFilters)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ColorFilterBar(
                colors: filterColors,
                selected: selectedColor,
                onSelected: onColorSelected,
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchHeaderDelegate old) =>
      old.selectedColor != selectedColor ||
      old.filterColors.length != filterColors.length ||
      !old.filterColors.every(filterColors.contains);
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return SizedBox(
      height: 52,
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (_, value, __) => TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          style: const TextStyle(fontSize: 14.5),
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary,
            ),
            suffixIcon: value.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppColors.textSecondary,
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.zero,
            enabledBorder: border,
            border: border,
            focusedBorder: border.copyWith(
              borderSide:
                  const BorderSide(color: AppColors.primaryLight, width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── FAB ───────────────────────────────

class _NewNoteFab extends StatelessWidget {
  final bool extended;
  final VoidCallback onTap;

  const _NewNoteFab({required this.extended, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: extended ? 20 : 17,
                vertical: 17,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: AppColors.cream),
                  if (extended) ...[
                    const SizedBox(width: 8),
                    const Text(
                      AppStrings.newNote,
                      style: TextStyle(
                        color: AppColors.cream,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
