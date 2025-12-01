// lib/presentation/pages/book_library_screen.dart

import 'dart:async';
import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:perpustakaan_mini/presentation/cubit/book_library_cubit.dart';
import '../../data/app_data.dart';
import '../widgets/compact_book_card.dart';
import '../widgets/search_delegate.dart';
import '../widgets/sort_filter_controls.dart';

class BookLibraryScreen extends StatefulWidget {
  const BookLibraryScreen({super.key});

  @override
  _BookLibraryScreenState createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen>
    with TickerProviderStateMixin {
  // --- Logic Variables ---
  String _selectedCategory = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  int _carouselIndex = 0;
  late PageController _pageController;
  late Timer _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    // Viewport fraction diatur agar card carousel terlihat sedikit "mengintip"
    _pageController = PageController(viewportFraction: 0.85);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookLibraryCubit>().fetchInitialBooks();
    });

    // Auto-scroll carousel
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_carouselIndex + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pageController.dispose();
    _autoScrollTimer.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<BookLibraryCubit>().fetchMoreBooks();
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.currentUser = null;
              AppData.favoriteBooks.clear();
              AppData.saveFavorites();
              context.go('/login');
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi lebar layar untuk responsive layout
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 1. FIXED HEADER (Sticky)
                _buildStickyHeader(),

                // 2. SCROLLABLE CONTENT
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Greeting & Search Section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // KIRI: Sapaan
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    ShaderMask(
                                      shaderCallback: (bounds) =>
                                          const LinearGradient(
                                        colors: [
                                          Color(0xFF6366F1),
                                          Color(0xFF8B5CF6)
                                        ],
                                      ).createShader(bounds),
                                      child: Text(
                                        AppData.currentUser?.username
                                                .toUpperCase() ??
                                            'READER',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // KANAN: Ikon Search
                              GestureDetector(
                                onTap: () => showSearch(
                                  context: context,
                                  delegate: EnhancedSearchDelegate(),
                                ),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Carousel Section
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              child: Text(
                                'Trending Now',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            // Carousel dengan tinggi dinamis
                            _buildCarouselSection(isDesktop),
                          ],
                        ),
                      ),

                      // Categories Section
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                              child: Text(
                                'Explore Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ),
                            _buildCategoriesList(),
                          ],
                        ),
                      ),

                      // Sort Filter Controls
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 16),
                          child: SortFilterControls(),
                        ),
                      ),

                      // Book Grid Section
                      _buildBookGrid(screenWidth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildStickyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Teks
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFF6366F1),
                    size: 30),
              ),
              const SizedBox(width: 12),
              const Text(
                'MI LIBRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          // Profile Dropdown
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'profile') {
                context.go('/profile');
              }
            },
            offset: const Offset(0, 50),
            color: const Color(0xFF2A2A3E),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: const [
                    Icon(Icons.person_outline_rounded,
                        color: Colors.white70, size: 20),
                    SizedBox(width: 12),
                    Text('Profile', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(height: 1),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout_rounded,
                        color: Colors.redAccent, size: 20),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSection(bool isDesktop) {
    return BlocBuilder<BookLibraryCubit, BookLibraryState>(
      builder: (context, state) {
        if (state is BookLibraryLoaded && state.books.isNotEmpty) {
          final topBooks = state.books
              .where((book) => book.imageUrl.isNotEmpty)
              .take(4)
              .toList();

          if (topBooks.isEmpty) return const SizedBox.shrink();

          // PERBAIKAN: Tinggi dinamis untuk shape persegi panjang
          final double height = isDesktop ? 320.0 : 200.0;

          return Column(
            children: [
              SizedBox(
                height: height,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _carouselIndex = index % topBooks.length);
                  },
                  itemCount: 10000,
                  itemBuilder: (context, index) {
                    final book = topBooks[index % topBooks.length];
                    final isCenter = index % topBooks.length == _carouselIndex;
                    final scale = isCenter ? 1.0 : 0.9;
                    final opacity = isCenter ? 1.0 : 0.6;

                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: scale, end: scale),
                      duration: const Duration(milliseconds: 350),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: opacity,
                            child: child,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () =>
                              context.push('/book/${book.id}', extra: book),
                          child: _buildCarouselItem(book),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  topBooks.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _carouselIndex == index ? 24 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _carouselIndex == index
                          ? const Color(0xFF6366F1)
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoriesList() {
    return BlocBuilder<BookLibraryCubit, BookLibraryState>(
      builder: (context, state) {
        if (state is BookLibraryLoaded) {
          final categories = {'All', ...state.books.map((b) => b.category)};
          final sortedCategories = [
            'All',
            ...categories.where((c) => c != 'All')
          ];

          return SizedBox(
            height: 40,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: sortedCategories.length,
              itemBuilder: (context, index) {
                final category = sortedCategories[index];
                final isSelected = _selectedCategory == category;
                return _buildCategoryPill(category, isSelected);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBookGrid(double screenWidth) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      sliver: BlocBuilder<BookLibraryCubit, BookLibraryState>(
        builder: (context, state) {
          if (state is BookLibraryLoading) {
            return const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF6366F1))),
            );
          }
          if (state is BookLibraryError) {
            return SliverToBoxAdapter(
              child: Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.white54))),
            );
          }
          if (state is BookLibraryLoaded) {
            final filteredBooks = _selectedCategory == 'All'
                ? state.books
                : state.books
                    .where((book) => book.category == _selectedCategory)
                    .toList();

            if (filteredBooks.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                      child: Text("No books found",
                          style: TextStyle(color: Colors.white54))),
                ),
              );
            }

            // PERBAIKAN: Grid Column Logic (Desktop 6, Mobile 3)
            int crossAxisCount = 3; // Mobile Default (Diubah dari 2 ke 3)
            double childAspectRatio = 0.55; // Disesuaikan agar card tidak gepeng

            if (screenWidth > 1200) {
              crossAxisCount = 6; // Desktop Besar (Diubah dari 5 ke 6)
              childAspectRatio = 0.65;
            } else if (screenWidth > 800) {
              crossAxisCount = 4; // Tablet
              childAspectRatio = 0.60;
            }

            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 16,
                mainAxisSpacing: 20,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CompactBookCard(
                    book: filteredBooks[index],
                    colorIndex: index % AppData.primaryColors.length,
                  );
                },
                childCount: filteredBooks.length,
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildCarouselItem(dynamic book) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF2A2A3E),
                child: const Icon(Icons.broken_image, color: Colors.white54),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.5, 0.7, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill(String category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
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
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}