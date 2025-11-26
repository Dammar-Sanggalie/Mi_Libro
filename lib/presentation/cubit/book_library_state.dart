part of 'book_library_cubit.dart';

abstract class BookLibraryState extends Equatable {
  const BookLibraryState();
  @override
  List<Object> get props => [];
}

class BookLibraryInitial extends BookLibraryState {}

class BookLibraryLoading extends BookLibraryState {}

class BookLibraryLoaded extends BookLibraryState {
  final List<DigitalBook> books;
  final bool hasReachedMax;
  final int totalBookCount; // PERUBAHAN: Tambah field totalBookCount

  const BookLibraryLoaded(
    this.books, {
    this.hasReachedMax = false,
    this.totalBookCount = 0, // Default 0
  });

  @override
  // PERUBAHAN: Masukkan totalBookCount ke props
  List<Object> get props => [books, hasReachedMax, totalBookCount];
}

class BookLibraryError extends BookLibraryState {
  final String message;
  const BookLibraryError(this.message);
  @override
  List<Object> get props => [message];
}
