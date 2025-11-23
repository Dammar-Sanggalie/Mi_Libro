import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryState> {
  final BookRepository _bookRepository;

  // State lokal untuk menampung data
  List<DigitalBook> _books = [];
  int _offset = 0;
  final int _limit = 18; // Jumlah buku per halaman (batch)
  bool _isFetching = false; // Penanda agar tidak fetch ganda

  BookLibraryCubit(this._bookRepository) : super(BookLibraryInitial());

  // 1. Fungsi untuk mengambil buku awal (Reset dari 0)
  Future<void> fetchInitialBooks() async {
    // Reset state lokal
    _books = [];
    _offset = 0;
    _isFetching = true;

    emit(BookLibraryLoading());

    try {
      print('CUBIT (Library): Fetching initial books...');

      final newBooks = await _bookRepository.getInitialBooks(
          offset: _offset, number: _limit);

      print('CUBIT (Library): Success, ${newBooks.length} books found.');

      // Masukkan ke list lokal
      _books.addAll(newBooks);
      _offset += newBooks.length;

      // Emit state Loaded dengan list baru
      // (Di sini _books baru saja di-reset jadi [] di atas, jadi aman)
      emit(BookLibraryLoaded(_books, hasReachedMax: newBooks.length < _limit));
    } catch (e) {
      print('--- CUBIT (Library) ERROR ---');
      print(e.toString());
      emit(BookLibraryError(e.toString()));
    }

    _isFetching = false;
  }

  // 2. Fungsi untuk menambah buku saat scroll (Infinite Scroll)
  Future<void> fetchMoreBooks() async {
    // Cek apakah sedang fetching atau sudah max data
    if (_isFetching ||
        (state is BookLibraryLoaded &&
            (state as BookLibraryLoaded).hasReachedMax)) {
      return;
    }

    _isFetching = true;

    // Simpan state saat ini untuk fallback jika error
    final currentState = state;

    if (currentState is BookLibraryLoaded) {
      print('CUBIT (Library): Fetching more books from offset $_offset');

      try {
        final newBooks = await _bookRepository.getInitialBooks(
            offset: _offset, number: _limit);

        print(
            'CUBIT (Library): Success (more), ${newBooks.length} books found.');

        if (newBooks.isEmpty) {
          // Jika tidak ada data baru, update hasReachedMax = true
          emit(BookLibraryLoaded(currentState.books, hasReachedMax: true));
        } else {
          // --- PERBAIKAN UTAMA DI SINI ---
          // Buat instance List baru yang berisi gabungan data lama + baru
          // Teknik ini memastikan Equatable mendeteksi perubahan state
          final List<DigitalBook> updatedBooks = List.from(_books)
            ..addAll(newBooks);

          // Update variabel lokal
          _books = updatedBooks;
          _offset += newBooks.length;

          // Emit state dengan List yang BARU
          emit(BookLibraryLoaded(updatedBooks,
              hasReachedMax: newBooks.length < _limit));
        }
      } catch (e) {
        print('--- CUBIT (Library) LOAD MORE ERROR ---');
        print(e.toString());

        // Jika gagal, kembalikan state sebelumnya agar UI tidak error
        // Kita gunakan List.from(_books) untuk keamanan ekstra
        emit(BookLibraryLoaded(List.from(_books),
            hasReachedMax: currentState.hasReachedMax));
      }
    }

    _isFetching = false;
  }
}
