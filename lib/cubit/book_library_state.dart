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
  const BookLibraryLoaded(this.books);
  @override
  List<Object> get props => [books];
}

class BookLibraryError extends BookLibraryState {
  final String message;
  const BookLibraryError(this.message);
  @override
  List<Object> get props => [message];
}
