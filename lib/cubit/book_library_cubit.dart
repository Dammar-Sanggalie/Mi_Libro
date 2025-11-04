import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryState> {
  final BookRepository _bookRepository;

  BookLibraryCubit(this._bookRepository) : super(BookLibraryInitial());

  // Fungsi untuk mengambil buku "default" untuk halaman utama
  Future<void> fetchInitialBooks() async {
    // --- DEBUG PRINT ---
    print('CUBIT (Library): Emitting BookLibraryLoading');
    // ---------------------
    emit(BookLibraryLoading());
    try {
      final books = await _bookRepository.getInitialBooks();
      // --- DEBUG PRINT ---
      print('CUBIT (Library): API call success, ${books.length} books found.');
      // ---------------------
      emit(BookLibraryLoaded(books));
    } catch (e) {
      // --- DEBUG PRINT ---
      print('--- CUBIT (Library) ERROR ---');
      print(e.toString());
      print('-----------------------------');
      // ---------------------
      emit(BookLibraryError(e.toString()));
    }
  }
}
