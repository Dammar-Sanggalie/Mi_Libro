import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/book_model.dart';
import '../../domain/entities/book.dart';

abstract class BookRemoteDataSource {
  Future<BookPage> getInitialBooks({required int offset, required int number});
  Future<List<BookModel>> searchBooks(String query);
  Future<BookModel> getBookDetails(int bookId);
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {
  final Dio dio;

  // Constructor ini sudah BENAR untuk testing.
  // Jika dioClient kosong (saat app jalan), dia buat Dio baru.
  // Jika dioClient diisi (saat testing), dia pakai yang dikirim.
  BookRemoteDataSourceImpl({Dio? dioClient})
      : dio = dioClient ??
            Dio(
              BaseOptions(
                baseUrl: 'https://gutendex.com',
                headers: {'Accept': 'application/json'},
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
              ),
            );

  @override
  Future<BookPage> getInitialBooks(
      {required int offset, required int number}) async {
    try {
      // Logic halaman (offset 0 -> page 1, offset 32 -> page 2)
      int page = (offset / 32).floor() + 1;
      
      final response = await dio.get('/books', queryParameters: {'page': page});

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['results'] ?? [];
        final int totalCount = data['count'] ?? 0;

        final books = results
            .map((e) => BookModel.fromGutendex(e))
            .where((book) => book.isReadable)
            .toList();

        return BookPage(books: books, totalCount: totalCount);
      } else {
        throw Exception('Failed to load books (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final response = await dio.get('/books', queryParameters: {'search': query});

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['results'] ?? [];

        return results
            .map((e) => BookModel.fromGutendex(e))
            .where((book) => book.isReadable)
            .toList();
      } else {
        throw Exception('Search failed (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  @override
  Future<BookModel> getBookDetails(int bookId) async {
    try {
      final response = await dio.get('/books/$bookId');

      if (response.statusCode == 200) {
        return BookModel.fromGutendex(response.data);
      } else {
        throw Exception('Detail failed (Status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to fetch book details');
    }
  }
}