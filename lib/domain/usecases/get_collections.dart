import '../entities/book_collection.dart';
import '../repositories/book_repository.dart';

class GetCollections {
  final BookRepository repository;

  GetCollections(this.repository);

  Future<List<BookCollection>> call() async {
    return await repository.getCollections();
  }
}
