// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:perpustakaan_mini/repositories/book_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/app_data.dart';
import '../models/book_model.dart';
// PERBAIKAN 1: Sesuaikan nama import dengan nama file asli (epub_player_screen.dart)
import 'epub_player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart'; // <-- Tambah Import

class EnhancedBookDetailScreen extends StatefulWidget {
  final String bookId;
  final DigitalBook?
      initialBook; // Diubah tipe datanya agar sesuai dengan model

  const EnhancedBookDetailScreen({
    Key? key,
    required this.bookId, // Menggunakan String agar konsisten dengan API
    this.initialBook,
  }) : super(key: key);

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
  bool isFavorite = false;
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();

    _book = widget.initialBook;
    if (_book != null) {
      isFavorite = AppData.favoriteBooks.contains(_book!.title);
      _userRating = AppData.getUserRating(_book!.title);
    }

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    // Jika data awal belum lengkap, fetch detailnya
    if (_book == null) {
      _fetchBookDetails();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchBookDetails() async {
    final repo = context.read<BookRepository>();
    try {
      // Perhatikan: bookId di widget berupa String, tapi repo butuh int
      final int id = int.tryParse(widget.bookId) ?? 0;
      final fetchedBook = await repo.getBookDetails(id);

      if (mounted) {
        setState(() {
          _book = fetchedBook;
          _isLoading = false;
        });
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

  void _toggleFavorite() async {
    if (_book == null) return;

    setState(() {
      if (isFavorite) {
        AppData.favoriteBooks.remove(_book!.title);
      } else {
        AppData.favoriteBooks.add(_book!.title);
      }
      isFavorite = !isFavorite;
    });

    // Ensure save completes
    await AppData.saveFavorites();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        backgroundColor: isFavorite ? Color(0xFF10B981) : Color(0xFFEF4444),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _openReadLink() async {
    // PERBAIKAN 2: Gunakan properti yang benar dari book_model.dart (epubUrl)
    if (_book?.epubUrl == null || _book!.epubUrl.isEmpty) {
      _showError('No readable link available');
      return;
    }

    final url = _book!.epubUrl;

    // PERBAIKAN 3: Gunakan properti yang benar (isReadable menggantikan isEpub)
    if (_book!.isReadable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          // PERBAIKAN 4: Panggil Class yang Benar (EpubReaderScreen)
          builder: (context) => EpubReaderScreen(
            url: url,
            title: _book!.title,
          ),
        ),
      );
    } else {
      // Fallback jika bukan epub (jika ada logika lain)
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
      SnackBar(content: Text(message), backgroundColor: Color(0xFFEF4444)),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
          child:
              Text(_error ?? 'Error', style: TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _book == null) return _buildLoadingScreen();
    if (_book == null) return _buildErrorScreen();

    final DigitalBook book = _book!;
    int colorIndex = book.title.hashCode.abs() % AppData.primaryColors.length;

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
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: 'book_cover_${book.id}',
                                  child: Container(
                                    width: 140,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 20,
                                            offset: Offset(0, 10)),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        // Gunakan CachedNetworkImage
                                        // Bungkus dengan proxy wsrv.nl
                                        imageUrl:
                                            'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, url) => Container(
                                          color: Colors.white10,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.white)),
                                        ),
                                        errorWidget: (ctx, url, error) =>
                                            Container(
                                          color: Colors.white24,
                                          child: Icon(Icons.book,
                                              color: Colors.white, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                GFRating(
                                  value: _userRating,
                                  onChanged: (v) {
                                    setState(() => _userRating = v);
                                    AppData.saveRating(book.title, v);
                                  },
                                  size: GFSize.SMALL,
                                  color: Colors.amber,
                                  borderColor: Colors.amber,
                                  allowHalfRating: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'by ${book.author}',
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildInfoCard('Gutendex ID', book.id.toString(),
                                Icons.tag), // Fix: book.id to string
                            _buildInfoCard('Downloads',
                                book.getFormattedDownloads(), Icons.download),
                            _buildInfoCard(
                                'Language',
                                book.languages.isNotEmpty
                                    ? book.languages.join(', ').toUpperCase()
                                    : '-',
                                Icons.language),
                            // Fix: 'format' tidak ada di model, kita hardcode 'EPUB' jika readable
                            _buildInfoCard(
                                'Format',
                                book.isReadable ? 'EPUB' : 'Unknown',
                                Icons.file_present),
                          ],
                        ),
                        SizedBox(height: 24),
                        Text('Subjects / Shelves',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        SizedBox(height: 12),
                        Text(
                          book.description,
                          style: TextStyle(
                              fontSize: 15, color: Colors.white70, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                        SizedBox(height: 32),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: book.isReadable
                                ? LinearGradient(colors: [
                                    Color(0xFF6366F1),
                                    Color(0xFF8B5CF6)
                                  ])
                                : LinearGradient(colors: [
                                    Colors.grey.shade800,
                                    Colors.grey.shade900
                                  ]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: book.isReadable
                                ? [
                                    BoxShadow(
                                        color:
                                            Color(0xFF6366F1).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: Offset(0, 8))
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: book.isReadable ? _openReadLink : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    book.isReadable
                                        ? Icons.menu_book_rounded
                                        : Icons.lock_outline,
                                    color: Colors.white.withOpacity(
                                        book.isReadable ? 1.0 : 0.5),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    book.isReadable
                                        ? 'Read Now' // Kita tahu ini EPUB karena filter di repo
                                        : 'Not Available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(
                                          book.isReadable ? 1.0 : 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: Colors.white70, size: 14),
            SizedBox(width: 6),
            Expanded(
                child: Text(title,
                    style: TextStyle(fontSize: 10, color: Colors.white54),
                    overflow: TextOverflow.ellipsis)),
          ]),
          SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
