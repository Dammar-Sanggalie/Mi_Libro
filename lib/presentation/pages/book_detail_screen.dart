// lib/screens/book_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:getwidget/getwidget.dart';
import 'package:perpustakaan_mini/domain/repositories/book_repository.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/app_data.dart'; // Keep for primaryColors
import '../../domain/entities/book.dart';
import '../cubit/user_library_cubit.dart'; // Import Cubit
import '../cubit/user_library_state.dart'; // NEW: Import UserLibraryState
import 'epub_player_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  
  // Local state for rating only, favorites is managed by Cubit
  double _userRating = 0.0;

  @override
  void initState() {
    super.initState();

    _book = widget.initialBook;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    
    // Fetch details if needed
    if (_book == null) {
      _fetchBookDetails();
    } else {
      setState(() => _isLoading = false);
      _loadRating();
    }
  }

  Future<void> _loadRating() async {
      // Ideally this should also be in a Cubit or Repository call
      if (_book != null) {
          final rating = await context.read<BookRepository>().getRating(_book!.id.toString());
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
    
    // Snackbars are now handled locally or we can listen to state changes
    // But simpler to just show generic feedback or let the UI update visually
  }

  Future<void> _openReadLink() async {
    if (_book?.epubUrl == null || _book!.epubUrl.isEmpty) {
      _showError('No readable link available');
      return;
    }

    final url = _book!.epubUrl;

    if (_book!.isReadable) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EpubReaderScreen(
            url: url,
            title: _book!.title,
          ),
        ),
      );
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
      SnackBar(content: Text(message), backgroundColor: const Color(0xFFEF4444)),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(child: CircularProgressIndicator(color: Color(0xFF6366F1))),
    );
  }

  Widget _buildErrorScreen() {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
          child:
              Text(_error ?? 'Error', style: const TextStyle(color: Colors.white))),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _book == null) return _buildLoadingScreen();
    if (_book == null) return _buildErrorScreen();

    final DigitalBook book = _book!;
    int colorIndex = book.title.hashCode.abs() % AppData.primaryColors.length;

    // Check favorite status from Cubit
    final isFavorite = context.select<UserLibraryCubit, bool>((cubit) {
      if (cubit.state is UserLibraryLoaded) {
        return (cubit.state as UserLibraryLoaded)
            .favorites
            .any((b) => b.id == book.id);
      }
      return false;
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
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
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
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
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black38,
                                            blurRadius: 20,
                                            offset: Offset(0, 10)),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl:
                                            'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                                        fit: BoxFit.cover,
                                        placeholder: (ctx, url) => Container(
                                          color: Colors.white10,
                                          child: const Center(
                                              child: CircularProgressIndicator(
                                                  color: Colors.white)),
                                        ),
                                        errorWidget: (ctx, url, error) =>
                                            Container(
                                          color: Colors.white24,
                                          child: const Icon(Icons.book,
                                              color: Colors.white, size: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GFRating(
                                  value: _userRating,
                                  onChanged: (v) {
                                    setState(() => _userRating = v);
                                    context.read<BookRepository>().saveRating(book.id.toString(), v);
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'by ${book.author}',
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          childAspectRatio: 2.5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            _buildInfoCard('Gutendex ID', book.id.toString(),
                                Icons.tag),
                            _buildInfoCard('Downloads',
                                book.getFormattedDownloads(), Icons.download),
                            _buildInfoCard(
                                'Language',
                                book.languages.isNotEmpty
                                    ? book.languages.join(', ').toUpperCase()
                                    : '-',
                                Icons.language),
                            _buildInfoCard(
                                'Format',
                                book.isReadable ? 'EPUB' : 'Unknown',
                                Icons.file_present),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Subjects / Shelves',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                        const SizedBox(height: 12),
                        Text(
                          book.description,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white70, height: 1.6),
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 56,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: book.isReadable
                                ? const LinearGradient(colors: [
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
                                            const Color(0xFF6366F1).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8))
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
                                  const SizedBox(width: 8),
                                  Text(
                                    book.isReadable
                                        ? 'Read Now'
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
                        const SizedBox(height: 32),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const SizedBox(width: 6),
            Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                    overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
