import '../repositories/book_repository.dart';

class CheckFavoriteStatus {
  final BookRepository repository;

  CheckFavoriteStatus(this.repository);

  Future<bool> call(String bookId) async {
    return await repository.isFavorite(bookId);
  }
}
