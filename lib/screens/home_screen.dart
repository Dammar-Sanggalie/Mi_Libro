import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perpustakaan_mini/cubit/book_library_cubit.dart';
import 'package:perpustakaan_mini/cubit/book_search_cubit.dart';
import 'package:perpustakaan_mini/repositories/api_book_repository.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';
import 'book_library_screen.dart';
import '../screens/compact_book_card.dart'; // Updated import path
import 'favorites_screen.dart';
import 'profile_screen.dart';

// Enhanced Home Screen with Bottom Navigation AND Providers
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    BookLibraryScreen(),
    CategoriesScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // --- INI ADALAH PERUBAHAN UTAMA ---
    // Kita sediakan Repository dan Cubit di sini, BUKAN di main.dart
    // Ini berarti semua _screens (termasuk BookLibraryScreen) dapat mengaksesnya.
    return RepositoryProvider<BookRepository>(
      create: (context) => ApiBookRepository(),
      child: MultiBlocProvider(
        providers: [
          // Cubit untuk Halaman Utama (Library)
          BlocProvider<BookLibraryCubit>(
            create: (context) => BookLibraryCubit(
              context.read<BookRepository>(),
            ),
          ),
          // Cubit untuk Halaman Pencarian (Search)
          BlocProvider<BookSearchCubit>(
            create: (context) => BookSearchCubit(
              context.read<BookRepository>(),
            ),
          ),
        ],
        child: Scaffold(
          body: _screens[_currentIndex],
          extendBody: true,
          bottomNavigationBar: Container(
            margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) => setState(() => _currentIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: Color(0xFF6366F1),
                unselectedItemColor: Colors.white.withOpacity(0.4),
                elevation: 0,
                selectedFontSize: 12,
                unselectedFontSize: 11,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_rounded),
                    label: 'Explore',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.favorite_rounded),
                    label: 'Favorites',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
