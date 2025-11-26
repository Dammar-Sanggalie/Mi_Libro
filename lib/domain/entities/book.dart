import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart'; // Import for NumberFormat

class Book extends Equatable {
  final String title;
  final String author;
  final int year;
  final String category;
  final String description;

  const Book({
    required this.title,
    required this.author,
    required this.year,
    required this.category,
    required this.description,
  });

  @override
  List<Object?> get props => [title, author, year, category, description];
}

class DigitalBook extends Book {
  final int id;
  final String imageUrl;
  final String epubUrl;
  final int downloads;
  final List<String> languages;
  final double rating;

  const DigitalBook({
    required this.id,
    required String title,
    required String author,
    required int year,
    required String category,
    required String description,
    required this.imageUrl,
    required this.epubUrl,
    this.downloads = 0,
    this.languages = const [],
    this.rating = 0.0,
  }) : super(
          title: title,
          author: author,
          year: year,
          category: category,
          description: description,
        );

  bool get isReadable => epubUrl.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        year,
        category,
        description,
        imageUrl,
        epubUrl,
        downloads,
        languages,
        rating,
      ];
}

// Extension to provide display-specific formatting for DigitalBook
extension DigitalBookExtension on DigitalBook {
  String getFormattedDownloads() {
    return NumberFormat.compact(locale: 'en_US').format(downloads);
  }
}

// Helper class for Pagination
class BookPage extends Equatable {
  final List<DigitalBook> books;
  final int totalCount;

  const BookPage({required this.books, required this.totalCount});
  
  @override
  List<Object?> get props => [books, totalCount];
}
