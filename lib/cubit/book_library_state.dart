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
  final bool hasReachedMax; // <-- PERUBAHAN: Ditambahkan

  // <-- PERUBAHAN: Modifikasi constructor
  const BookLibraryLoaded(this.books, {this.hasReachedMax = false});

  @override
  // <-- PERUBAHAN: Modifikasi props
  List<Object> get props => [books, hasReachedMax];
}

class BookLibraryError extends BookLibraryState {
  final String message;
  const BookLibraryError(this.message);
  @override
  List<Object> get props => [message];
}