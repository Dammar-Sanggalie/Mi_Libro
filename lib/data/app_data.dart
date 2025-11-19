import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/book_model.dart';
import '../models/user_model.dart';

// Enhanced Global Data Management
class AppData {
  static List<User> users = [
    User('dammar', 'miegoreng', 'dammar@email.com'),
    User('1', '1', 'sanggalie@email.com'),
  ];

  static List<DigitalBook> books = [
    DigitalBook(
      1001, // <-- PERUBAHAN: Menambahkan Dummy ID
      'The Art of Code',
      'Alexander Sterling',
      2024,
      'Programming',
      'Master the elegant craft of writing beautiful, maintainable code that stands the test of time. Learn advanced patterns, clean architecture principles, and best practices.',
      '5.2 MB',
      'PDF',
      'https://plus.unsplash.com/premium_photo-1678566111481-8e275550b700?q=80&w=387&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://drive.google.com/file/d/1_IZ_cMw98HRZO2Tj79UAFKl6mYtGBgPu/view?usp=drive_link',
      rating: 4.8,
      downloads: 12500,
    ),
    DigitalBook(
      1002, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Quantum Computing Fundamentals',
      'Dr. Elena Vasquez',
      2023,
      'Science',
      'Journey through the revolutionary world of quantum computing, exploring qubits, superposition, and quantum algorithms that will reshape our future.',
      '8.7 MB',
      'EPUB',
      'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1eyRUz4icH9EBQlTX8Oh7HqgmkNeHzprf/view?usp=drive_link',
      rating: 4.6,
      downloads: 8900,
    ),
    DigitalBook(
      1003, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Digital Transformation Strategy',
      'Marcus Chen',
      2024,
      'Business',
      'Build and scale your digital business in the age of AI and automation. Strategic frameworks for modern enterprises.',
      '4.1 MB',
      'PDF',
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1RycnkPCzrpwhelOzHnojbkyRDoTorOGm/view?usp=drive_link',
      rating: 4.7,
      downloads: 15200,
    ),
    DigitalBook(
      1004, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Machine Learning Mastery',
      'Sarah Thompson',
      2023,
      'Technology',
      'Deep dive into artificial intelligence and machine learning with practical implementations and real-world case studies.',
      '6.8 MB',
      'PDF',
      'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1ytUYnJn3k5-TLIsn97QMVFdIZPoEKKr9/view?usp=drive_link',
      rating: 4.9,
      downloads: 22100,
    ),
    DigitalBook(
      1005, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Astrophysics Today',
      'Prof. James Wright',
      2024,
      'Science',
      'Explore the vast universe and the latest discoveries in astrophysics, from black holes to dark matter.',
      '9.2 MB',
      'EPUB',
      'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/15MPZZ0yRncFZtiASoTDxJdAoTIzvG17-/view?usp=drive_link',
      rating: 4.5,
      downloads: 7800,
    ),
    DigitalBook(
      1006, // <-- PERUBAHAN: Menambahkan Dummy ID
      'UX Design Principles',
      'Isabella Rodriguez',
      2023,
      'Design',
      'Revolutionary approaches to user experience design and creative problem solving in the digital age.',
      '7.3 MB',
      'PDF',
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1UEJUvUSls5KJKGI7hiTnMmWRhhJjXk-3/view?usp=drive_link',
      rating: 4.4,
      downloads: 11300,
    ),
    DigitalBook(
      1007, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Blockchain & Web3',
      'David Kim',
      2024,
      'Technology',
      'Understanding decentralized technologies, cryptocurrencies, and their impact on future economics.',
      '5.9 MB',
      'PDF',
      'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1sX7kifbspQzDHug7XbYuT-6dBz5JC6Hp/view?usp=drive_link',
      rating: 4.3,
      downloads: 9600,
    ),
    DigitalBook(
      1008, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Mindful Leadership',
      'Dr. Amelia Foster',
      2023,
      'Psychology',
      'Transform your leadership style with emotional intelligence and mindfulness practices for modern managers.',
      '4.6 MB',
      'EPUB',
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1PSuyRfiSXGM2CgTZqopCIw9m37hr3zv7/view?usp=drive_link',
      rating: 4.6,
      downloads: 6700,
    ),
    DigitalBook(
      1009, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Future Tech Trends',
      'Ryan Matthews',
      2024,
      'Futurism',
      'Predictions and insights into the technologies that will shape our tomorrow, from AI to biotechnology.',
      '6.4 MB',
      'PDF',
      'https://images.unsplash.com/photo-1621870616319-eeb7fdf31234?q=80&w=327&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://drive.google.com/file/d/1jNe6gXeFLNtkCU2NkNgpNj1wkg3u8XjL/view?usp=drive_link',
      rating: 4.2,
      downloads: 8400,
    ),
    DigitalBook(
      1010, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Data Science Excellence',
      'Lisa Zhang',
      2023,
      'Analytics',
      'Harness the power of big data and analytics to drive business transformation and innovation.',
      '5.8 MB',
      'EPUB',
      'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1rF1hcSAUNJf5Zou0GcLP9_cWTv-N6Vsa/view?usp=drive_link',
      rating: 4.7,
      downloads: 13900,
    ),
    DigitalBook(
      1011, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Cybersecurity Essentials',
      'Michael Torres',
      2024,
      'Security',
      'Comprehensive guide to modern cybersecurity practices, threat detection, and digital protection strategies.',
      '7.1 MB',
      'PDF',
      'https://images.unsplash.com/photo-1563986768494-4dee2763ff3f?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1UH_0PMOxvj0y0DxwHhWdEAT8Ol9Jo-k2/view?usp=drive_link',
      rating: 4.5,
      downloads: 10200,
    ),
    DigitalBook(
      1012, // <-- PERUBAHAN: Menambahkan Dummy ID
      'Creative Writing Mastery',
      'Emma Clarke',
      2023,
      'Literature',
      'Unlock your creative potential with advanced writing techniques and storytelling methodologies.',
      '3.9 MB',
      'EPUB',
      'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=300&h=400&fit=crop',
      'https://drive.google.com/file/d/1To7lpiveI5ASaGxNai1yrVLdzn3pF21_/view?usp=drive_link',
      rating: 4.8,
      downloads: 5600,
    ),
  ];

