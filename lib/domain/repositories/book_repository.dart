import '../entities/book.dart';
import '../entities/book_collection.dart';

abstract class BookRepository {
  // Remote
  Future<BookPage> getInitialBooks({required int offset, required int number});
  Future<List<DigitalBook>> searchBooks(String query);
  Future<DigitalBook> getBookDetails(int bookId);

  // Local (Favorites)
  Future<List<DigitalBook>> getFavorites();
  Future<void> addFavorite(DigitalBook book);
  Future<void> removeFavorite(String bookId);
  Future<bool> isFavorite(String bookId);
  
  // Local (Collections)
  Future<List<BookCollection>> getCollections();
  Future<void> saveCollections(List<BookCollection> collections);

  // Local (Ratings)
  Future<void> saveRating(String bookId, double rating);
  Future<double> getRating(String bookId);
}
