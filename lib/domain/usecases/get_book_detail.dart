import '../repositories/book_repository.dart';
import '../entities/book.dart';

class GetBookDetail {
  final BookRepository repository;

  GetBookDetail(this.repository);

  Future<DigitalBook> call(int bookId) async {
    return await repository.getBookDetails(bookId);
  }
}
