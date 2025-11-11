import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../data/app_data.dart';
import '../models/book_model.dart';

// Enhanced Book Detail Screen - Sekarang mengambil data berdasarkan ID
class EnhancedBookDetailScreen extends StatefulWidget {
  final int bookId;

  const EnhancedBookDetailScreen({Key? key, required this.bookId})
      : super(key: key);

  @override
  _EnhancedBookDetailScreenState createState() =>
      _EnhancedBookDetailScreenState();
}

class _EnhancedBookDetailScreenState extends State<EnhancedBookDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // State baru untuk mengelola pengambilan data
  DigitalBook? _book;
  bool _isLoading = true;
  String? _error;
  bool isFavorite = false;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Panggil fungsi untuk mengambil detail
    _fetchBookDetails();
  }

  // Fungsi baru untuk mengambil data buku dari API
  Future<void> _fetchBookDetails() async {
    try {
      // 1. Ambil buku dari repository menggunakan ID
      final fetchedBook =
          await context.read<BookRepository>().getBookDetails(widget.bookId);

      // 2. Set state dengan data yang berhasil didapat
      setState(() {
        _book = fetchedBook;
        // 3. Inisialisasi favorit & rating SETELAH buku didapat
        isFavorite = AppData.favoriteBooks.contains(fetchedBook.title);
        _userRating = AppData.getUserRating(fetchedBook.title);
        _isLoading = false;
      });

      // 4. Mulai animasi setelah data siap
      _animationController.forward();
    } catch (e) {
      // Tangani jika terjadi error
      setState(() {
        // Beri pesan error yang lebih singkat untuk UI
        _error = "Gagal memuat detail buku. Silakan coba lagi.";
        _isLoading = false;
      });
      // Tetap tampilkan error lengkap di konsol untuk debugging
      print('Error fetching book details: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    // Pastikan _book tidak null
    if (_book == null) return;

    setState(() {
      if (isFavorite) {
        AppData.favoriteBooks.remove(_book!.title);
      } else {
        AppData.favoriteBooks.add(_book!.title);
      }
      isFavorite = !isFavorite;
    });

    // Save favorites to persistent storage
    AppData.saveFavorites();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          ],
        ),
        backgroundColor: isFavorite ? Color(0xFF10B981) : Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _openPDF() async {
    // Pastikan _book tidak null
    if (_book == null) return;

    // Catatan: 'pdfUrl' dari API di-set ke 'N/A' di model.
    // Logic ini akan gagal (seperti seharusnya) jika URL tidak valid.
    try {
      final Uri url = Uri.parse(_book!.pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open PDF (link invalid)'), // Pesan error
            backgroundColor: Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Error opening URL'),
            ],
          ),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF6366F1),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        // Bungkus dengan SingleChildScrollView untuk mengatasi overflow
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, color: Colors.white30, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'Gagal Memuat Buku',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _error ?? 'Terjadi kesalahan tidak diketahui',
                    style: TextStyle(color: Colors.red.shade300),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Handle state Loading
    if (_isLoading) {
      return _buildLoadingScreen();
    }

    // Handle state Error
    if (_error != null || _book == null) {
      return _buildErrorScreen();
    }

    // Buat variabel lokal 'book'
    final DigitalBook book = _book!;

    // Gunakan ID buku untuk menentukan warna
    int colorIndex = book.id % AppData.primaryColors.length;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Enhanced App Bar
                SliverAppBar(
                  expandedHeight: 350,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  leading: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppData.primaryColors[colorIndex],
                            AppData.primaryColors[colorIndex].withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned(
                            right: -100,
                            top: -100,
                            child: Container(
                              width: 300,
                              height: 300,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -50,
                            bottom: -50,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.03),
                              ),
                            ),
                          ),
                          // Main content
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Book cover
                                Container(
                                  width: 140,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      book.imageUrl, // Gunakan 'book'
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            Icons.menu_book_rounded,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                // Updated Rating & Pages section
                                Wrap(
                                  spacing: 12.0,
                                  runSpacing: 8.0,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    // New GFRating widget
                                    GFRating(
                                      value: _userRating,
                                      onChanged: (rating) async {
                                        if (_book == null) return; // Guard
                                        setState(() {
                                          _userRating = rating;
                                        });

                                        // Save the rating
                                        await AppData.saveRating(
                                            _book!.title, rating);

                                        // Show confirmation message
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Thank you! You rated: $rating'),
                                            backgroundColor: Color(0xFF10B981),
                                          ),
                                        );
                                      },
                                      size: GFSize.SMALL,
                                      color: Colors.amber,
                                      borderColor: Colors.amber,
                                      allowHalfRating: true,
                                    ),

                                    // <-- PERUBAHAN: Tampilkan "Pages" (Halaman)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.menu_book_rounded, // Icon baru
                                              size: 16,
                                              color: Colors.white),
                                          SizedBox(width: 4),
                                          Text(
                                            '${book.numberOfPages} Pages', // Data baru
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Author
                        Text(
                          book.title, // Gunakan 'book'
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 8),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ).createShader(bounds),
                          child: Text(
                            'by ${book.author}', // Gunakan 'book'
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        // <-- PERUBAHAN: Book Info Grid
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 1.95,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildInfoCard(
                              'Category',
                              book.category, // Tetap "General"
                              Icons.category_rounded,
                            ),
                            _buildInfoCard(
                              'Year',
                              book.year.toString(), // Tetap
                              Icons.calendar_today_rounded,
                            ),
                            _buildInfoCard(
                              'ISBN', // Ganti 'Format'
                              book.isbn, // Data baru
                              Icons.qr_code_rounded, // Icon baru
                            ),
                            _buildInfoCard(
                              'Pages', // Ganti 'Size'
                              book.numberOfPages.toString(), // Data baru
                              Icons.menu_book_rounded, // Icon baru
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        // OOP Demo Section
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF2A2A3E), Color(0xFF1A1A2E)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.code_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'OOP Demonstration',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                book.displayInfo(), // Gunakan 'book'
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 24),
                        // Description
                        Text(
                          'About this book',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          book.description, // Gunakan 'book'
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.6,
                          ),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 32),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF6366F1).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _openPDF,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Read Now',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
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
                            SizedBox(width: 12),
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              '${book.title} downloaded!', // Gunakan 'book'
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Color(0xFF10B981),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Icon(
                                    Icons.download_rounded,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}