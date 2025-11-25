import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'package:perpustakaan_mini/cubit/book_library_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/app_data.dart';
import '../models/user_model.dart';
import '../widgets/compact_book_card.dart';
import '../widgets/search_delegate.dart';
import '../widgets/sort_filter_controls.dart';

class BookLibraryScreen extends StatefulWidget {
  @override
  _BookLibraryScreenState createState() => _BookLibraryScreenState();
}

class _BookLibraryScreenState extends State<BookLibraryScreen>
    with TickerProviderStateMixin {
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
    _pageController = PageController(viewportFraction: 0.75);

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
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

    // Auto-scroll carousel every 2 seconds
    _autoScrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_carouselIndex + 1) % 4;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
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
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
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
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting + Username
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          AppData.currentUser?.username.toUpperCase() ??
                              'READER',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: GestureDetector(
                      onTap: () => showSearch(
                        context: context,
                        delegate: EnhancedSearchDelegate(),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF6366F1).withOpacity(0.2),
                              Color(0xFF8B5CF6).withOpacity(0.2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF6366F1).withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  color: Colors.white54, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'Search books...',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Title - Top Books
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: Text(
                        'Top Books',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),

                  // Carousel of Top Books
                  BlocBuilder<BookLibraryCubit, BookLibraryState>(
                    builder: (context, state) {
                      if (state is BookLibraryLoaded &&
                          state.books.isNotEmpty) {
                        final topBooks = state.books.take(4).toList();

                        return Column(
                          children: [
                            SizedBox(
                              height: 220,
                              child: PageView.builder(
                                controller: _pageController,
                                onPageChanged: (index) {
                                  setState(() => _carouselIndex = index % 4);
                                },
                                itemBuilder: (context, index) {
                                  final book =
                                      topBooks[index % topBooks.length];
                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/book-detail',
                                          arguments: book,
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              blurRadius: 12,
                                              offset: Offset(0, 6),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CachedNetworkImage(
                                                imageUrl: book.imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: Color(0xFF2A2A3E),
                                                  child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: Color(0xFF6366F1),
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Color(0xFF2A2A3E),
                                                  child: Icon(
                                                    Icons.book,
                                                    color: Colors.white24,
                                                    size: 60,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                      Colors.transparent,
                                                      Colors.black
                                                          .withOpacity(0.8),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 12,
                                                left: 12,
                                                right: 12,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFF6366F1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        book.category,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      book.title,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 2),
                                                    Text(
                                                      book.author,
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Indicator dots
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                topBooks.length,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  width: _carouselIndex == index ? 28 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _carouselIndex == index
                                        ? Color(0xFF6366F1)
                                        : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  // Categories Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Categories Horizontal Scroll
                  BlocBuilder<BookLibraryCubit, BookLibraryState>(
                    builder: (context, state) {
                      if (state is BookLibraryLoaded) {
                        final categories = {
                          'All',
                          ...state.books.map((b) => b.category)
                        };
                        final sortedCategories = [
                          'All',
                          ...categories.where((c) => c != 'All').toList()
                        ];

                        return SizedBox(
                          height: 50,
                          child: ListView.builder(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            itemCount: sortedCategories.length,
                            itemBuilder: (context, index) {
                              final category = sortedCategories[index];
                              final isSelected = _selectedCategory == category;

                              return Padding(
                                padding: EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
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
                                      color:
                                          isSelected ? null : Color(0xFF2A2A3E),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.transparent
                                            : Colors.white.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),

                  SizedBox(height: 16),

                  // Books Grid with Category Filter
                  BlocBuilder<BookLibraryCubit, BookLibraryState>(
                    builder: (context, state) {
                      if (state is BookLibraryLoading) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        );
                      }

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
                                  'Failed to Load Books',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
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

                      if (state is BookLibraryLoaded) {
                        final filteredBooks = _selectedCategory == 'All'
                            ? state.books
                            : state.books
                                .where((book) =>
                                    book.category == _selectedCategory)
                                .toList();

                        if (filteredBooks.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Text(
                                'No books in this category',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          );
                        }

                        final double screenWidth =
                            MediaQuery.of(context).size.width;
                        int crossAxisCount = 3;
                        double childAspectRatio = 0.62;

                        if (screenWidth > 1200) {
                          crossAxisCount = 7;
                          childAspectRatio = 0.7;
                        } else if (screenWidth > 800) {
                          crossAxisCount = 5;
                          childAspectRatio = 0.68;
                        } else if (screenWidth > 550) {
                          crossAxisCount = 4;
                          childAspectRatio = 0.65;
                        }

                        return Column(
                          children: [
                            // Sort and Filter Controls from dammar-dev
                            SortFilterControls(),
                            SizedBox(height: 16),
                            // Books Grid from randy-dev (cleaner implementation)
                            Padding(
                              padding: EdgeInsets.fromLTRB(16, 0, 16, 120),
                              child: GridView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  childAspectRatio: childAspectRatio,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                itemCount: filteredBooks.length,
                                itemBuilder: (context, index) {
                                  return CompactBookCard(
                                    book: filteredBooks[index],
                                    colorIndex:
                                        index % AppData.primaryColors.length,
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }

                      return Center(
                        child: Text(
                          "Loading library...",
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
