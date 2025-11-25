// lib/models/book_model.dart

import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

// Base Class
class Book extends Equatable {
  final String _title;
  final String _author;
  final int _year;
  final String _category;
  final String _description;

  Book(
    this._title,
    this._author,
    this._year,
    this._category,
    this._description,
  );

  String get title => _title;
  String get author => _author;
  int get year => _year;
  String get category => _category;
  String get description => _description;

  String displayInfo() {
    return '$_title by $_author';
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

class DigitalBook extends Book {
  final int _id;
  final String _imageUrl;
  final String _epubUrl;
  final int _downloads;
  final List<String> _languages;
  final double _rating;

  DigitalBook(
    this._id,
    String title,
    String author,
    int year,
    String category,
    String description,
    this._imageUrl,
    this._epubUrl, {
    int downloads = 0,
    List<String> languages = const [],
    double rating = 0.0,
  })  : _downloads = downloads,
        _languages = languages,
        _rating = rating,
        super(title, author, year, category, description);

  // --- PARSING LOGIC ---

  static String _parseAuthors(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 'Unknown Author';
    return authors[0]['name'] ?? 'Unknown Author';
  }

  static int _parseYear(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 2024;
    final author = authors[0];
    if (author['death_year'] != null) return author['death_year'];
    if (author['birth_year'] != null) return author['birth_year'];
    return 2024;
  }

  static String _parseCategory(List<dynamic>? subjects, List<dynamic>? bookshelves) {
    if (bookshelves != null && bookshelves.isNotEmpty) {
      return bookshelves[0].toString().replaceAll('jh', '').trim(); 
    }
    if (subjects != null && subjects.isNotEmpty) {
      return subjects[0].toString().split('--')[0].trim();
    }
    return 'General';
  }

  // Generate rating berdasarkan download count (simulasi rating)
  static double _generateRating(int downloads) {
    if (downloads > 10000) return 5.0;
    if (downloads > 5000) return 4.5;
    if (downloads > 2000) return 4.0;
    if (downloads > 1000) return 3.5;
    if (downloads > 500) return 3.0;
    if (downloads > 100) return 2.5;
    if (downloads > 50) return 2.0;
    if (downloads > 10) return 1.5;
    return 1.0;
  }

  factory DigitalBook.fromGutendex(Map<String, dynamic> json) {
    // 1. Ambil Formats dengan aman (Cast ke Map<String, dynamic>)
    final Map<String, dynamic> formats = Map<String, dynamic>.from(json['formats'] ?? {});
    
    // 2. LOGIKA IMAGE (Disesuaikan dengan request Anda)
    String imgUrl = '';
    
    // Prioritas UTAMA: Cek key "image/jpeg" (Cover Medium)
    if (formats.containsKey('image/jpeg')) {
      imgUrl = formats['image/jpeg'];
    } 
    // Fallback 1: Cek key "image/png" jika jpeg tidak ada
    else if (formats.containsKey('image/png')) {
      imgUrl = formats['image/png'];
    }
    // Fallback 2: Cari key lain yang mengandung kata 'cover' atau 'image/'
    else {
      for (var key in formats.keys) {
        if (key.toString().contains('cover') || key.toString().contains('image/')) {
          imgUrl = formats[key];
          break;
        }
      }
    }

    // Gunakan placeholder jika masih kosong
    if (imgUrl.isEmpty) {
      imgUrl = 'https://via.placeholder.com/150';
    }

    // 3. Cari URL EPUB
    String epubUrl = formats['application/epub+zip'] ?? 
                     formats['application/epub3+zip'] ??
                     '';

    // 4. Ambil Deskripsi
    List<dynamic> summaries = json['summaries'] ?? [];
    String desc = summaries.isNotEmpty 
        ? summaries.join('\n\n') 
        : 'No description available.';

    return DigitalBook(
      json['id'] ?? 0,
      json['title'] ?? 'Untitled',
      _parseAuthors(json['authors']),
      _parseYear(json['authors']),
      _parseCategory(json['subjects'], json['bookshelves']),
      desc,
      imgUrl,
      epubUrl,
      downloads: json['download_count'] ?? 0,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: _generateRating(json['download_count'] ?? 0),
    );
  }

  int get id => _id;
  String get imageUrl => _imageUrl;
  String get epubUrl => _epubUrl;
  int get downloads => _downloads;
  List<String> get languages => _languages;
  double get rating => _rating;

  String getFormattedDownloads() {
    return NumberFormat.compact(locale: 'en_US').format(_downloads);
  }

  bool get isReadable => _epubUrl.isNotEmpty;

  @override
  String displayInfo() {
    return '${super.displayInfo()} • ${_languages.first.toUpperCase()}';
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      ...super.toJson(),
      'imageUrl': _imageUrl,
      'epubUrl': _epubUrl,
      'downloads': _downloads,
      'languages': _languages,
      'rating': _rating,
    };
  }

  @override
  List<Object?> get props => [
        _id,
        ...super.props,
        _imageUrl,
        _epubUrl,
        _downloads,
        _languages,
        _rating,
      ];
}