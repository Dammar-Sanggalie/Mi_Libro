// lib/models/book_model.dart

import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

// Enhanced OOP Implementation
class Book extends Equatable {
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

  // Getters
  String get title => _title;
  String get author => _author;
  int get year => _year;
  String get category => _category;
  String get description => _description;

  // Setters
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

  @override
  List<Object?> get props => [title, author, year, category, description];
}

// Enhanced Inheritance
class DigitalBook extends Book {
  int _id; // <-- PERUBAHAN: Menambahkan ID
  String _fileSize;
  String _format;
  String _imageUrl;
  String _pdfUrl;
  double _rating;
  int _downloads;
  // <-- PERUBAHAN: Tambahkan field baru
  int _numberOfPages;
  String _isbn;

  DigitalBook(
    this._id, // <-- PERUBAHAN: Menambahkan ID di constructor
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
    int numberOfPages = 0, // <-- PERUBAHAN: Tambahkan
    String isbn = 'N/A', // <-- PERUBAHAN: Tambahkan
  })  : _rating = rating,
        _downloads = downloads,
        _numberOfPages = numberOfPages, // <-- PERUBAHAN: Inisialisasi
        _isbn = isbn, // <-- PERUBAHAN: Inisialisasi
        super(title, author, year, category, description);

  // Helper untuk parsing tahun yang aman dari API
  static int _parseYear(dynamic date) {
    if (date == null) return 2024;
    // <-- PERUBAHAN: API detail mengirim 'double' (cth: 2000.0)
    if (date is num) return date.toInt();
    if (date is String) {
      if (date.length >= 4) {
        return int.tryParse(date.substring(0, 4)) ?? 2024;
      }
    }
    return 2024;
  }

  // Helper untuk parsing authors
  static String _parseAuthors(dynamic authors) {
    if (authors == null || authors is! List || authors.isEmpty) {
      return 'No Author';
    }
    try {
      return authors
          .map((author) => (author as Map<String, dynamic>)['name'] as String)
          .join(', ');
    } catch (e) {
      print('Gagal parsing authors: $e');
      return 'No Author';
    }
  }

  // Helper untuk rating
  static double _parseRating(dynamic ratingData) {
    if (ratingData is Map<String, dynamic> &&
        ratingData.containsKey('average')) {
      final avg = ratingData['average'];
      if (avg is num) {
        // <-- PERUBAHAN: Skala dari [0, 1] ke [0, 5]
        double scaledRating = (avg as num).toDouble() * 5.0;
        return scaledRating.clamp(0.0, 5.0);
      }
    }
    if (ratingData is num) {
      return ratingData.toDouble();
    }
    return 4.0;
  }

  // <-- PERUBAHAN: Helper baru untuk ISBN
  static String _parseIsbn(dynamic identifiers) {
    if (identifiers is Map<String, dynamic>) {
      if (identifiers.containsKey('isbn_13') &&
          identifiers['isbn_13'] != null) {
        return identifiers['isbn_13'] as String;
      }
      if (identifiers.containsKey('isbn_10') &&
          identifiers['isbn_10'] != null) {
        return identifiers['isbn_10'] as String;
      }
      if (identifiers.containsKey('open_library_id') &&
          identifiers['open_library_id'] != null) {
        return identifiers['open_library_id'] as String;
      }
    }
    return 'N/A';
  }

  // Factory constructor dari JSON API (Untuk Search)
  factory DigitalBook.fromJson(Map<String, dynamic> json) {
    // Note: Search factory mungkin perlu disesuaikan jika respons search berbeda
    return DigitalBook(
      (json['id'] as num?)?.toInt() ?? 0, // <-- PERUBAHAN: Ambil ID
      json['title'] ?? 'No Title',
      _parseAuthors(json['authors']),
      _parseYear(json['publish_date']),
      (json['genres'] as List?)?.first ?? 'General',
      json['description'] ?? 'No Description',
      'N/A',
      'API',
      json['image'] ?? '',
      'N/A',
      rating: _parseRating(json['rating']),
      // 'downloads' dari 'number_of_pages' (jika ada di search)
      downloads: (json['number_of_pages'] as num?)?.toInt() ?? 0,
      numberOfPages: (json['number_of_pages'] as num?)?.toInt() ?? 0,
      isbn: _parseIsbn(json['identifiers']),
    );
  }

  // <-- PERUBAHAN: Factory baru untuk endpoint Detail
  factory DigitalBook.fromJsonDetail(Map<String, dynamic> json) {
    return DigitalBook(
      (json['id'] as num?)?.toInt() ?? 0, // <-- Ambil ID
      json['title'] ?? 'No Title',
      _parseAuthors(json['authors']), // Helper authors
      _parseYear(json['publish_date']), // Helper tahun
      'General', // <-- Respons detail tidak memiliki 'genres'
      json['description'] ?? 'No Description',
      'N/A', // API tidak menyediakan ini
      'API', // Tandai sebagai format 'API'
      json['image'] ?? '', // URL Gambar dari API
      'N/A', // API tidak menyediakan PDF URL
      rating: _parseRating(json['rating']), // Helper rating
      downloads: 0, // <-- PERUBAHAN: API tidak menyediakan downloads
      // <-- PERUBAHAN: Gunakan field baru
      numberOfPages: (json['number_of_pages'] as num?)?.toInt() ?? 0,
      // <-- PERUBAHAN: Gunakan helper baru
      isbn: _parseIsbn(json['identifiers']),
    );
  }

  // Getters
  int get id => _id; // <-- PERUBAHAN: Getter untuk ID
  String get fileSize => _fileSize;
  String get format => _format;
  String get imageUrl => _imageUrl;
  String get pdfUrl => _pdfUrl;
  double get rating => _rating;
  int get downloads => _downloads;
  int get numberOfPages => _numberOfPages; // <-- PERUBAHAN: Getter baru
  String get isbn => _isbn; // <-- PERUBAHAN: Getter baru

  // Setters
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

  set numberOfPages(int pages) {
    // <-- PERUBAHAN: Setter baru
    if (pages >= 0) _numberOfPages = pages;
  }

  set isbn(String isbn) {
    // <-- PERUBAHAN: Setter baru
    if (isbn.isNotEmpty) _isbn = isbn;
  }

  // Enhanced Polymorphism
  @override
  String displayInfo() {
    return '${super.displayInfo()} - $_format ($_fileSize) • ${_rating.toStringAsFixed(1)}⭐';
  }

  String getFormattedDownloads() {
    return NumberFormat.compact(locale: 'id_ID').format(_downloads);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id, // <-- PERUBAHAN
      ...super.toJson(),
      'fileSize': _fileSize,
      'format': _format,
      'imageUrl': _imageUrl,
      'pdfUrl': _pdfUrl,
      'rating': _rating,
      'downloads': _downloads,
      'numberOfPages': _numberOfPages, // <-- PERUBAHAN
      'isbn': _isbn, // <-- PERUBAHAN
    };
  }

  @override
  List<Object?> get props => [
        _id, // <-- PERUBAHAN
        ...super.props,
        fileSize,
        format,
        imageUrl,
        pdfUrl,
        rating,
        downloads,
        _numberOfPages, // <-- PERUBAHAN
        _isbn, // <-- PERUBAHAN
      ];
}