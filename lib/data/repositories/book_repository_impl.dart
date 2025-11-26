import '../../domain/repositories/book_repository.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_collection.dart';
import '../datasources/book_remote_data_source.dart';
import '../datasources/book_local_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<BookPage> getInitialBooks({required int offset, required int number}) async {
    return await remoteDataSource.getInitialBooks(offset: offset, number: number);
  }

  @override
  Future<List<DigitalBook>> searchBooks(String query) async {
    return await remoteDataSource.searchBooks(query);
  }

  @override
  Future<DigitalBook> getBookDetails(int bookId) async {
    return await remoteDataSource.getBookDetails(bookId);
  }

  // --- Local Favorites ---

  @override
  Future<List<DigitalBook>> getFavorites() async {
    return await localDataSource.getFavoriteBooks();
  }

  @override
  Future<void> addFavorite(DigitalBook book) async {
    await localDataSource.cacheFavoriteBook(BookModel.fromEntity(book));
  }

  @override
  Future<void> removeFavorite(String bookId) async {
    await localDataSource.removeFavoriteBook(bookId);
  }

  @override
  Future<bool> isFavorite(String bookId) async {
    return await localDataSource.isFavorite(bookId);
  }

  // --- Local Collections ---

  @override
  Future<List<BookCollection>> getCollections() async {
    return await localDataSource.getCollections();
  }

  @override
  Future<void> saveCollections(List<BookCollection> collections) async {
    await localDataSource.cacheCollections(collections);
  }

  // --- Local Ratings ---

  @override
  Future<void> saveRating(String bookId, double rating) async {
    await localDataSource.cacheUserRating(bookId, rating);
  }

  @override
  Future<double> getRating(String bookId) async {
    return await localDataSource.getUserRating(bookId);
  }
}