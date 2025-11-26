import '../entities/book.dart';
import '../repositories/book_repository.dart';

class ToggleFavorite {
  final BookRepository repository;

  ToggleFavorite(this.repository);

  // Returns true if added, false if removed
  Future<bool> call(DigitalBook book) async {
    final isFav = await repository.isFavorite(book.id.toString());
    if (isFav) {
      await repository.removeFavorite(book.id.toString());
      return false;
    } else {
      await repository.addFavorite(book);
      return true;
    }
  }
}
