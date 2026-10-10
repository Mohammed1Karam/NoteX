class AppStrings {
  AppStrings._();

  static const String appName = 'NoteX';
  static const String tagline = 'دوّن أفكارك قبل أن تضيع';

  static const String myNotes = 'ملاحظاتي';
  static const String searchHint = 'ابحث في ملاحظاتك...';
  static const String newNote = 'ملاحظة جديدة';
  static const String editNote = 'تعديل الملاحظة';
  static const String edit = 'تعديل';
  static const String titleHint = 'العنوان';
  static const String contentHint = 'اكتب ملاحظتك هنا...';
  static const String save = 'حفظ';
  static const String delete = 'حذف';
  static const String cancel = 'إلغاء';
  static const String copy = 'نسخ';
  static const String undo = 'تراجع';
  static const String all = 'الكل';
  static const String untitled = 'بدون عنوان';
  static const String gridView = 'عرض شبكي';
  static const String listView = 'عرض قائمة';

  static const String deleteTitle = 'حذف الملاحظة';
  static const String deleteMessage = 'هل أنت متأكد أنك تريد حذف هذه الملاحظة؟';
  static const String noteDeleted = 'تم حذف الملاحظة';
  static const String noteCopied = 'تم نسخ الملاحظة';

  static const String discardTitle = 'تجاهل التغييرات؟';
  static const String discardMessage =
      'لديك تغييرات لم تُحفظ، ستضيع إذا خرجت الآن.';
  static const String discard = 'تجاهل';
  static const String keepEditing = 'متابعة الكتابة';

  static const String emptyTitle = 'لا توجد ملاحظات بعد';
  static const String emptySubtitle =
      'اضغط على «ملاحظة جديدة» وابدأ بتدوين أفكارك';
  static const String startWriting = 'ابدأ أول ملاحظة';
  static const String noResults = 'لم نجد أي نتائج';
  static const String noResultsSubtitle = 'جرّب كلمات مختلفة في البحث';

  static const String emptyNoteError = 'اكتب شيئًا قبل الحفظ';
  static const String saveError = 'تعذّر حفظ الملاحظة، حاول مجددًا';
  static const String loadError = 'حدث خطأ أثناء تحميل الملاحظات';
  static const String loadErrorSubtitle =
      'تأكد من اتصالك بالإنترنت ثم حاول مجددًا';
  static const String retry = 'إعادة المحاولة';

  static const String statNotes = 'ملاحظة';
  static const String statWords = 'كلمة';
  static const String statWeek = 'هذا الأسبوع';
  static const String lastEdit = 'آخر تعديل';
  static const String createdAt = 'أُنشئت';

  // صيغ الجمع العربية: مفرد / مثنى / جمع (3-10) / تمييز مفرد (11+)
  static String _plural(
      int n, String one, String two, String few, String many) {
    if (n == 1) return one;
    if (n == 2) return two;
    if (n >= 3 && n <= 10) return '$n $few';
    return '$n $many';
  }

  static String notesCount(int n) {
    if (n == 0) return 'لا توجد ملاحظات';
    return _plural(n, 'ملاحظة واحدة', 'ملاحظتان', 'ملاحظات', 'ملاحظة');
  }

  static String wordsCount(int n) {
    if (n == 0) return 'لا كلمات';
    return _plural(n, 'كلمة واحدة', 'كلمتان', 'كلمات', 'كلمة');
  }

  static String charsCount(int n) =>
      n == 0 ? '0 حرف' : _plural(n, 'حرف واحد', 'حرفان', 'أحرف', 'حرف');

  static String readingTime(int words) {
    final minutes = (words / 200).ceil();
    if (minutes <= 1) return 'دقيقة قراءة';
    return '${_plural(minutes, 'دقيقة', 'دقيقتان', 'دقائق', 'دقيقة')} قراءة';
  }

  static String minutesAgo(int n) =>
      'منذ ${_plural(n, 'دقيقة', 'دقيقتين', 'دقائق', 'دقيقة')}';

  static String hoursAgo(int n) =>
      'منذ ${_plural(n, 'ساعة', 'ساعتين', 'ساعات', 'ساعة')}';
}
