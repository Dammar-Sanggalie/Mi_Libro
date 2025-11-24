// lib/repositories/api_book_repository.dart

import 'package:dio/dio.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

class ApiBookRepository implements BookRepository {
  // Base URL Gutendex
  final String _baseUrl = 'https://gutendex.com';
  late final Dio _dio;

  ApiBookRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
        },
        // Gutendex kadang agak lambat karena traffic tinggi, kita beri waktu lebih
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  @override
  Future<List<DigitalBook>> getInitialBooks({required int offset, required int number}) async {
    try {
      // LOGIC PAGINATION:
      // Gutendex menggunakan sistem 'page' (1 page = 32 buku).
      // Cubit Anda mengirim offset (0, 32, 64...).
      // Rumus: (0/32)+1 = Page 1. (32/32)+1 = Page 2.
      int page = (offset / 32).floor() + 1;

      print('[Gutendex] Fetching Books (Page $page)...');

      final response = await _dio.get(
        '/books',
        queryParameters: {
          'page': page,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['results'] ?? [];
        
        // Filter hanya buku yang punya file EPUB (biar bisa dibaca)
        final books = results
            .map((e) => DigitalBook.fromGutendex(e))
            .where((book) => book.isReadable) // Hanya ambil yang bisa dibaca
            .toList();

        print('[Gutendex] Success: Got ${books.length} books.');
        return books;
      } else {
        throw Exception('Failed to load books (Status: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[Gutendex] DioError: ${e.message}');
      throw Exception('Connection error: ${e.message}');
    } catch (e) {
      print('[Gutendex] Error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<DigitalBook>> searchBooks(String query) async {
    try {
      print('[Gutendex] Searching for: $query');

      // Ganti spasi dengan %20 dilakukan otomatis oleh Dio
      final response = await _dio.get(
        '/books',
        queryParameters: {
          'search': query,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['results'] ?? [];

        final books = results
            .map((e) => DigitalBook.fromGutendex(e))
            .where((book) => book.isReadable)
            .toList();

        print('[Gutendex] Search Found: ${books.length} books.');
        return books;
      } else {
        throw Exception('Search failed (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('[Gutendex] Search Error: $e');
      throw Exception('Search error: $e');
    }
  }

  @override
  Future<DigitalBook> getBookDetails(int bookId) async {
    try {
      print('[Gutendex] Fetching Detail ID: $bookId');

      final response = await _dio.get('/books/$bookId');

      if (response.statusCode == 200) {
        final data = response.data;
        return DigitalBook.fromGutendex(data);
      } else {
        throw Exception('Detail failed (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('[Gutendex] Detail Error: $e');
      throw Exception('Failed to fetch book details');
    }
  }
}