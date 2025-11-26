import '../entities/book_collection.dart';
import '../repositories/book_repository.dart';

class SaveCollections {
  final BookRepository repository;

  SaveCollections(this.repository);

  Future<void> call(List<BookCollection> collections) async {
    await repository.saveCollections(collections);
  }
}
