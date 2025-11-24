// lib/models/book_model.dart

import 'package:intl/intl.dart';
import 'package:equatable/equatable.dart';

// Base Class
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

  String get title => _title;
  String get author => _author;
  int get year => _year;
  String get category => _category;
  String get description => _description;

  // Base display info
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

// Enhanced DigitalBook for Gutendex
class DigitalBook extends Book {
  final int _id;
  final String _imageUrl;
  final String _epubUrl; // URL khusus untuk file EPUB
  final int _downloads;
  final List<String> _languages;

  // Constructor
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
  })  : _downloads = downloads,
        _languages = languages,
        super(title, author, year, category, description);

  // --- PARSING LOGIC KHUSUS GUTENDEX ---

  // Helper untuk mengambil Author pertama
  static String _parseAuthors(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 'Unknown Author';
    // Gutendex format: "Lastname, Firstname". Kita ubah sedikit jika perlu,
    // tapi membiarkannya apa adanya juga oke.
    return authors[0]['name'] ?? 'Unknown Author';
  }

  // Helper untuk mencari tahun dari range author (Gutendex tidak selalu punya publish date buku)
  // Kita gunakan tahun lahir/wafat author atau tahun default
  static int _parseYear(List<dynamic>? authors) {
    if (authors == null || authors.isEmpty) return 2024;
    // Coba ambil tahun meninggal atau lahir author sebagai referensi 'era' buku
    final author = authors[0];
    if (author['death_year'] != null) return author['death_year'];
    if (author['birth_year'] != null) return author['birth_year'];
    return 2024;
  }

  // Helper untuk mengambil kategori (Subject / Bookshelf)
  static String _parseCategory(List<dynamic>? subjects, List<dynamic>? bookshelves) {
    if (bookshelves != null && bookshelves.isNotEmpty) {
      // Ambil kata kunci yang menarik dari bookshelf, misal "Science Fiction"
      return bookshelves[0].toString().replaceAll('jh', '').trim(); 
    }
    if (subjects != null && subjects.isNotEmpty) {
      // Subject biasanya panjang, kita ambil bagian awal saja
      return subjects[0].toString().split('--')[0].trim();
    }
    return 'General';
  }

  // Factory Method Utama untuk Gutendex
  factory DigitalBook.fromGutendex(Map<String, dynamic> json) {
    // 1. Ambil Formats
    final Map<String, dynamic> formats = json['formats'] ?? {};
    
    // 2. Cari URL Cover Image (Prioritas: Medium -> Small -> Any Image)
    String imgUrl = formats['image/jpeg'] ?? 
                    formats['image/png'] ?? 
                    'https://via.placeholder.com/150'; // Fallback image

    // 3. Cari URL EPUB (Prioritas: epub+zip -> epub)
    String epubUrl = formats['application/epub+zip'] ?? '';

    // 4. Ambil Deskripsi (Summaries)
    List<dynamic> summaries = json['summaries'] ?? [];
    String desc = summaries.isNotEmpty 
        ? summaries.join('\n\n') 
        : 'No description available for this book. You can read it directly to find out more.';

    return DigitalBook(
      json['id'] ?? 0,
      json['title'] ?? 'Untitled',
      _parseAuthors(json['authors']),
      _parseYear(json['authors']), // Estimasi tahun
      _parseCategory(json['subjects'], json['bookshelves']),
      desc,
      imgUrl,
      epubUrl,
      downloads: json['download_count'] ?? 0,
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  // Getters
  int get id => _id;
  String get imageUrl => _imageUrl;
  String get epubUrl => _epubUrl; // Getter penting untuk fitur baca
  int get downloads => _downloads;
  List<String> get languages => _languages;

  // Format download count agar rapi (misal: 12.5K)
  String getFormattedDownloads() {
    return NumberFormat.compact(locale: 'en_US').format(_downloads);
  }

  // Helper cek apakah buku bisa dibaca (ada file EPUB-nya)
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
      ];
}