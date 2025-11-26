import '../../domain/entities/book.dart';

class BookModel extends DigitalBook {
  const BookModel({
    required int id,
    required String title,
    required String author,
    required int year,
    required String category,
    required String description,
    required String imageUrl,
    required String epubUrl,
    int downloads = 0,
    List<String> languages = const [],
    double rating = 0.0,
  }) : super(
          id: id,
          title: title,
          author: author,
          year: year,
          category: category,
          description: description,
          imageUrl: imageUrl,
          epubUrl: epubUrl,
          downloads: downloads,
          languages: languages,
          rating: rating,
        );

  factory BookModel.fromGutendex(Map<String, dynamic> json) {
    final Map<String, dynamic> formats = 
        Map<String, dynamic>.from(json['formats'] ?? {});

    // 1. Logic Image
    String imgUrl = '';
    final int bookId = json['id'] ?? 0;

    if (formats.containsKey('image/jpeg')) {
      imgUrl = formats['image/jpeg'];
    } else if (formats.containsKey('image/png')) {
      imgUrl = formats['image/png'];
    } else {
      for (var key in formats.keys) {
        if (key.toString().contains('cover') ||
            key.toString().contains('image/')) {
          imgUrl = formats[key];
          break;
        }
      }
    }

    if (imgUrl.isEmpty) {
      imgUrl = 'https://www.gutendex.com/cache/epub/$bookId/pg$bookId.jpg';
    }

    // 2. Logic Epub
    String epubUrl = formats['application/epub+zip'] ??
        formats['application/epub3+zip'] ??
        '';

    // 3. Logic Description
    List<dynamic> summaries = json['summaries'] ?? [];
    String desc = summaries.isNotEmpty
        ? summaries.join('\n\n')
        : 'No description available.';

    return BookModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled',
      author: _parseAuthors(json['authors']),
      year: _parseYear(json['authors']),
      category: _parseCategory(json['subjects'], json['bookshelves']),
      description: desc,
      imageUrl: imgUrl,
      epubUrl: epubUrl,
      downloads: json['download_count'] ?? 0,
      languages: (json['languages'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: _generateRating(json['download_count'] ?? 0),
    );
  }

  // For Local Caching
  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      year: json['year'] as int,
      category: json['category'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      epubUrl: json['epubUrl'] as String,
      downloads: json['downloads'] as int? ?? 0,
      languages: List<String>.from(json['languages'] as List? ?? []),
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'year': year,
      'category': category,
      'description': description,
      'imageUrl': imageUrl,
      'epubUrl': epubUrl,
      'downloads': downloads,
      'languages': languages,
      'rating': rating,
    };
  }
  
  // Helper to convert DigitalBook to BookModel
  factory BookModel.fromEntity(DigitalBook book) {
    return BookModel(
      id: book.id,
      title: book.title,
      author: book.author,
      year: book.year,
      category: book.category,
      description: book.description,
      imageUrl: book.imageUrl,
      epubUrl: book.epubUrl,
      downloads: book.downloads,
      languages: book.languages,
      rating: book.rating,
    );
  }

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

  static String _parseCategory(
      List<dynamic>? subjects, List<dynamic>? bookshelves) {
    if (bookshelves != null && bookshelves.isNotEmpty) {
      return bookshelves[0].toString().replaceAll('jh', '').trim();
    }
    if (subjects != null && subjects.isNotEmpty) {
      return subjects[0].toString().split('--')[0].trim();
    }
    return 'General';
  }

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
}
