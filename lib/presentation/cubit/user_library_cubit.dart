import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_collection.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/get_collections.dart';
import '../../domain/usecases/save_collections.dart';
import 'user_library_state.dart'; // Changed from part to import

class UserLibraryCubit extends Cubit<UserLibraryState> {
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;
  final GetCollections _getCollections;
  final SaveCollections _saveCollections;

  UserLibraryCubit({
    required GetFavorites getFavorites,
    required ToggleFavorite toggleFavorite,
    required GetCollections getCollections,
    required SaveCollections saveCollections,
  })  : _getFavorites = getFavorites,
        _toggleFavorite = toggleFavorite,
        _getCollections = getCollections,
        _saveCollections = saveCollections,
        super(UserLibraryInitial());

  Future<void> loadLibrary() async {
    emit(UserLibraryLoading());
    try {
      final favorites = await _getFavorites();
      final collections = await _getCollections();
      emit(UserLibraryLoaded(favorites: favorites, collections: collections));
    } catch (e) {
      emit(UserLibraryError(e.toString()));
    }
  }

  Future<void> toggleFavoriteBook(DigitalBook book) async {
    try {
      await _toggleFavorite(book);
      // Reload to update UI
      await loadLibrary(); 
    } catch (e) {
      // Handle error silently or emit dedicated error state if needed
      await loadLibrary();
    }
  }

  Future<void> createCollection(String name) async {
    if (state is UserLibraryLoaded) {
      final currentCollections = (state as UserLibraryLoaded).collections;
      final newCollection = BookCollection(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      );
      final updatedCollections = List<BookCollection>.from(currentCollections)..add(newCollection);
      
      await _saveCollections(updatedCollections);
      await loadLibrary();
    }
  }

  Future<void> deleteCollection(String id) async {
    if (state is UserLibraryLoaded) {
       final currentCollections = (state as UserLibraryLoaded).collections;
       final updatedCollections = currentCollections.where((c) => c.id != id).toList();
       await _saveCollections(updatedCollections);
       await loadLibrary();
    }
  }
  
  Future<void> addBookToCollection(String collectionId, DigitalBook book) async {
      if (state is UserLibraryLoaded) {
        final currentCollections = (state as UserLibraryLoaded).collections;
        final index = currentCollections.indexWhere((c) => c.id == collectionId);
        
        if (index != -1) {
            // Mutating the object directly for now as deep copy logic is complex
            // In a purer implementation, we would create a new Collection object
            final collection = currentCollections[index];
            if (!collection.bookIds.contains(book.id.toString())) {
                collection.bookIds.add(book.id.toString());
                await _saveCollections(currentCollections); 
                await loadLibrary();
            }
        }
      }
  }
  
  Future<void> removeBookFromCollection(String collectionId, String bookId) async {
      if (state is UserLibraryLoaded) {
        final currentCollections = (state as UserLibraryLoaded).collections;
        final index = currentCollections.indexWhere((c) => c.id == collectionId);
        
         if (index != -1) {
            final collection = currentCollections[index];
            collection.bookIds.remove(bookId);
            await _saveCollections(currentCollections);
            await loadLibrary();
        }
      }
  }
}
