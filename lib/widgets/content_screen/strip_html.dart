/// A neat function that removes any html tag from text.
/// It also replease a line break with a new line
String stripHtmlIfNeeded(String text) {
  return text
      .replaceAll(RegExp(r'<br>'), '\n')
      .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
}
