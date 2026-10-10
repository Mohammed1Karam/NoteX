import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // الأساسيات: ورق دافئ + أخضر غامق (حبر) + لمسة تيراكوتا
  static const Color background = Color(0xFFF7F3EC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF1F4E4A);
  static const Color primaryLight = Color(0xFF2F6E68);
  static const Color primaryDark = Color(0xFF143633);
  static const Color accent = Color(0xFFE07A4F);
  static const Color cream = Color(0xFFFBF6EC);

  // النصوص
  static const Color textPrimary = Color(0xFF1D2B29);
  static const Color textSecondary = Color(0xFF6B7773);
  static const Color hint = Color(0xFF9AA5A1);

  // أخرى
  static const Color border = Color(0xFFE6DFD3);
  static const Color danger = Color(0xFFC8553D);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [primaryLight, primary, primaryDark],
  );

  static List<BoxShadow> softShadow([Color color = primary]) => [
        BoxShadow(
          color: color.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];

  // ألوان الملاحظات (باستيل هادئ)
  static const List<Color> noteColors = [
    Color(0xFFFFFFFF), // أبيض
    Color(0xFFFBE8C8), // زبدة
    Color(0xFFDCEBDD), // مريمية
    Color(0xFFF6D5C8), // طين
    Color(0xFFD6E6EE), // ضباب أزرق
    Color(0xFFEADFF0), // خزامى
    Color(0xFFF3E1E1), // وردي ترابي
  ];

  // درجة أغمق لكل لون ملاحظة (للنقاط والشرائط والتفاصيل)
  static const List<Color> noteAccents = [
    Color(0xFF8A9A95),
    Color(0xFFD9A441),
    Color(0xFF5E9A6B),
    Color(0xFFD2774F),
    Color(0xFF4F87A6),
    Color(0xFF8E6BAE),
    Color(0xFFC0686F),
  ];

  static const List<String> noteColorNames = [
    'أبيض',
    'زبدة',
    'مريمية',
    'طين',
    'ضباب',
    'خزامى',
    'ورد',
  ];

  static Color noteColor(int index) => noteColors[index % noteColors.length];
  static Color noteAccent(int index) => noteAccents[index % noteAccents.length];
}
