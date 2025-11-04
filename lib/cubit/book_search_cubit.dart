import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_search_state.dart';

class BookSearchCubit extends Cubit<BookSearchState> {
  // Cubit ini bergantung pada BookRepository (Abstract)
  final BookRepository _bookRepository;

  BookSearchCubit(this._bookRepository) : super(BookSearchInitial());

  // Fungsi untuk memicu pencarian API
  Future<void> searchApiBooks(String query) async {
    if (query.isEmpty) {
      emit(BookSearchInitial());
      return;
    }

    print('CUBIT (Search): Emitting BookSearchLoading');
    emit(BookSearchLoading());
    try {
      final books = await _bookRepository.searchBooks(query);
      print('CUBIT (Search): API call success, ${books.length} books found.');
      emit(BookSearchLoaded(books));
    } catch (e) {
      print('--- CUBIT (Search) ERROR ---');
      print(e.toString());
      print('----------------------------');
      emit(BookSearchError(e.toString()));
    }
  }

  // Fungsi untuk membersihkan hasil pencarian
  void clearSearch() {
    emit(BookSearchInitial());
  }
}
