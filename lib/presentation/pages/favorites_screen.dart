// lib/presentation/pages/favorites_screen.dart

import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_data.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_collection.dart';
import '../../presentation/widgets/compact_book_card.dart';
import '../cubit/user_library_cubit.dart';
import '../cubit/user_library_state.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  BookCollection? _openedCollection;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIC METHODS ---

  // Fungsi Logout (Sama seperti di Home)
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

  void _createNewCollection() {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            const Text('New Collection', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'e.g. Sci-Fi Favorites',
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white30)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF6366F1))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                context
                    .read<UserLibraryCubit>()
                    .createCollection(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _addBookToCollection(
      BookCollection collection, List<DigitalBook> allFavorites) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (context) {
        final availableBooks = allFavorites
            .where((b) => !collection.bookIds.contains(b.id.toString()))
            .toList();

        return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add to ${collection.name}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: availableBooks.isEmpty
                          ? const Center(
                              child: Text(
                                  "No more favorites to add.\nLike more books first!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white54)))
                          : ListView.builder(
                              controller: scrollController,
                              itemCount: availableBooks.length,
                              itemBuilder: (ctx, idx) {
                                final book = availableBooks[idx];
                                return ListTile(
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                                      width: 40,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(book.title,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      maxLines: 1),
                                  subtitle: Text(book.author,
                                      style: const TextStyle(
                                          color: Colors.white54),
                                      maxLines: 1),
                                  trailing: const Icon(Icons.add_circle_outline,
                                      color: Color(0xFF6366F1)),
                                  onTap: () {
                                    context
                                        .read<UserLibraryCubit>()
                                        .addBookToCollection(
                                            collection.id, book);
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  void _deleteCollection(BookCollection collection) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text('Delete Collection?',
            style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${collection.name}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white54))),
          TextButton(
            onPressed: () {
              context.read<UserLibraryCubit>().deleteCollection(collection.id);
              if (_openedCollection == collection) {
                setState(() {
                  _openedCollection = null;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- UI SECTION ---

  @override
  Widget build(BuildContext context) {
    // Responsive Logic
    final double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3; // Mobile default
    double childAspectRatio = 0.60;

    if (screenWidth > 1100) {
      crossAxisCount = 6; // Desktop default
      childAspectRatio = 0.68;
    } else if (screenWidth > 800) {
      crossAxisCount = 4;
      childAspectRatio = 0.65;
    }

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
          child: BlocBuilder<UserLibraryCubit, UserLibraryState>(
            builder: (context, state) {
              if (state is UserLibraryLoaded) {
                // Logic validasi collection yang dibuka
                if (_openedCollection != null) {
                  final exists = state.collections
                      .any((c) => c.id == _openedCollection!.id);
                  if (!exists) {
                    _openedCollection = null;
                  } else {
                    _openedCollection = state.collections
                        .firstWhere((c) => c.id == _openedCollection!.id);
                  }
                }

                return Column(
                  children: [
                    // 1. STICKY HEADER (Dinamis: Home Style atau Detail Style)
                    _buildStickyHeader(),

                    // 2. SCROLLABLE CONTENT
                    Expanded(
                      child: _openedCollection != null
                          ? _buildOpenedCollectionView(state.favorites)
                          : _buildMainLibraryView(state.favorites,
                              state.collections, crossAxisCount, childAspectRatio),
                    ),
                  ],
                );
              } else if (state is UserLibraryLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // Header yang Statis & Dinamis
  Widget _buildStickyHeader() {
    // Cek apakah sedang membuka detail koleksi
    bool isDetails = _openedCollection != null;

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
          // KIRI: Logika Tampilan (Main vs Details)
          Expanded(
            child: Row(
              children: [
                if (isDetails) ...[
                  // --- TAMPILAN DETAIL KOLEKSI ---
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                    onPressed: () => setState(() => _openedCollection = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: Text(
                        _openedCollection!.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ] else ...[
                  // --- TAMPILAN UTAMA (SAMA DENGAN HOME) ---
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
              ],
            ),
          ),

          // KANAN: Logika Tampilan
          if (isDetails)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent),
              onPressed: () => _deleteCollection(_openedCollection!),
            )
          else
            // --- PROFILE DROPDOWN (SAMA DENGAN HOME) ---
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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

  // Tampilan Utama (List Collections + All Liked Books)
  Widget _buildMainLibraryView(List<DigitalBook> favorites,
      List<BookCollection> collections, int crossAxisCount, double aspectRatio) {
    final filteredBooks = favorites.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      return titleLower.contains(_searchQuery) ||
          authorLower.contains(_searchQuery);
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Search Bar (Sticky-ish look but scrolls inside)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded,
                          color: Colors.white.withOpacity(0.5)),
                      hintText: 'Filter your favorites...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.4)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Collections Section
        if (_searchQuery.isEmpty)
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 16, 24, 12),
                  child: Text(
                    'Your Collections',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: collections.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildAddCollectionCircle();
                      }
                      return _buildCollectionCircle(
                          collections[index - 1], favorites);
                    },
                  ),
                ),
              ],
            ),
          ),

        // Liked Books Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text(
              _searchQuery.isEmpty ? 'Liked Books' : 'Search Results',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Grid Books
        filteredBooks.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.favorite_border_rounded,
                            size: 48, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(color: Colors.white.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: aspectRatio,
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
                ),
              ),
      ],
    );
  }

  // Tampilan Detail Koleksi
  Widget _buildOpenedCollectionView(List<DigitalBook> favorites) {
    final collection = _openedCollection!;
    List<DigitalBook> collectionBooks = [];
    for (String id in collection.bookIds) {
      try {
        final b = favorites.firstWhere((book) => book.id.toString() == id);
        collectionBooks.add(b);
      } catch (e) {
        // Book not found in favorites
      }
    }

    return Column(
      children: [
        // Summary Card
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.2),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.collections_bookmark_rounded,
                      color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${collectionBooks.length} Books',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Created recently',
                        style: TextStyle(color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _addBookToCollection(collection, favorites),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F0F23),
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
        ),

        // List Books in Collection
        Expanded(
          child: collectionBooks.isEmpty
              ? Center(
                  child: Text("Collection is empty",
                      style: TextStyle(color: Colors.white.withOpacity(0.5))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  itemCount: collectionBooks.length,
                  itemBuilder: (context, index) {
                    final book = collectionBooks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        onTap: () =>
                            context.push('/book/${book.id}', extra: book),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                            width: 50,
                            height: 75,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(book.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            maxLines: 1),
                        subtitle: Text(book.author,
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.6)),
                            maxLines: 1),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline_rounded,
                              color: Colors.redAccent.withOpacity(0.8)),
                          onPressed: () {
                            context
                                .read<UserLibraryCubit>()
                                .removeBookFromCollection(
                                    collection.id, book.id.toString());
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAddCollectionCircle() {
    return GestureDetector(
      onTap: _createNewCollection,
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Create',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionCircle(
      BookCollection collection, List<DigitalBook> favorites) {
    String? coverUrl;
    if (collection.bookIds.isNotEmpty) {
      try {
        final firstBook = favorites
            .firstWhere((b) => b.id.toString() == collection.bookIds.first);
        coverUrl = firstBook.imageUrl;
      } catch (e) {
        coverUrl = null;
      }
    }

    return GestureDetector(
      onTap: () => setState(() => _openedCollection = collection),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(2), // Border width
                child: ClipOval(
                  child: coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl:
                              'https://wsrv.nl/?url=${Uri.encodeComponent(coverUrl)}',
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const Icon(
                              Icons.collections_bookmark,
                              color: Colors.white),
                        )
                      : Container(
                          color: const Color(0xFF2A2A3E),
                          child: const Icon(Icons.collections_bookmark,
                              color: Colors.white),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              collection.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}