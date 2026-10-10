import '../constants/app_strings.dart';

class DateFormatter {
  DateFormatter._();

  static const List<String> _months = [
    'كانون الثاني',
    'شباط',
    'آذار',
    'نيسان',
    'أيار',
    'حزيران',
    'تموز',
    'آب',
    'أيلول',
    'تشرين الأول',
    'تشرين الثاني',
    'كانون الأول',
  ];

  // DateTime.weekday: 1 = الاثنين ... 7 = الأحد
  static const List<String> _weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String format(DateTime date) {
    final base = '${date.day} ${_months[date.month - 1]}';
    return date.year == DateTime.now().year ? base : '$base ${date.year}';
  }

  /// مثال: الجمعة، 2 تشرين الأول
  static String full(DateTime date) =>
      '${_weekdays[date.weekday - 1]}، ${format(date)}';

  /// مثال: 4:05 م
  static String time(DateTime date) {
    final h = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m ${date.hour < 12 ? 'ص' : 'م'}';
  }

  /// وقت نسبي قصير: الآن، منذ 5 دقائق، أمس، الثلاثاء، 3 آب
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return AppStrings.minutesAgo(diff.inMinutes);

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final days = today.difference(day).inDays;
    if (days == 0) return AppStrings.hoursAgo(diff.inHours);
    if (days == 1) return 'أمس';
    if (days < 7) return _weekdays[date.weekday - 1];
    return format(date);
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'صباح الخير';
    if (hour >= 12 && hour < 18) return 'نهارك سعيد';
    return 'مساء الخير';
  }
}
