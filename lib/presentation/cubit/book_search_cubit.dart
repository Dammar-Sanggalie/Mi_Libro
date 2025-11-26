import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/search_books.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint

part 'book_search_state.dart';

class BookSearchCubit extends Cubit<BookSearchState> {
  final SearchBooks _searchBooks;

  BookSearchCubit(this._searchBooks) : super(BookSearchInitial());

  // Fungsi untuk memicu pencarian API
  Future<void> searchApiBooks(String query) async {
    if (query.isEmpty) {
      emit(BookSearchInitial());
      return;
    }

    debugPrint('CUBIT (Search): Emitting BookSearchLoading');
    emit(BookSearchLoading());
    try {
      final books = await _searchBooks(query);
      debugPrint('CUBIT (Search): API call success, ${books.length} books found.');
      emit(BookSearchLoaded(books));
    } catch (e) {
      debugPrint('--- CUBIT (Search) ERROR ---');
      debugPrint(e.toString());
      debugPrint('----------------------------');
      emit(BookSearchError(e.toString()));
    }
  }

  // Fungsi untuk membersihkan hasil pencarian
  void clearSearch() {
    emit(BookSearchInitial());
  }
}
