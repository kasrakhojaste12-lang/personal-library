/// Utility class for normalizing Persian and Arabic text as well as ISBN strings.
///
/// Ensures search queries and stored records match accurately regardless of:
/// - Arabic vs. Persian keyboard input (e.g. ي -> ی, ك -> ک)
/// - Arabic/Persian diacritics (Fatha, Damma, Kasra, Tanwin, Shaddah, Sukun)
/// - Alef variations (أ, إ, آ, ٱ -> ا)
/// - Tatweel / Kashida
/// - Zero-width non-joiner (ZWNJ) and invisible characters
/// - Persian/Arabic numeral vs Latin numeral differences
/// - Case differences in English text
class PersianNormalizer {
  PersianNormalizer._();

  static final RegExp _diacriticsRegex = RegExp(
    r'[\u064B-\u065F\u0610-\u061A\u06D6-\u06ED]',
  );

  static final RegExp _whitespaceRegex = RegExp(r'\s+');

  /// Normalizes general text (title, author, genre, etc.).
  static String normalize(String? input) {
    if (input == null || input.isEmpty) {
      return '';
    }

    var text = input.trim().toLowerCase();

    // Remove diacritics (harakat / tashkeel)
    text = text.replaceAll(_diacriticsRegex, '');

    // Remove Tatweel (Kashida)
    text = text.replaceAll('\u0640', '');

    // Remove invisible formatting characters (except treat ZWNJ as space or remove)
    text = text.replaceAll('\u200E', ''); // LRM
    text = text.replaceAll('\u200F', ''); // RLM
    text = text.replaceAll('\u200D', ''); // ZWJ
    text = text.replaceAll('\u200C', ' '); // ZWNJ replaced with space for word matching

    // Normalize Persian/Arabic letters
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final char = text[i];
      switch (char) {
        // Arabic Yeh variants to Persian Yeh
        case '\u064A': // Arabic Yeh
        case '\u0649': // Alef Maksura
        case '\u06D2': // Urdu Yeh
        case '\u0626': // Yeh with Hamza
          buffer.write('ی');
          break;

        // Arabic Kaf to Persian Kaf
        case '\u0643': // Arabic Kaf
        case '\u06AA': // Swash Kaf
          buffer.write('ک');
          break;

        // Alef variants to plain Alef
        case '\u0622': // Alef with Madda
        case '\u0623': // Alef with Hamza above
        case '\u0625': // Alef with Hamza below
        case '\u0671': // Alef Wasla
          buffer.write('ا');
          break;

        // Heh variants
        case '\u0629': // Teh Marbuta
        case '\u06C0': // Heh with Yeh above
        case '\u06D5': // Ae
          buffer.write('ه');
          break;

        // Waw with Hamza
        case '\u0624':
          buffer.write('و');
          break;

        // Persian digits to Latin digits
        case '۰':
          buffer.write('0');
          break;
        case '۱':
          buffer.write('1');
          break;
        case '۲':
          buffer.write('2');
          break;
        case '۳':
          buffer.write('3');
          break;
        case '۴':
          buffer.write('4');
          break;
        case '۵':
          buffer.write('5');
          break;
        case '۶':
          buffer.write('6');
          break;
        case '۷':
          buffer.write('7');
          break;
        case '۸':
          buffer.write('8');
          break;
        case '۹':
          buffer.write('9');
          break;

        // Arabic digits to Latin digits
        case '٠':
          buffer.write('0');
          break;
        case '١':
          buffer.write('1');
          break;
        case '٢':
          buffer.write('2');
          break;
        case '٣':
          buffer.write('3');
          break;
        case '٤':
          buffer.write('4');
          break;
        case '٥':
          buffer.write('5');
          break;
        case '٦':
          buffer.write('6');
          break;
        case '٧':
          buffer.write('7');
          break;
        case '٨':
          buffer.write('8');
          break;
        case '٩':
          buffer.write('9');
          break;

        default:
          buffer.write(char);
      }
    }

    // Collapse repeated whitespaces and trim
    return buffer.toString().replaceAll(_whitespaceRegex, ' ').trim();
  }

  /// Normalizes an ISBN string by stripping hyphens, spaces, and converting digits.
  static String normalizeIsbn(String? isbn) {
    if (isbn == null || isbn.isEmpty) {
      return '';
    }
    final normalized = normalize(isbn);
    // Remove all non-alphanumeric characters (hyphens, spaces)
    return normalized.replaceAll(RegExp(r'[^0-9a-zA-Z]'), '').toUpperCase();
  }
}
