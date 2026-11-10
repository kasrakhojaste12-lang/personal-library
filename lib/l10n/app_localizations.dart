import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  String get appTitle;
  String get library;
  String get addBook;
  String get editBook;
  String get bookDetails;
  String get settings;
  String get searchPlaceholder;
  String get sortBy;
  String get sortTitleAsc;
  String get sortTitleDesc;
  String get sortDateDesc;
  String get sortDateAsc;
  String get title;
  String get author;
  String get publisher;
  String get publicationYear;
  String get isbn;
  String get category;
  String get notes;
  String get quantity;
  String get createdAt;
  String get updatedAt;
  String get optional;
  String get required;
  String get titleRequired;
  String get authorRequired;
  String get quantityMinError;
  String get invalidYearError;
  String get bookSaved;
  String get bookDeleted;
  String get deleteBook;
  String deleteConfirmation(String title);
  String get cancel;
  String get delete;
  String get save;
  String get edit;
  String get emptyLibraryTitle;
  String get emptyLibrarySubtitle;
  String get addFirstBook;
  String get noResultsTitle;
  String get noResultsSubtitle;
  String get clearSearch;
  String get appearance;
  String get theme;
  String get systemTheme;
  String get lightTheme;
  String get darkTheme;
  String get language;
  String get english;
  String get persian;
  String get backupAndRestore;
  String get exportBackup;
  String get exportSubtitle;
  String get importBackup;
  String get importSubtitle;
  String get importDialogTitle;
  String importDialogDescription(int count);
  String get mergeOptionTitle;
  String get mergeOptionSubtitle;
  String get replaceOptionTitle;
  String get replaceOptionSubtitle;
  String get importSummaryTitle;
  String importSummaryMessage(int imported, int skipped);
  String get exportSuccess;
  String get errorOccurred;
  String get unknownCategory;
  String totalBooks(int count);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    default:
      return AppLocalizationsEn();
  }
}

/// English translations
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Library';
  @override
  String get library => 'Library';
  @override
  String get addBook => 'Add Book';
  @override
  String get editBook => 'Edit Book';
  @override
  String get bookDetails => 'Book Details';
  @override
  String get settings => 'Settings';
  @override
  String get searchPlaceholder => 'Search by title, author, ISBN...';
  @override
  String get sortBy => 'Sort by';
  @override
  String get sortTitleAsc => 'Title (A → Z)';
  @override
  String get sortTitleDesc => 'Title (Z → A)';
  @override
  String get sortDateDesc => 'Date Added (Newest)';
  @override
  String get sortDateAsc => 'Date Added (Oldest)';
  @override
  String get title => 'Title';
  @override
  String get author => 'Author';
  @override
  String get publisher => 'Publisher';
  @override
  String get publicationYear => 'Publication Year';
  @override
  String get isbn => 'ISBN';
  @override
  String get category => 'Category / Genre';
  @override
  String get notes => 'Notes';
  @override
  String get quantity => 'Quantity';
  @override
  String get createdAt => 'Added on';
  @override
  String get updatedAt => 'Updated on';
  @override
  String get optional => 'Optional';
  @override
  String get required => 'Required';
  @override
  String get titleRequired => 'Please enter a title';
  @override
  String get authorRequired => 'Please enter an author';
  @override
  String get quantityMinError => 'Quantity must be at least 1';
  @override
  String get invalidYearError => 'Please enter a valid 4-digit year';
  @override
  String get bookSaved => 'Book saved successfully';
  @override
  String get bookDeleted => 'Book deleted successfully';
  @override
  String get deleteBook => 'Delete Book';
  @override
  String deleteConfirmation(String title) => 'Are you sure you want to delete "$title"?';
  @override
  String get cancel => 'Cancel';
  @override
  String get delete => 'Delete';
  @override
  String get save => 'Save';
  @override
  String get edit => 'Edit';
  @override
  String get emptyLibraryTitle => 'Your library is empty';
  @override
  String get emptyLibrarySubtitle => 'Start building your offline collection by adding your first book.';
  @override
  String get addFirstBook => 'Add Your First Book';
  @override
  String get noResultsTitle => 'No books found';
  @override
  String get noResultsSubtitle => 'No books matched your search query. Try different keywords.';
  @override
  String get clearSearch => 'Clear Search';
  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get systemTheme => 'System Default';
  @override
  String get lightTheme => 'Light';
  @override
  String get darkTheme => 'Dark';
  @override
  String get language => 'Language';
  @override
  String get english => 'English';
  @override
  String get persian => 'فارسی (Persian)';
  @override
  String get backupAndRestore => 'Backup & Restore';
  @override
  String get exportBackup => 'Export Backup';
  @override
  String get exportSubtitle => 'Save or share your library as a single JSON file';
  @override
  String get importBackup => 'Import Backup';
  @override
  String get importSubtitle => 'Restore books from a JSON backup file';
  @override
  String get importDialogTitle => 'Import Backup';
  @override
  String importDialogDescription(int count) => 'Choose how you want to restore the $count books from the backup file:';
  @override
  String get mergeOptionTitle => 'Merge with existing data';
  @override
  String get mergeOptionSubtitle => 'Adds new books while automatically skipping exact duplicates.';
  @override
  String get replaceOptionTitle => 'Replace all existing data';
  @override
  String get replaceOptionSubtitle => 'Wipes your current library and restores the backup books.';
  @override
  String get importSummaryTitle => 'Import Completed';
  @override
  String importSummaryMessage(int imported, int skipped) => '$imported books imported, $skipped skipped.';
  @override
  String get exportSuccess => 'Backup exported successfully.';
  @override
  String get errorOccurred => 'An error occurred';
  @override
  String get unknownCategory => 'General';
  @override
  String totalBooks(int count) => '$count books in library';
}

