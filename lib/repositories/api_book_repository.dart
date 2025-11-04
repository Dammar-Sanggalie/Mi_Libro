import 'dart:convert';
import 'package:dio/dio.dart'; // <-- Impor Dio
import 'package:perpustakaan_mini/models/book_model.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';

// Implementasi repository yang sekarang menggunakan DIO
class ApiBookRepository implements BookRepository {
  final String _apiKey = '8393a2463a6743b7a8c4b86fa4fae970';
  final String _baseUrl = 'https://api.bigbookapi.com';

  // 1. Buat instance Dio
  late final Dio _dio;

  // 2. Konfigurasi Dio di constructor
  ApiBookRepository() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Authorization': 'Bearer $_apiKey', // Header default
          'Accept': 'application/json',
        },
        connectTimeout: Duration(seconds: 15), // Timeout koneksi
        receiveTimeout: Duration(seconds: 15), // Timeout menerima data
      ),
    );
  }

  @override
  Future<List<DigitalBook>> getInitialBooks() async {
    // Metode ini tidak berubah, akan otomatis memanggil searchBooks versi Dio
    return searchBooks("technology");
  }

  @override
  Future<List<DigitalBook>> searchBooks(String query) async {
    try {
      print('[API Call - Dio] Calling: /search-books?query=$query');

      // 3. Gunakan dio.get()
      // Kita hanya perlu path-nya (/search-books) karena baseUrl sudah diatur
      final response = await _dio.get(
        '/search-books',
        queryParameters: {
          'query': query,
          'number': '21',
        },
      );

      print('[API Call - Dio] Status Code: ${response.statusCode}');

      // 4. Dio otomatis melakukan jsonDecode. Gunakan response.data
      if (response.statusCode == 200) {
        final data = response.data; // Tidak perlu json.decode
        final List results = data['books'] ?? [];
        print('[API Call - Dio] Success: Found ${results.length} books.');
        return results.map((e) => DigitalBook.fromJson(e)).toList();
      } else {
        print('[API Call - Dio] Error Body: ${response.data}');
        throw Exception(
            'Gagal mencari buku (Status Code: ${response.statusCode})');
      }
    } on DioException catch (e) {
      // 5. Tangani DioException (error spesifik dari Dio)
      print('[API Call - Dio] REPOSITORY ERROR: ${e.message}');
      if (e.response != null) {
        print('[API Call - Dio] Error Response Data: ${e.response?.data}');
      }
      throw Exception('Gagal terhubung ke server: ${e.message}');
    } catch (e) {
      // 6. Tangani error lainnya
      print('[API Call - Dio] REPOSITORY GENERIC ERROR: ${e.toString()}');
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }
}
