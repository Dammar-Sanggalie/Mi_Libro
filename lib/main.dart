// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:perpustakaan_mini/presentation/cubit/book_library_cubit.dart';
import 'package:perpustakaan_mini/presentation/cubit/book_search_cubit.dart';
import 'package:perpustakaan_mini/presentation/cubit/user_library_cubit.dart';

import 'package:perpustakaan_mini/data/datasources/book_remote_data_source.dart';
import 'package:perpustakaan_mini/data/datasources/book_local_data_source.dart';
import 'package:perpustakaan_mini/data/repositories/book_repository_impl.dart';

import 'package:perpustakaan_mini/domain/repositories/book_repository.dart';
import 'package:perpustakaan_mini/domain/usecases/get_initial_books.dart';
import 'package:perpustakaan_mini/domain/usecases/search_books.dart';
import 'package:perpustakaan_mini/domain/usecases/get_favorites.dart';
import 'package:perpustakaan_mini/domain/usecases/toggle_favorite.dart';
import 'package:perpustakaan_mini/domain/usecases/get_collections.dart';
import 'package:perpustakaan_mini/domain/usecases/save_collections.dart';

// IMPORT ROUTER BARU
import 'package:perpustakaan_mini/presentation/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 1. Create Data Sources
  final bookRemoteDataSource = BookRemoteDataSourceImpl();
  final bookLocalDataSource = BookLocalDataSourceImpl(sharedPreferences: prefs);

  // 2. Create Repository
  final bookRepository = BookRepositoryImpl(
    remoteDataSource: bookRemoteDataSource,
    localDataSource: bookLocalDataSource,
  );

  // 3. Create UseCases
  final getInitialBooks = GetInitialBooks(bookRepository);
  final searchBooks = SearchBooks(bookRepository);
  final getFavorites = GetFavorites(bookRepository);
  final toggleFavorite = ToggleFavorite(bookRepository);
  final getCollections = GetCollections(bookRepository);
  final saveCollections = SaveCollections(bookRepository);

  runApp(
    RepositoryProvider<BookRepository>.value(
      value: bookRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<BookSearchCubit>(
            create: (context) => BookSearchCubit(searchBooks),
          ),
          BlocProvider<BookLibraryCubit>(
            create: (context) => BookLibraryCubit(getInitialBooks),
          ),
          BlocProvider<UserLibraryCubit>(
            create: (context) => UserLibraryCubit(
              getFavorites: getFavorites,
              toggleFavorite: toggleFavorite,
              getCollections: getCollections,
              saveCollections: saveCollections,
            )..loadLibrary(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MENGGUNAKAN MATERIALAPP.ROUTER
    return MaterialApp.router(
      title: 'Digital Library',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'Inter',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      // HUBUNGKAN DENGAN GO_ROUTER CONFIG
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
