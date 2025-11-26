import 'package:equatable/equatable.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_collection.dart';

abstract class UserLibraryState extends Equatable {
  const UserLibraryState();
  @override
  List<Object> get props => [];
}

class UserLibraryInitial extends UserLibraryState {}

class UserLibraryLoading extends UserLibraryState {}

class UserLibraryLoaded extends UserLibraryState {
  final List<DigitalBook> favorites;
  final List<BookCollection> collections;

  const UserLibraryLoaded({
    this.favorites = const [],
    this.collections = const [],
  });

  @override
  List<Object> get props => [favorites, collections];
}

class UserLibraryError extends UserLibraryState {
  final String message;
  const UserLibraryError(this.message);
  @override
  List<Object> get props => [message];
}