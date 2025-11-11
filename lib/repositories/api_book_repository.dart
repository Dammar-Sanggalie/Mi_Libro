// lib/repositories/api_book_repository.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

class ApiBookRepository implements BookRepository {
  final String _apiKey = '8393a2463a6743b7a8c4b86fa4fae970';
  final String _baseUrl = 'https://api.bigbookapi.com';

  late final Dio _dio;

  ApiBookRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
        },
        connectTimeout: Duration(seconds: 15),
        receiveTimeout: Duration(seconds: 15),
      ),
    );
  }

  @override
  // <-- PERUBAHAN: Menerima parameter offset dan number
  Future<List<DigitalBook>> getInitialBooks(
      {required int offset, required int number}) async {
    const String defaultQuery = "fiction";
    try {
      print(
          '[API Call - Dio] (Initial Books) Calling: /search-books?query=$defaultQuery&number=$number&offset=$offset'); // <-- PERUBAHAN: Log baru

      final response = await _dio.get(
        '/search-books',
        queryParameters: {
          'query': defaultQuery,
          'number': number.toString(), // <-- PERUBAHAN: Gunakan parameter
          'offset': offset.toString(), // <-- PERUBAHAN: Gunakan parameter
          'api-key': _apiKey,
        },
      );

      print(
          '[API Call - Dio] (Initial Books) Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['books'] ?? [];
        print(
            '[API Call - Dio] (Initial Books) Success: Found ${results.length} books.');

        final books = results
            .where((e) => e is List && e.isNotEmpty)
            .map((e) {
              final bookData = e[0];
              if (bookData is Map<String, dynamic>) {
                return DigitalBook.fromJson(bookData);
              }
              return null;
            })
            .whereType<DigitalBook>()
            .toList();

        print('[API Call - Dio] (Initial Books) Parsed ${books.length} books.');
        return books;
      } else {
        print('[API Call - Dio] (Initial Books) Error Body: ${response.data}');
        throw Exception(
            'Gagal memuat buku awal (Status Code: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[API Call - Dio] (Initial Books) REPOSITORY ERROR: ${e.message}');
      if (e.response != null) {
        print('[API Call - Dio] Error Response Data: ${e.response?.data}');
      }
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      print(
          '[API Call - Dio] (Initial Books) REPOSITORY GENERIC ERROR: ${e.toString()}');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  @override
  Future<List<DigitalBook>> searchBooks(String query) async {
    try {
      print(
          '[API Call - Dio] (Search) Calling: /search-books?query=$query'); // <-- PERUBAHAN: 'query'

      final response = await _dio.get(
        '/search-books',
        queryParameters: {
          'query': query, // <-- PERUBAHAN: dari 'name' ke 'query'
          'number': '21',
          'api-key': _apiKey,
        },
      );

      print('[API Call - Dio] (Search) Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        final List results = data['books'] ?? [];
        print(
            '[API Call - Dio] (Search) Success: Found ${results.length} books.');

        final books = results
            .where((e) => e is List && e.isNotEmpty)
            .map((e) {
              final bookData = e[0];
              if (bookData is Map<String, dynamic>) {
                return DigitalBook.fromJson(bookData);
              }
              return null;
            })
            .whereType<DigitalBook>()
            .toList();

        print('[API Call - Dio] (Search) Parsed ${books.length} books.');
        return books;
      } else {
        print('[API Call - Dio] (Search) Error Body: ${response.data}');
        throw Exception(
            'Gagal mencari buku (Status Code: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[API Call - Dio] (Search) REPOSITORY ERROR: ${e.message}');
      if (e.response != null) {
        print('[API Call - Dio] Error Response Data: ${e.response?.data}');
      }
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      print(
          '[API Call - Dio] (Search) REPOSITORY GENERIC ERROR: ${e.toString()}');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  // <-- PERUBAHAN: Implementasi metode baru
  @override
  Future<DigitalBook> getBookDetails(int bookId) async {
    try {
      print('[API Call - Dio] (Details) Calling: /$bookId');

      final response = await _dio.get(
        '/$bookId', // Panggil endpoint ID
        queryParameters: {
          'api-key': _apiKey, // Tetap gunakan API key
        },
      );

      print('[API Call - Dio] (Details) Status Code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Gunakan factory 'fromJsonDetail' yang baru
          final book = DigitalBook.fromJsonDetail(data);
          print('[API Call - Dio] (Details) Parsed ${book.title}.');
          return book;
        } else {
          print(
              '[API Call - Dio] (Details) Error: Invalid data format received.');
          throw Exception('Invalid data format received from API');
        }
      } else {
        print('[API Call - Dio] (Details) Error Body: ${response.data}');
        throw Exception(
            'Gagal memuat detail (Status Code: ${response.statusCode})');
      }
    } on DioException catch (e) {
      print('[API Call - Dio] (Details) REPOSITORY ERROR: ${e.message}');
      if (e.response != null) {
        print('[API Call - Dio] Error Response Data: ${e.response?.data}');
      }
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      print(
          '[API Call - Dio] (Details) REPOSITORY GENERIC ERROR: ${e.toString()}');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}