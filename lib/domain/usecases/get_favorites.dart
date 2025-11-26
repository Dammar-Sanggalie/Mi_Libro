import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetFavorites {
  final BookRepository repository;

  GetFavorites(this.repository);

  Future<List<DigitalBook>> call() async {
    return await repository.getFavorites();
  }
}
