import 'package:perpustakaan_mini/models/book_model.dart';

abstract class BookRepository {
  Future<List<DigitalBook>> searchBooks(String query);
  Future<List<DigitalBook>> getInitialBooks();
}