/// Persian translations
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'کتابخانه شخصی';
  @override
  String get library => 'کتابخانه';
  @override
  String get addBook => 'افزودن کتاب';
  @override
  String get editBook => 'ویرایش کتاب';
  @override
  String get bookDetails => 'مشخصات کتاب';
  @override
  String get settings => 'تنظیمات';
  @override
  String get searchPlaceholder => 'جستجو بر اساس عنوان، نویسنده، شابک...';
  @override
  String get sortBy => 'مرتب‌سازی بر اساس';
  @override
  String get sortTitleAsc => 'عنوان (الف تا ی)';
  @override
  String get sortTitleDesc => 'عنوان (ی تا الف)';
  @override
  String get sortDateDesc => 'تاریخ افزودن (جدیدترین)';
  @override
  String get sortDateAsc => 'تاریخ افزودن (قدیمی‌ترین)';
  @override
  String get title => 'عنوان';
  @override
  String get author => 'نویسنده';
  @override
  String get publisher => 'ناشر';
  @override
  String get publicationYear => 'سال انتشار';
  @override
  String get isbn => 'شابک (ISBN)';
  @override
  String get category => 'دسته‌بندی / موضوع';
  @override
  String get notes => 'یادداشت‌ها';
  @override
  String get quantity => 'تعداد موجودی';
  @override
  String get createdAt => 'تاریخ ثبت';
  @override
  String get updatedAt => 'آخرین ویرایش';
  @override
  String get optional => 'اختیاری';
  @override
  String get required => 'الزامی';
  @override
  String get titleRequired => 'لطفاً عنوان کتاب را وارد کنید';
  @override
  String get authorRequired => 'لطفاً نام نویسنده را وارد کنید';
  @override
  String get quantityMinError => 'تعداد موجودی باید حداقل ۱ باشد';
  @override
  String get invalidYearError => 'لطفاً سال انتشار معتبر (۴ رقمی) وارد کنید';
  @override
  String get bookSaved => 'کتاب با موفقیت ذخیره شد';
  @override
  String get bookDeleted => 'کتاب با موفقیت حذف شد';
  @override
  String get deleteBook => 'حذف کتاب';
  @override
  String deleteConfirmation(String title) => 'آیا از حذف کتاب «$title» اطمینان دارید؟';
  @override
  String get cancel => 'انصراف';
  @override
  String get delete => 'حذف';
  @override
  String get save => 'ذخیره';
  @override
  String get edit => 'ویرایش';
  @override
  String get emptyLibraryTitle => 'کتابخانه شما خالی است';
  @override
  String get emptyLibrarySubtitle => 'با افزودن اولین کتاب، مدیریت آفلاین مجموعه خود را آغاز کنید.';
  @override
  String get addFirstBook => 'افزودن اولین کتاب';
  @override
  String get noResultsTitle => 'کتابی یافت نشد';
  @override
  String get noResultsSubtitle => 'هیچ کتابی با عبارت جستجوی شما پیدا نشد. کلمات دیگری را امتحان کنید.';
  @override
  String get clearSearch => 'پاک کردن جستجو';
  @override
  String get appearance => 'ظاهر برنامه';
  @override
  String get theme => 'پوسته';
  @override
  String get systemTheme => 'پیش‌فرض سیستم';
  @override
  String get lightTheme => 'روشن';
  @override
  String get darkTheme => 'تیره';
  @override
  String get language => 'زبان برنامه';
  @override
  String get english => 'English (انگلیسی)';
  @override
  String get persian => 'فارسی';
  @override
  String get backupAndRestore => 'پشتیبان‌گیری و بازیابی';
  @override
  String get exportBackup => 'تهیه فایل پشتیبان JSON';
  @override
  String get exportSubtitle => 'ذخیره یا اشتراک‌گذاری تمام اطلاعات کتابخانه در یک فایل JSON';
  @override
  String get importBackup => 'بازیابی فایل پشتیبان JSON';
  @override
  String get importSubtitle => 'بازگردانی کتاب‌ها از فایل پشتیبان JSON قبلی';
  @override
  String get importDialogTitle => 'بازیابی اطلاعات کتاب‌ها';
  @override
  String importDialogDescription(int count) => 'روش بازیابی $count کتاب موجود در فایل پشتیبان را مشخص کنید:';
  @override
  String get mergeOptionTitle => 'ادغام با داده‌های فعلی';
  @override
  String get mergeOptionSubtitle => 'کتاب‌های جدید اضافه شده و موارد تکراری نادیده گرفته می‌شوند.';
  @override
  String get replaceOptionTitle => 'جایگزینی کامل داده‌ها';
  @override
  String get replaceOptionSubtitle => 'تمام کتاب‌های فعلی حذف شده و کتاب‌های فایل پشتیبان جایگزین می‌شوند.';
  @override
  String get importSummaryTitle => 'عملیات بازیابی انجام شد';
  @override
  String importSummaryMessage(int imported, int skipped) => '$imported کتاب وارد شد، $skipped مورد تکراری رد شد.';
  @override
  String get exportSuccess => 'فایل پشتیبان با موفقیت تهیه شد.';
  @override
  String get errorOccurred => 'خطایی رخ داده است';
  @override
  String get unknownCategory => 'عمومی';
  @override
  String totalBooks(int count) => '$count کتاب در کتابخانه';
}
