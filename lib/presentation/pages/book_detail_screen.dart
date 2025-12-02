// lib/presentation/pages/book_detail_screen.dart

import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:perpustakaan_mini/domain/repositories/book_repository.dart';
import '../../data/app_data.dart';
import '../../domain/entities/book.dart';
import '../cubit/user_library_cubit.dart';
import '../cubit/user_library_state.dart';

class EnhancedBookDetailScreen extends StatefulWidget {
  final String bookId;
  final DigitalBook? initialBook;

  const EnhancedBookDetailScreen({
    super.key,
    required this.bookId,
    this.initialBook,
  });

  @override
  _EnhancedBookDetailScreenState createState() =>
      _EnhancedBookDetailScreenState();
}

class _EnhancedBookDetailScreenState extends State<EnhancedBookDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DigitalBook? _book;
  bool _isLoading = true;
  String? _error;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();

    _book = widget.initialBook;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();

    if (_book == null) {
      _fetchBookDetails();
    } else {
      setState(() => _isLoading = false);
      _loadRating();
    }
  }

  Future<void> _loadRating() async {
    if (_book != null) {
      final rating =
          await context.read<BookRepository>().getRating(_book!.id.toString());
      if (mounted) setState(() => _userRating = rating);
    }
  }

  Future<void> _fetchBookDetails() async {
    final repo = context.read<BookRepository>();
    try {
      final int id = int.tryParse(widget.bookId) ?? 0;
      final fetchedBook = await repo.getBookDetails(id);

      if (mounted) {
        setState(() {
          _book = fetchedBook;
          _isLoading = false;
        });
        _loadRating();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (_book == null && widget.initialBook == null) {
            _error = "Gagal memuat detail buku.";
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    if (_book == null) return;
    context.read<UserLibraryCubit>().toggleFavoriteBook(_book!);
  }

  Future<void> _openReadLink() async {
    if (_book?.epubUrl == null || _book!.epubUrl.isEmpty) {
      _showError('No readable link available');
      return;
    }

    final url = _book!.epubUrl;

    if (_book!.isReadable) {
      context.push('/read', extra: {
        'url': url,
        'title': _book!.title,
      });
    } else {
      try {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showError('Could not launch browser');
        }
      } catch (e) {
        _showError('Error opening URL: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _book == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F23),
        body: Center(
            child: CircularProgressIndicator(color: Color(0xFF6366F1))),
      );
    }

    if (_book == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F23),
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
            child: Text(_error ?? 'Error loading book',
                style: const TextStyle(color: Colors.white))),
      );
    }

    final DigitalBook book = _book!;
    
    final isFavorite = context.select<UserLibraryCubit, bool>((cubit) {
      if (cubit.state is UserLibraryLoaded) {
        return (cubit.state as UserLibraryLoaded)
            .favorites
            .any((b) => b.id == book.id);
      }
      return false;
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      body: Stack(
        children: [
          // 1. BACKGROUND
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: const Color(0xFF0F0F23)),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: const Color(0xFF0F0F23).withOpacity(0.85),
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildGlassIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => context.pop(),
                      ),
                      const Text(
                        "Book Details",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildGlassIconButton(
                        // Gunakan Icons.favorite agar filled, warna putih jika tidak aktif
                        icon: Icons.favorite,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        onTap: _toggleFavorite,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            // Cover
                            Hero(
                              tag: 'book_cover_${book.id}',
                              child: Container(
                                width: 160,
                                height: 240,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.4),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: Colors.white10,
                                      child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2)),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Info
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 600),
                              child: Column(
                                children: [
                                  Text(
                                    book.title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    book.author,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // --- STATS ROW DENGAN BACKGROUND IKON ---
                            _buildStatsRow(book),

                            const SizedBox(height: 24),

                            // Description
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Description",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 800),
                                child: Text(
                                  book.description.isNotEmpty 
                                      ? book.description 
                                      : "No description available for this book.",
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.6,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Rating Input
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.05)),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    "Rate this book",
                                    style: TextStyle(color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInteractiveRatingBar(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF0F0F23).withOpacity(0.9),
                    const Color(0xFF0F0F23),
                  ],
                ),
              ),
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _openReadLink,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.menu_book_rounded, color: Colors.white),
                                SizedBox(width: 12),
                                Text(
                                  'Start Reading',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }

  // --- STATS ROW BARU (DENGAN BADGE BACKGROUND) ---
  Widget _buildStatsRow(DigitalBook book) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                "Rating", 
                _userRating > 0 ? _userRating.toString() : "-", 
                Icons.star, // Ikon Solid
                Colors.amber
              ),
              
              _buildVerticalDivider(),
              
              // IKON FLAG DIUBAH DAN DIBERI BACKGROUND BIRU
              _buildStatItem(
                "Language", 
                book.languages.isNotEmpty ? book.languages.first.toUpperCase() : "EN", 
                Icons.flag_rounded, // Menggunakan Flag
                Colors.blueAccent
              ),
              
              _buildVerticalDivider(),
              
              _buildStatItem(
                "Downloads", 
                book.getFormattedDownloads(), 
                Icons.download_rounded, 
                Colors.greenAccent
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        // Container Background untuk Ikon (Agar PASTI terlihat)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15), // Background transparan warna ikon
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  // --- RATING BAR (SOLID COLOR) ---
  Widget _buildInteractiveRatingBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            double rating = index + 1.0;
            setState(() => _userRating = rating);
            context.read<BookRepository>().saveRating(_book!.id.toString(), rating);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              // Gunakan Icons.star (Filled) untuk semua kondisi
              Icons.star,
              
              // WARNA: Amber (Terpilih) vs Putih Solid (Tidak)
              // Colors.grey.withOpacity(0.3) -> Diganti jadi Colors.white24 atau Grey Solid
              color: index < _userRating ? Colors.amber : Colors.grey.shade700,
              
              size: 38,
            ),
          ),
        );
      }),
    );
  }
}