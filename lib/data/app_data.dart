import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book_model.dart';
import '../models/user_model.dart';

// Enhanced Global Data Management
class AppData {
  static List<User> users = [
    User('dammar', 'miegoreng', 'dammar@email.com'),
    User('sanggalie', 'nasipecel', 'sanggalie@email.com'),
  ];

  // Dummy Data disesuaikan dengan Constructor DigitalBook baru:
  // DigitalBook(id, title, author, year, category, description, imageUrl, epubUrl, {downloads, languages})
  static List<DigitalBook> books = [
    DigitalBook(
      1001,
      'The Art of Code',
      'Alexander Sterling',
      2024,
      'Programming',
      'Master the elegant craft of writing beautiful, maintainable code.',
      'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=300&fit=crop',
      '', // Kosongkan epubUrl untuk dummy
      downloads: 12500,
      languages: ['en'],
    ),
    DigitalBook(
      1002,
      'Quantum Computing',
      'Dr. Elena Vasquez',
      2023,
      'Science',
      'Journey through the revolutionary world of quantum computing.',
      'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=300&fit=crop',
      '',
      downloads: 8900,
      languages: ['en'],
    ),
    DigitalBook(
      1003,
      'Digital Strategy',
      'Marcus Chen',
      2024,
      'Business',
      'Build and scale your digital business.',
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&fit=crop',
      '',
      downloads: 15200,
      languages: ['en'],
    ),
    DigitalBook(
      1004,
      'Machine Learning',
      'Sarah Thompson',
      2023,
      'Technology',
      'Deep dive into artificial intelligence.',
      'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=300&fit=crop',
      '',
      downloads: 22100,
      languages: ['fr'],
    ),
    DigitalBook(
      1005,
      'Astrophysics Today',
      'Prof. James Wright',
      2024,
      'Science',
      'Explore the vast universe.',
      'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=300&fit=crop',
      '',
      downloads: 7800,
      languages: ['en'],
    ),
  ];

  static User? currentUser;
  static Set<String> favoriteBooks = {}; // Simpan ID saja untuk favorites
  static List<DigitalBook> favoriteBooksData = []; // Simpan full data favorit

  static List<Color> primaryColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF84CC16), // Lime
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
  ];

  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan ID saja
    await prefs.setStringList('favoriteBooks', favoriteBooks.toList());
    // Simpan full data favorit sebagai JSON
    final jsonBooks = favoriteBooksData
        .map((book) => jsonEncode({
              'id': book.id,
              'title': book.title,
              'author': book.author,
              'year': book.year,
              'category': book.category,
              'description': book.description,
              'imageUrl': book.imageUrl,
              'epubUrl': book.epubUrl,
              'downloads': book.downloads,
              'languages': book.languages,
            }))
        .toList();
    await prefs.setStringList('favoriteBooksData', jsonBooks);
  }

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    // Load ID saja
    final favoriteList = prefs.getStringList('favoriteBooks') ?? [];
    favoriteBooks = favoriteList.toSet();

    // Load full data favorit dari JSON
    final jsonBooks = prefs.getStringList('favoriteBooksData') ?? [];
    favoriteBooksData = [];
    for (var jsonStr in jsonBooks) {
      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        favoriteBooksData.add(DigitalBook(
          data['id'] as int,
          data['title'] as String,
          data['author'] as String,
          data['year'] as int,
          data['category'] as String,
          data['description'] as String,
          data['imageUrl'] as String,
          data['epubUrl'] as String,
          downloads: data['downloads'] as int? ?? 0,
          languages: List<String>.from(data['languages'] as List? ?? []),
        ));
      } catch (e) {
        print('Error loading favorite book: $e');
      }
    }
  }

  // Rating menggunakan bookId sebagai key, bukan title
  static Map<String, double> userRatings = {};

  static Future<void> saveRating(String bookId, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    userRatings[bookId] = rating;
    final ratings =
        userRatings.map((key, value) => MapEntry(key, value.toString()));
    await prefs.setString('userRatings', jsonEncode(ratings));
  }

  static Future<void> loadRatings() async {
    final prefs = await SharedPreferences.getInstance();
    final ratingsStr = prefs.getString('userRatings');
    if (ratingsStr != null) {
      final ratingsMap = jsonDecode(ratingsStr) as Map<String, dynamic>;
      userRatings =
          ratingsMap.map((key, value) => MapEntry(key, double.parse(value)));
    }
  }

  static double getUserRating(String bookId) {
    return userRatings[bookId] ?? 0.0;
  }

  // Method untuk ensure data selalu ter-load dari SharedPreferences
  static Future<void> initializeAppData() async {
    await loadFavorites();
    await loadRatings();
  }

  // Clear all saved data (for debugging/reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteBooks');
    await prefs.remove('userRatings');
    favoriteBooks.clear();
    userRatings.clear();
  }

  static List<String> get categories {
    return books.map((book) => book.category).toSet().toList()..sort();
  }

  static List<DigitalBook> getBooksByCategory(String category) {
    return books.where((book) => book.category == category).toList();
  }
}
