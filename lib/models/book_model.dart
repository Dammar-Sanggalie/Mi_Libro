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

  // Helper untuk parsing tahun yang aman dari API
  static int _parseYear(dynamic date) {
    if (date == null) return 2024;
    if (date is int) return date;
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

  // --- FUNGSI HELPER BARU UNTUK RATING (INI PERBAIKANNYA) ---
  static double _parseRating(dynamic ratingData) {
    // Cek jika ratingData adalah Map dan punya key 'average'
    if (ratingData is Map<String, dynamic> &&
        ratingData.containsKey('average')) {
      final avg = ratingData['average'];
      if (avg is num) {
        // API mengembalikan rating 0.0 - 1.0. Kita ubah ke skala 0.0 - 5.0
        double scaledRating = (avg as num).toDouble() * 5.0;
        // Batasi nilainya antara 0.0 dan 5.0
        return scaledRating.clamp(0.0, 5.0);
      }
    }
    // Cek jika API (mungkin) mengirim rating sebagai angka
    if (ratingData is num) {
      return ratingData.toDouble();
    }
    // Jika tidak ada data, beri rating default
    return 4.0;
  }
  // --------------------------------------------------------

  // Factory constructor dari JSON API
  factory DigitalBook.fromJson(Map<String, dynamic> json) {
    return DigitalBook(
      json['title'] ?? 'No Title',
      _parseAuthors(json['authors']), // Helper authors
      _parseYear(json['publish_date']), // Helper tahun
      (json['genres'] as List?)?.first ?? 'General',
      json['description'] ?? 'No Description',
      'N/A', // API tidak menyediakan ini
      'API', // Tandai sebagai format 'API'
      json['image'] ?? '', // URL Gambar dari API
      'N/A', // API tidak menyediakan PDF URL

      // --- PERBAIKAN: Gunakan helper rating yang baru ---
      rating: _parseRating(json['rating']),

      // 'number_of_pages' tidak ada di JSON, jadi 'downloads' akan 0 (ini aman)
      downloads: (json['number_of_pages'] as int?) ?? 0,
    );
  }

  // Getters
  String get fileSize => _fileSize;
  String get format => _format;
  String get imageUrl => _imageUrl;
  String get pdfUrl => _pdfUrl;
  double get rating => _rating;
  int get downloads => _downloads;

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
      ...super.toJson(),
      'fileSize': _fileSize,
      'format': _format,
      'imageUrl': _imageUrl,
      'pdfUrl': _pdfUrl,
      'rating': _rating,
      'downloads': _downloads,
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, fileSize, format, imageUrl, pdfUrl, rating, downloads];
}
