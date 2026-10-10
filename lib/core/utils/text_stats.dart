class TextStats {
  TextStats._();

  static final RegExp _whitespace = RegExp(r'\s+');

  static int words(String text) {
    final t = text.trim();
    return t.isEmpty ? 0 : t.split(_whitespace).length;
  }

  static int chars(String text) => text.trim().runes.length;
}