  static User? currentUser;
  static Set<String> favoriteBooks = {};

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

  // New methods for persistent storage
  static Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteBooks', favoriteBooks.toList());
  }

  static Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoriteList = prefs.getStringList('favoriteBooks') ?? [];
    favoriteBooks = favoriteList.toSet();
  }

  // Add new static field for storing user ratings
  static Map<String, double> userRatings = {};

  // Add new methods for rating persistence
  static Future<void> saveRating(String bookTitle, double rating) async {
    final prefs = await SharedPreferences.getInstance();
    userRatings[bookTitle] = rating;

    // Convert Map to a format that can be stored in SharedPreferences
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

  // Enhanced methods
  static List<String> get categories {
    return books.map((book) => book.category).toSet().toList()..sort();
  }

  static List<DigitalBook> getBooksByCategory(String category) {
    return books.where((book) => book.category == category).toList();
  }

  static List<DigitalBook> getTopRatedBooks() {
    List<DigitalBook> sortedBooks = List.from(books);
    sortedBooks.sort((a, b) => b.rating.compareTo(a.rating));
    return sortedBooks.take(5).toList();
  }

  static List<DigitalBook> getMostDownloadedBooks() {
    List<DigitalBook> sortedBooks = List.from(books);
    sortedBooks.sort((a, b) => b.downloads.compareTo(a.downloads));
    return sortedBooks.take(5).toList();
  }

  // Add method to get user rating for a specific book
  static double getUserRating(String bookTitle) {
    return userRatings[bookTitle] ?? 0.0;
  }
}