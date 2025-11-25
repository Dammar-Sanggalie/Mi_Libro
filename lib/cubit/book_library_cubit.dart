import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/models/sort_option.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

part 'book_library_state.dart';

class BookLibraryCubit extends Cubit<BookLibraryState> {
  final BookRepository _bookRepository;

  // State lokal untuk menampung data
  List<DigitalBook> _books = [];
  List<DigitalBook> _allBooks = []; // Menyimpan semua buku untuk filtering
  int _offset = 0;
  final int _limit = 18; // Jumlah buku per halaman (batch)
  bool _isFetching = false; // Penanda agar tidak fetch ganda

  // Filter dan sorting options
  SortOption _currentSort = SortOption.popularity;
  RatingFilter _currentRatingFilter = RatingFilter.all;

  BookLibraryCubit(this._bookRepository) : super(BookLibraryInitial());

  // 1. Fungsi untuk mengambil buku awal (Reset dari 0)
  Future<void> fetchInitialBooks() async {
    // Reset state lokal
    _books = [];
    _allBooks = [];
    _offset = 0;
    _isFetching = true;

    emit(BookLibraryLoading());

    try {
      print('CUBIT (Library): Fetching initial books...');

      final pageData = await _bookRepository.getInitialBooks(
          offset: _offset, number: _limit);
      final newBooks = pageData.books;

      print('CUBIT (Library): Success, ${newBooks.length} books found.');

      // Masukkan ke list lokal
      _allBooks.addAll(newBooks);
      _offset += newBooks.length;

      // Apply filters and sorting
      _applyFiltersAndSort();

      // Emit state Loaded dengan list yang sudah difilter
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
        final pageData = await _bookRepository.getInitialBooks(
            offset: _offset, number: _limit);
        final newBooks = pageData.books;

        print(
            'CUBIT (Library): Success (more), ${newBooks.length} books found.');

        if (newBooks.isEmpty) {
          // Jika tidak ada data baru, update hasReachedMax = true
          emit(BookLibraryLoaded(currentState.books, hasReachedMax: true));
        } else {
          // Add new books to _allBooks
          _allBooks.addAll(newBooks);
          _offset += newBooks.length;

          // Apply filters and sorting again
          _applyFiltersAndSort();

          // Emit state dengan List yang BARU
          emit(BookLibraryLoaded(List.from(_books),
              hasReachedMax: newBooks.length < _limit));
        }
      } catch (e) {
        print('--- CUBIT (Library) LOAD MORE ERROR ---');
        print(e.toString());

        // Jika gagal, kembalikan state sebelumnya agar UI tidak error
        emit(BookLibraryLoaded(List.from(_books),
            hasReachedMax: currentState.hasReachedMax));
      }
    }

    _isFetching = false;
  }

  // 3. Fungsi untuk mengubah sorting
  void changeSorting(SortOption newSort) {
    _currentSort = newSort;
    _applyFiltersAndSort();
    emit(BookLibraryLoaded(List.from(_books), hasReachedMax: false));
  }

  // 4. Fungsi untuk mengubah filter rating
  void changeRatingFilter(RatingFilter newFilter) {
    _currentRatingFilter = newFilter;
    _applyFiltersAndSort();
    emit(BookLibraryLoaded(List.from(_books), hasReachedMax: false));
  }

  // 5. Apply filters and sorting
  void _applyFiltersAndSort() {
    // Start with all books
    List<DigitalBook> filteredBooks = List.from(_allBooks);

    // Apply rating filter
    if (_currentRatingFilter != RatingFilter.all) {
      filteredBooks = filteredBooks
          .where((book) => book.rating >= _currentRatingFilter.minimumRating)
          .toList();
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.popularity:
        filteredBooks.sort((a, b) => b.downloads.compareTo(a.downloads));
        break;
      case SortOption.titleAZ:
        filteredBooks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        filteredBooks.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.newest:
        filteredBooks.sort((a, b) => b.year.compareTo(a.year));
        break;
      case SortOption.oldest:
        filteredBooks.sort((a, b) => a.year.compareTo(b.year));
        break;
    }

    _books = filteredBooks;
  }

  // Getters for current state
  SortOption get currentSort => _currentSort;
  RatingFilter get currentRatingFilter => _currentRatingFilter;
}
