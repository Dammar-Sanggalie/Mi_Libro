import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:perpustakaan_mini/data/datasources/book_remote_data_source.dart';
import 'package:perpustakaan_mini/data/models/book_model.dart';
import 'package:perpustakaan_mini/domain/entities/book.dart';

// Generate Mock Dio
@GenerateMocks([Dio])
import 'book_remote_data_source_test.mocks.dart';

void main() {
  late BookRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    // DI SINI KITA SUNTIKKAN MOCK DIO
    dataSource = BookRemoteDataSourceImpl(dioClient: mockDio);
  });

  group('getInitialBooks', () {
    final tJson = {
      "count": 100,
      "results": [
        {
          "id": 1,
          "title": "Test Book",
          "authors": [{"name": "Author", "birth_year": 1900}],
          "formats": {"application/epub+zip": "http://epub"},
          "download_count": 10
        }
      ]
    };

    test('harus mengembalikan BookPage ketika status code 200', () async {
      // ARRANGE
      // Kita setel Mock Dio supaya kalau dipanggil .get('/books'),
      // dia jawab dengan Response sukses dan data palsu (tJson)
      when(mockDio.get(
        any, // Path apa saja (atau '/books')
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: tJson,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/books'),
          ));

      // ACT
      final result = await dataSource.getInitialBooks(offset: 0, number: 32);

      // ASSERT
      expect(result, isA<BookPage>());
      expect(result.books.length, 1);
      expect(result.books.first.title, 'Test Book');
    });

    test('harus melempar Exception ketika status code 404', () async {
      // ARRANGE
      when(mockDio.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response(
            data: 'Not Found',
            statusCode: 404,
            requestOptions: RequestOptions(path: '/books'),
          ));

      // ACT & ASSERT
      final call = dataSource.getInitialBooks;
      
      // Kita cek apakah fungsi tersebut melempar error
      expect(
        () => call(offset: 0, number: 32),
        throwsA(isA<Exception>()),
      );
    });
  });
}