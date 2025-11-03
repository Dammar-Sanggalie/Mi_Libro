import 'package:intl/intl.dart';

// Enhanced OOP Implementation
class Book {
  String _title;
  String _author;
  int _year;
  String _category;
  String _description;

  Book(
    this._title,
    this._author,
    this._year,
    this._category,
    this._description,
  );

  // Getters with validation
  String get title => _title;
  String get author => _author;
  int get year => _year;
  String get category => _category;
  String get description => _description;

  // Enhanced setters with validation
  set title(String title) {
    if (title.isNotEmpty) _title = title;
  }

  set author(String author) {
    if (author.isNotEmpty) _author = author;
  }

  set year(int year) {
    if (year > 1000 && year <= DateTime.now().year) _year = year;
  }

  set category(String category) {
    if (category.isNotEmpty) _category = category;
  }

  set description(String description) {
    if (description.isNotEmpty) _description = description;
  }

  // Polymorphism - Base method
  String displayInfo() {
    return '$_title by $_author ($_year)';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': _title,
      'author': _author,
      'year': _year,
      'category': _category,
      'description': _description,
    };
  }
}

// Enhanced Inheritance
class DigitalBook extends Book {
  String _fileSize;
  String _format;
  String _imageUrl;
  String _pdfUrl;
  double _rating;
  int _downloads;

  DigitalBook(
    String title,
    String author,
    int year,
    String category,
    String description,
    this._fileSize,
    this._format,
    this._imageUrl,
    this._pdfUrl, {
    double rating = 4.0,
    int downloads = 0,
  })  : _rating = rating,
        _downloads = downloads,
        super(title, author, year, category, description);

  // Enhanced getters
  String get fileSize => _fileSize;
  String get format => _format;
  String get imageUrl => _imageUrl;
  String get pdfUrl => _pdfUrl;
  double get rating => _rating;
  int get downloads => _downloads;

  // Enhanced setters
  set fileSize(String size) {
    if (size.isNotEmpty) _fileSize = size;
  }

  set format(String format) {
    if (format.isNotEmpty) _format = format;
  }

  set imageUrl(String url) {
    if (url.isNotEmpty) _imageUrl = url;
  }

  set pdfUrl(String url) {
    if (url.isNotEmpty) _pdfUrl = url;
  }

  set rating(double rating) {
    if (rating >= 0 && rating <= 5) _rating = rating;
  }

  set downloads(int downloads) {
    if (downloads >= 0) _downloads = downloads;
  }

  // Enhanced Polymorphism
  @override
  String displayInfo() {
    return '${super.displayInfo()} - $_format ($_fileSize) • ${_rating.toStringAsFixed(1)}⭐';
  }

  // Updated method using intl package for Indonesian number formatting
  String getFormattedDownloads() {
    return NumberFormat.compact(locale: 'id_ID').format(_downloads);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'fileSize': _fileSize,
      'format': _format,
      'imageUrl': _imageUrl,
      'pdfUrl': _pdfUrl,
      'rating': _rating,
      'downloads': _downloads,
    };
  }
}
