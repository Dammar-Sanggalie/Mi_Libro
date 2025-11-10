import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:perpustakaan_mini/cubit/book_library_cubit.dart';
import 'package:perpustakaan_mini/cubit/book_search_cubit.dart';
import 'package:perpustakaan_mini/repositories/api_book_repository.dart';
import 'package:perpustakaan_mini/screens/splash_screen.dart';
import 'package:perpustakaan_mini/data/app_data.dart';

void main() async {
  // Initialize required services
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Load persistent data
  await AppData.loadFavorites();
  await AppData.loadRatings();

  final ApiBookRepository apiBookRepository = ApiBookRepository();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<BookSearchCubit>(
          create: (context) => BookSearchCubit(apiBookRepository),
        ),
        BlocProvider<BookLibraryCubit>(
          create: (context) => BookLibraryCubit(apiBookRepository),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
