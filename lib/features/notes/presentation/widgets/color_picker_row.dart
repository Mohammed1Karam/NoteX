import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class ColorPickerRow extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ColorPickerRow({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.noteColors;

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (_, i) {
          final selected = i == selectedIndex;
          final accent = AppColors.noteAccent(i);
          return Tooltip(
            message: AppColors.noteColorNames[i],
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: 38,
                height: 38,
                padding: EdgeInsets.all(selected ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? accent : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                  child: AnimatedScale(
                    scale: selected ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.check_rounded, size: 16, color: accent),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
