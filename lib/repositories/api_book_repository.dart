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
  Future<List<DigitalBook>> getInitialBooks() async {
    const String defaultQuery = "fiction";
    try {
      print(
          '[API Call - Dio] (Initial Books) Calling: /search-books?name=$defaultQuery&number=10');

      final response = await _dio.get(
        '/search-books',
        queryParameters: {
          'name': defaultQuery,
          'number': '10',
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

        // --- INI PERBAIKANNYA ---
        // 1. Pastikan 'e' adalah List dan tidak kosong
        // 2. Ambil elemen pertama 'e[0]' dan pastikan itu adalah Map
        // 3. Kirim 'e[0]' ke fromJson
        final books = results
            .where((e) => e is List && e.isNotEmpty) // 1
            .map((e) {
              final bookData = e[0]; // 2
              if (bookData is Map<String, dynamic>) {
                return DigitalBook.fromJson(bookData); // 3
              }
              return null; // Abaikan jika datanya tidak valid
            })
            .whereType<DigitalBook>() // Hanya ambil yang tidak null
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
      print('[API Call - Dio] (Search) Calling: /search-books?name=$query');

      final response = await _dio.get(
        '/search-books',
        queryParameters: {
          'name': query,
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

        // --- INI PERBAIKANNYA (Sama seperti di atas) ---
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
}
