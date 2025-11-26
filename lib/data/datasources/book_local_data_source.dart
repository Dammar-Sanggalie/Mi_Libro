import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/book_collection.dart';
import '../models/book_model.dart';

abstract class BookLocalDataSource {
  Future<void> cacheFavoriteBook(BookModel book);
  Future<void> removeFavoriteBook(String bookId);
  Future<List<BookModel>> getFavoriteBooks();
  Future<bool> isFavorite(String bookId);

  Future<void> cacheCollections(List<BookCollection> collections);
  Future<List<BookCollection>> getCollections();

  Future<void> cacheUserRating(String bookId, double rating);
  Future<double> getUserRating(String bookId);
  Future<Map<String, double>> getAllUserRatings();
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  final SharedPreferences sharedPreferences;

  BookLocalDataSourceImpl({required this.sharedPreferences});

  static const String CACHED_FAVORITES_KEY = 'favoriteBooksData';
  static const String CACHED_FAVORITE_IDS_KEY = 'favoriteBooks'; // Legacy support
  static const String CACHED_COLLECTIONS_KEY = 'userCollections';
  static const String CACHED_RATINGS_KEY = 'userRatings';

  @override
  Future<void> cacheFavoriteBook(BookModel book) async {
    List<BookModel> currentFavorites = await getFavoriteBooks();
    
    // Check if already exists to avoid duplicates
    if (!currentFavorites.any((b) => b.id == book.id)) {
      currentFavorites.add(book);
    }

    final jsonList = currentFavorites.map((b) => jsonEncode(b.toJson())).toList();
    await sharedPreferences.setStringList(CACHED_FAVORITES_KEY, jsonList);
    
    // Maintain legacy ID list
    await sharedPreferences.setStringList(CACHED_FAVORITE_IDS_KEY, currentFavorites.map((b) => b.id.toString()).toList());
  }

  @override
  Future<void> removeFavoriteBook(String bookId) async {
    List<BookModel> currentFavorites = await getFavoriteBooks();
    currentFavorites.removeWhere((b) => b.id.toString() == bookId);

    final jsonList = currentFavorites.map((b) => jsonEncode(b.toJson())).toList();
    await sharedPreferences.setStringList(CACHED_FAVORITES_KEY, jsonList);
    
    // Maintain legacy ID list
    await sharedPreferences.setStringList(CACHED_FAVORITE_IDS_KEY, currentFavorites.map((b) => b.id.toString()).toList());
  }

  @override
  Future<List<BookModel>> getFavoriteBooks() async {
    final jsonList = sharedPreferences.getStringList(CACHED_FAVORITES_KEY);
    if (jsonList == null) {
      // Try loading from legacy ID list if full data is missing (optional, but good for migration)
      return [];
    }

    List<BookModel> books = [];
    for (String jsonStr in jsonList) {
      try {
        books.add(BookModel.fromJson(jsonDecode(jsonStr)));
      } catch (e) {
        print('Error parsing cached book: $e');
      }
    }
    return books;
  }

  @override
  Future<bool> isFavorite(String bookId) async {
     final favoriteIds = sharedPreferences.getStringList(CACHED_FAVORITE_IDS_KEY);
     return favoriteIds?.contains(bookId) ?? false;
  }

  @override
  Future<void> cacheCollections(List<BookCollection> collections) async {
    final String encodedData = jsonEncode(
      collections.map((c) => c.toJson()).toList(),
    );
    await sharedPreferences.setString(CACHED_COLLECTIONS_KEY, encodedData);
  }

  @override
  Future<List<BookCollection>> getCollections() async {
    final String? encodedData = sharedPreferences.getString(CACHED_COLLECTIONS_KEY);
    if (encodedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(encodedData);
        return decodedList.map((item) => BookCollection.fromJson(item)).toList();
      } catch (e) {
        print('Error loading collections: $e');
      }
    }
    return [];
  }

  @override
  Future<void> cacheUserRating(String bookId, double rating) async {
    Map<String, double> ratings = await getAllUserRatings();
    ratings[bookId] = rating;
    
    final ratingsMap = ratings.map((key, value) => MapEntry(key, value.toString()));
    await sharedPreferences.setString(CACHED_RATINGS_KEY, jsonEncode(ratingsMap));
  }

  @override
  Future<double> getUserRating(String bookId) async {
    Map<String, double> ratings = await getAllUserRatings();
    return ratings[bookId] ?? 0.0;
  }
  
  @override
  Future<Map<String, double>> getAllUserRatings() async {
    final ratingsStr = sharedPreferences.getString(CACHED_RATINGS_KEY);
    if (ratingsStr != null) {
      try {
        final ratingsMap = jsonDecode(ratingsStr) as Map<String, dynamic>;
        return ratingsMap.map((key, value) => MapEntry(key, double.parse(value.toString())));
      } catch (e) {
        print('Error loading ratings: $e');
      }
    }
    return {};
  }
}
