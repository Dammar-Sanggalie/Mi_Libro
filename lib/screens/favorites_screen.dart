import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/book_model.dart';
import '../widgets/compact_book_card.dart';

// Enhanced Favorites Screen
class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Filter buku favorit dari AppData.books berdasarkan favoriteBooks (Set<String>)
    List<DigitalBook> favoriteBooks = AppData.books
        .where((book) => AppData.favoriteBooks.contains(book.title))
        .toList();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.red.shade400, Colors.pink.shade400],
                      ).createShader(bounds),
                      child: Text(
                        'My Favorites',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      '${favoriteBooks.length} books saved',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              // Favorites Content
              Expanded(
                child: favoriteBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.pink.shade400,
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.favorite_rounded,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              'No favorites yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start adding books to your favorites\nto build your personal collection',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: favoriteBooks.length,
                        itemBuilder: (context, index) {
                          return CompactBookCard(
                            book: favoriteBooks[index],
                            colorIndex: index % AppData.primaryColors.length,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
