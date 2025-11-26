import '../repositories/book_repository.dart';
import '../entities/book.dart';

class SearchBooks {
  final BookRepository repository;

  SearchBooks(this.repository);

  Future<List<DigitalBook>> call(String query) async {
    return await repository.searchBooks(query);
  }
}
