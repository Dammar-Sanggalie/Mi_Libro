import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/book.dart';
import '../pages/splash_screen.dart';
import '../pages/login_screen.dart';
import '../pages/home_screen.dart';
import '../pages/book_library_screen.dart';
import '../pages/favorites_screen.dart';
import '../pages/profile_screen.dart';
import '../pages/book_detail_screen.dart';
import '../pages/epub_player_screen.dart';
import '../pages/category_books_screen.dart';

// Key untuk Navigator agar transisi halaman detail menutupi BottomBar
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // 1. Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 3. SHELL ROUTE (Untuk Bottom Navigation Bar)
      // Ini membuat URL berubah saat pindah tab (/home -> /favorites)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // HomeScreen sekarang bertugas sebagai "Wrapper"
          return HomeScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home / Library
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => BookLibraryScreen(),
              ),
            ],
          ),
          // Branch 1: Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                name: 'favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // 4. Detail Pages (Di luar Shell agar menutupi Bottom Bar)
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey, // Penting agar full screen
        path: '/book/:id',
        name: 'book-detail',
        builder: (context, state) {
          final bookId = state.pathParameters['id']!;
          final book = state.extra as DigitalBook?;
          return EnhancedBookDetailScreen(
            bookId: bookId,
            initialBook: book,
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/read',
        name: 'read',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return EpubReaderScreen(
            url: args['url'] as String,
            title: args['title'] as String,
          );
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/category/:category',
        name: 'category-books',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          return CategoryBooksScreen(category: category);
        },
      ),
    ],
  );
}
