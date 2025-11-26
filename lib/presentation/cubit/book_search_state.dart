part of 'book_search_cubit.dart';

// Abstract class untuk semua state
abstract class BookSearchState extends Equatable {
  const BookSearchState();
  @override
  List<Object> get props => [];
}

// State awal, belum ada aksi
class BookSearchInitial extends BookSearchState {}

// State ketika sedang loading (menunggu data dari API)
class BookSearchLoading extends BookSearchState {}

// State ketika data berhasil didapat
class BookSearchLoaded extends BookSearchState {
  final List<DigitalBook> books;
  const BookSearchLoaded(this.books);
  @override
  List<Object> get props => [books];
}

// State ketika terjadi error
class BookSearchError extends BookSearchState {
  final String message;
  const BookSearchError(this.message);
  @override
  List<Object> get props => [message];
}
