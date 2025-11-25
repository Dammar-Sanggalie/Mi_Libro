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

  static List<DigitalBook> books = [
    DigitalBook(
      1001,
      'The Art of Code',
      'Alexander Sterling',
      2024,
      'Programming',
      'Master the elegant craft of writing beautiful, maintainable code.',
      'https://images.unsplash.com/photo-1587620962725-abab7fe55159?w=300&fit=crop',
      '',
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

  // Favorites Data
  static Set<String> favoriteBooks = {}; // Simpan ID saja
  static List<DigitalBook> favoriteBooksData = []; // Simpan full data

  // --- NEW: Playlist Collections ---
  static List<BookCollection> userCollections = [];

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

  // --- FAVORITES MANAGEMENT ---
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

  // --- COLLECTION / PLAYLIST MANAGEMENT ---
  static Future<void> saveCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      userCollections.map((c) => c.toJson()).toList(),
    );
    await prefs.setString('userCollections', encodedData);
  }

  static Future<void> loadCollections() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('userCollections');

    userCollections = [];
    if (encodedData != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(encodedData);
        userCollections =
            decodedList.map((item) => BookCollection.fromJson(item)).toList();
      } catch (e) {
        print('Error loading collections: $e');
      }
    }
  }

  // Helper: Ambil object DigitalBook berdasarkan ID
  static DigitalBook? getBookById(String id) {
    // Cari di favoriteBooksData dulu (karena ini data lokal paling lengkap)
    try {
      return favoriteBooksData.firstWhere((b) => b.id.toString() == id);
    } catch (e) {
      // Jika tidak ada di favorit, cari di dummy books
      try {
        return books.firstWhere((b) => b.id.toString() == id);
      } catch (e) {
        return null;
      }
    }
  }

  // --- RATINGS MANAGEMENT ---
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

  // Initialization
  static Future<void> initializeAppData() async {
    await loadFavorites();
    await loadRatings();
    await loadCollections(); // Load collections juga
  }

  // Clear all saved data (for debugging/reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favoriteBooks');
    await prefs.remove('favoriteBooksData');
    await prefs.remove('userRatings');
    await prefs.remove('userCollections');
    favoriteBooks.clear();
    favoriteBooksData.clear();
    userRatings.clear();
    userCollections.clear();
  }

  static List<String> get categories {
    return books.map((book) => book.category).toSet().toList()..sort();
  }

  static List<DigitalBook> getBooksByCategory(String category) {
    return books.where((book) => book.category == category).toList();
  }
}
