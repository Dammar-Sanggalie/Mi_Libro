import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryState> {
  final BookRepository _bookRepository;

  // <-- BARU: State untuk pagination
  List<DigitalBook> _books = [];
  int _offset = 0;
  final int _limit = 18; // Sesuai permintaan Anda
  bool _isFetching = false;

  BookLibraryCubit(this._bookRepository) : super(BookLibraryInitial());

  // Fungsi untuk mengambil buku "default" untuk halaman utama
  Future<void> fetchInitialBooks() async {
    // <-- BARU: Reset state untuk pemuatan awal
    _books = [];
    _offset = 0;
    _isFetching = true;

    // --- DEBUG PRINT ---
    print('CUBIT (Library): Emitting BookLibraryLoading');
    // ---------------------
    emit(BookLibraryLoading());
    try {
      // <-- PERUBAHAN: Panggil dengan offset dan limit
      final newBooks =
          await _bookRepository.getInitialBooks(offset: _offset, number: _limit);

      // --- DEBUG PRINT ---
      print(
          'CUBIT (Library): API call success (initial), ${newBooks.length} books found.');
      // ---------------------

      _books.addAll(newBooks);
      _offset += newBooks.length;

      // <-- PERUBAHAN: Emit state baru dengan hasReachedMax
      emit(BookLibraryLoaded(_books, hasReachedMax: newBooks.length < _limit));
    } catch (e) {
      // --- DEBUG PRINT ---
      print('--- CUBIT (Library) ERROR ---');
      print(e.toString());
      print('-----------------------------');
      // ---------------------
      emit(BookLibraryError(e.toString()));
    }
    _isFetching = false; // <-- BARU
  }

  // <-- BARU: Fungsi untuk memuat lebih banyak buku
  Future<void> fetchMoreBooks() async {
    // Jangan fetch jika sedang fetching atau sudah max
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
        // Panggil API dengan offset saat ini
        final newBooks =
            await _bookRepository.getInitialBooks(offset: _offset, number: _limit);
        print(
            'CUBIT (Library): API call success (more), ${newBooks.length} books found.');

        // Tambahkan buku baru ke daftar yang ada
        _books.addAll(newBooks);
        _offset += newBooks.length;

        // Emit state baru dengan list gabungan dan status hasReachedMax
        emit(BookLibraryLoaded(_books, hasReachedMax: newBooks.length < _limit));
      } catch (e) {
        print('--- CUBIT (Library) LOAD MORE ERROR ---');
        print(e.toString());
        print('---------------------------------------');
        // Jika gagal, emit state sebelumnya agar UI tidak rusak
        emit(
            BookLibraryLoaded(_books, hasReachedMax: currentState.hasReachedMax));
      }
    }
    _isFetching = false;
  }
}