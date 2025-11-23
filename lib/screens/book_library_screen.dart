import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perpustakaan_mini/cubit/book_library_cubit.dart';
import '../data/app_data.dart';
import '../models/book_model.dart';
import '../widgets/compact_book_card.dart';
import '../widgets/search_delegate.dart';

// Book Library Screen - Sekarang memuat data dari API
class BookLibraryScreen extends StatefulWidget {
  @override
  _BookLibraryScreenState createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // <-- BARU: Scroll controller untuk pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // <-- BARU: Tambahkan listener untuk scroll
    _scrollController.addListener(_onScroll);

    // --- PANGGIL API SAAT LAYAR DIMUAT ---
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookLibraryCubit>().fetchInitialBooks();
    });
    // -------------------------------------
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll); // <-- BARU: Hapus listener
    _scrollController.dispose(); // <-- BARU: Dispose controller
    super.dispose();
  }

  // <-- BARU: Fungsi listener untuk scroll
  void _onScroll() {
    // Panggil fetchMoreBooks jika sudah scroll mendekati akhir (cth: 200 pixel dari akhir)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookLibraryCubit>().fetchMoreBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Enhanced Header - FIXED
                Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), Colors.transparent],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Greeting text
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width - 100,
                                  ),
                                  child: Text(
                                    'Good ${_getGreeting()}, ${AppData.currentUser?.username.toUpperCase() ?? 'READER'}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Title
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'Digital Library',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12),
                          // Search button
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: () => showSearch(
                                context: context,
                                delegate: EnhancedSearchDelegate(),
                              ),
                              icon: Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              padding: EdgeInsets.all(8),
                              constraints: BoxConstraints(
                                minWidth: 44,
                                minHeight: 44,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      // Stats Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatChip(
                              '${AppData.books.length} Local Books',
                              Icons.library_books_rounded,
                            ),
                            SizedBox(width: 10),
                            _buildStatChip(
                              '${AppData.categories.length} Categories',
                              Icons.category_rounded,
                            ),
                            SizedBox(width: 10),
                            _buildStatChip(
                              '${AppData.favoriteBooks.length} Favorites',
                              Icons.favorite_rounded,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Enhanced Books Grid - Menggunakan BlocBuilder
                Expanded(
                  child: BlocBuilder<BookLibraryCubit, BookLibraryState>(
                    builder: (context, state) {
                      // STATE: LOADING
                      if (state is BookLibraryLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF6366F1),
                          ),
                        );
                      }

                      // STATE: ERROR
                      if (state is BookLibraryError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_off_rounded,
                                    color: Colors.white30, size: 48),
                                SizedBox(height: 16),
                                Text(
                                  'Gagal Memuat Buku',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  state.message,
                                  style: TextStyle(color: Colors.red.shade300),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // STATE: LOADED (SUKSES)
                      if (state is BookLibraryLoaded) {
                        final allApiBooks = state.books;
                        Set<String> categories =
                            allApiBooks.map((book) => book.category).toSet();
                        categories.add('All');
                        final sortedCategories = categories.toList()..sort();
                        final filteredApiBooks = allApiBooks.where((book) {
                          return _selectedCategory == 'All' ||
                              book.category == _selectedCategory;
                        }).toList();

                        // --- BARU: Logika untuk Grid Responsif ---
                        final double screenWidth =
                            MediaQuery.of(context).size.width;
                        int crossAxisCount = 3; // Default untuk mobile
                        double childAspectRatio = 0.62;

                        if (screenWidth > 1200) {
                          crossAxisCount = 7; // Desktop besar
                          childAspectRatio = 0.7;
                        } else if (screenWidth > 800) {
                          crossAxisCount = 5; // Tablet atau desktop kecil
                          childAspectRatio = 0.68;
                        } else if (screenWidth > 550) {
                          crossAxisCount = 4; // Mobile besar atau tablet kecil
                          childAspectRatio = 0.65;
                        }
                        // -----------------------------------------

                        return Column(
                          children: [
                            // Categories - Dinamis
                            Container(
                              height: 42,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: sortedCategories.length,
                                physics: BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  String category =
                                      sortedCategories.elementAt(index);
                                  bool isSelected =
                                      category == _selectedCategory;
                                  return Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: GestureDetector(
                                      onTap: () => setState(
                                        () => _selectedCategory = category,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    Color(0xFF6366F1),
                                                    Color(0xFF8B5CF6),
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.white.withOpacity(0.1),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            category,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : Colors.white
                                                      .withOpacity(0.7),
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              fontSize: 12,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: 18),
                            // GridView
                            Expanded(
                              child: GridView.builder(
                                // <-- BARU: Pasang controller
                                controller: _scrollController,
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
                                physics: BouncingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  // --- BARU: Menggunakan nilai dinamis ---
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  // ------------------------------------
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                // <-- PERUBAHAN: Tambah 1 item untuk loader jika belum max
                                itemCount: filteredApiBooks.length +
                                    (state.hasReachedMax ? 0 : 1),
                                itemBuilder: (context, index) {
                                  // <-- PERUBAHAN: Logika untuk menampilkan loader di akhir
                                  if (index == filteredApiBooks.length) {
                                    return Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF6366F1),
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  }

                                  // Tampilkan CompactBookCard seperti biasa
                                  return CompactBookCard(
                                    book: filteredApiBooks[index],
                                    colorIndex:
                                        index % AppData.primaryColors.length,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      // STATE: INITIAL
                      return Center(
                        child: Text(
                          "Memuat perpustakaan...",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}