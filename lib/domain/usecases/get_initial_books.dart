import '../repositories/book_repository.dart';
import '../entities/book.dart';

class GetInitialBooks {
  final BookRepository repository;

  GetInitialBooks(this.repository);

  Future<BookPage> call({required int offset, required int number}) async {
    return await repository.getInitialBooks(offset: offset, number: number);
  }
}
