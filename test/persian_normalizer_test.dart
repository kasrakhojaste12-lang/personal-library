import 'package:flutter_test/flutter_test.dart';
import 'package:library_manager/core/utils/persian_normalizer.dart';

void main() {
  group('PersianNormalizer Unit Tests', () {
    test('normalizes Arabic Yeh (ي) and Alef Maksura (ى) to Persian Yeh (ی)', () {
      expect(PersianNormalizer.normalize('على'), equals('علی'));
      expect(PersianNormalizer.normalize('موسى'), equals('موسی'));
      expect(PersianNormalizer.normalize('كيميا'), equals('کیمیا'));
    });

    test('normalizes Arabic Kaf (ك) to Persian Kaf (ک)', () {
      expect(PersianNormalizer.normalize('كتاب'), equals('کتاب'));
      expect(PersianNormalizer.normalize('بانك'), equals('بانک'));
    });

    test('normalizes Alef variants (أ, إ, آ, ٱ) to standard Alef (ا)', () {
      expect(PersianNormalizer.normalize('آموزش'), equals('اموزش'));
      expect(PersianNormalizer.normalize('اسلام'), equals('اسلام'));
      expect(PersianNormalizer.normalize('أحمد'), equals('احمد'));
      expect(PersianNormalizer.normalize('إيران'), equals('ایران'));
    });

    test('removes Arabic and Persian diacritics (Harakat / Tashkeel)', () {
      // Fatha, Damma, Kasra, Tanwin, Shaddah, Sukun
      const withDiacritics = 'حافِظِ شِیرازِیٌّ';
      expect(PersianNormalizer.normalize(withDiacritics), equals('حافظ شیرازی'));
    });

    test('removes Tatweel / Kashida (ـ)', () {
      expect(PersianNormalizer.normalize('کـــتـــاب'), equals('کتاب'));
    });

    test('handles Zero-Width Non-Joiner (ZWNJ)', () {
      expect(PersianNormalizer.normalize('کتاب\u200Cخانه'), equals('کتاب خانه'));
    });

    test('normalizes Persian and Arabic numerals to standard digits', () {
      expect(PersianNormalizer.normalize('۱۳۹۹'), equals('1399'));
      expect(PersianNormalizer.normalize('١٤٠٢'), equals('1402'));
    });

    test('performs English case-folding', () {
      expect(PersianNormalizer.normalize('Clean Code by Robert Martin'),
          equals('clean code by robert martin'));
    });

    test('collapses multiple whitespace characters and trims', () {
      expect(PersianNormalizer.normalize('   کتاب    روانشناسی   '), equals('کتاب روانشناسی'));
    });

    test('normalizes ISBN strings correctly', () {
      expect(
        PersianNormalizer.normalizeIsbn('978-3-16-148410-0'),
        equals('9783161484100'),
      );
      expect(
        PersianNormalizer.normalizeIsbn('  978 0 13 235088 4 '),
        equals('9780132350884'),
      );
      expect(
        PersianNormalizer.normalizeIsbn('isbn-978-X'),
        equals('ISBN978X'),
      );
    });
  });
}
