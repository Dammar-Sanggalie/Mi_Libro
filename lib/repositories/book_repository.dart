import 'package:perpustakaan_mini/models/book_model.dart';

// Class pembungkus untuk menampung List Buku dan Total Data dari API
class BookPage {
  final List<DigitalBook> books;
  final int totalCount;

  const BookPage({required this.books, required this.totalCount});
}

abstract class BookRepository {
  Future<List<DigitalBook>> searchBooks(String query);

  // PERUBAHAN: Return type diubah dari Future<List<DigitalBook>> menjadi Future<BookPage>
  Future<BookPage> getInitialBooks({required int offset, required int number});

  Future<DigitalBook> getBookDetails(int bookId);
}
