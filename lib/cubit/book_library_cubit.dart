import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryState> {
  final BookRepository _bookRepository;

  List<DigitalBook> _books = [];
  int _offset = 0;
  final int _limit = 18;
  bool _isFetching = false;
  int _totalCount = 0; // Variable lokal untuk menyimpan total

  BookLibraryCubit(this._bookRepository) : super(BookLibraryInitial());

  Future<void> fetchInitialBooks() async {
    _books = [];
    _offset = 0;
    _totalCount = 0;
    _isFetching = true;

    emit(BookLibraryLoading());

    try {
      print('CUBIT (Library): Fetching initial books...');

      // PERUBAHAN: Menerima return type BookPage
      final pageData = await _bookRepository.getInitialBooks(
          offset: _offset, number: _limit);

      final newBooks = pageData.books;
      _totalCount = pageData.totalCount; // Simpan total count

      print(
          'CUBIT (Library): Success, ${newBooks.length} books found. Total API: $_totalCount');

      _books.addAll(newBooks);
      _offset += newBooks.length;

      // Emit dengan totalBookCount
      emit(BookLibraryLoaded(
        _books,
        hasReachedMax: newBooks.length < _limit,
        totalBookCount: _totalCount,
      ));
    } catch (e) {
      print('--- CUBIT (Library) ERROR ---');
      print(e.toString());
      emit(BookLibraryError(e.toString()));
    }

    _isFetching = false;
  }

  Future<void> fetchMoreBooks() async {
    if (_isFetching ||
        (state is BookLibraryLoaded &&
            (state as BookLibraryLoaded).hasReachedMax)) {
      return;
    }

    _isFetching = true;
    final currentState = state;

    if (currentState is BookLibraryLoaded) {
      print('CUBIT (Library): Fetching more books from offset $_offset');

      try {
        // PERUBAHAN: Menerima return type BookPage
        final pageData = await _bookRepository.getInitialBooks(
            offset: _offset, number: _limit);

        final newBooks = pageData.books;
        // Update total count jika berubah (opsional, biasanya sama)
        _totalCount = pageData.totalCount;

        print(
            'CUBIT (Library): Success (more), ${newBooks.length} books found.');

        if (newBooks.isEmpty) {
          emit(BookLibraryLoaded(currentState.books,
              hasReachedMax: true, totalBookCount: _totalCount));
        } else {
          final List<DigitalBook> updatedBooks = List.from(_books)
            ..addAll(newBooks);

          _books = updatedBooks;
          _offset += newBooks.length;

          emit(BookLibraryLoaded(
            updatedBooks,
            hasReachedMax: newBooks.length < _limit,
            totalBookCount: _totalCount,
          ));
        }
      } catch (e) {
        print('--- CUBIT (Library) LOAD MORE ERROR ---');
        print(e.toString());

        emit(BookLibraryLoaded(
          List.from(_books),
          hasReachedMax: currentState.hasReachedMax,
          totalBookCount: currentState.totalBookCount,
        ));
      }
    }

    _isFetching = false;
  }
}
