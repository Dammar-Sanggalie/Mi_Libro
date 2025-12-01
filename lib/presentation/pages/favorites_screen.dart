// lib/presentation/pages/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

import '../../data/app_data.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/book_collection.dart';
import '../../presentation/widgets/compact_book_card.dart';
import '../cubit/user_library_cubit.dart';
import '../cubit/user_library_state.dart';
// import 'book_detail_screen.dart'; // Tidak diperlukan lagi

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
            hintText: 'e.g. My Sci-Fi Favorites',
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
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) => Container(
                                          color: Colors.grey,
                                          child: const Icon(Icons.book)),
                                    ),
                                  ),
                                  title: Text(book.title,
                                      style:
                                          const TextStyle(color: Colors.white),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  subtitle: Text(book.author,
                                      style: const TextStyle(
                                          color: Colors.white54),
                                      maxLines: 1),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.add_rounded,
                                        color: Color(0xFF6366F1)),
                                  ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF0F0F23)],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<UserLibraryCubit, UserLibraryState>(
            builder: (context, state) {
              if (state is UserLibraryLoaded) {
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

                return _openedCollection != null
                    ? _buildOpenedCollectionView(state.favorites)
                    : _buildMainSpotifyView(state.favorites, state.collections);
              } else if (state is UserLibraryLoading) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6366F1)));
              } else if (state is UserLibraryError) {
                return Center(
                    child: Text("Error: ${state.message}",
                        style: const TextStyle(color: Colors.white)));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainSpotifyView(
      List<DigitalBook> favorites, List<BookCollection> collections) {
    final filteredBooks = favorites.where((book) {
      final titleLower = book.title.toLowerCase();
      final authorLower = book.author.toLowerCase();
      return titleLower.contains(_searchQuery) ||
          authorLower.contains(_searchQuery);
    }).toList();

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 3;

    if (screenWidth > 900) {
      crossAxisCount = 7;
    } else if (screenWidth > 600) {
      crossAxisCount = 4;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Library',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    hintText: 'Find in favorites',
                    hintStyle: TextStyle(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_searchQuery.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            height: 130,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchQuery.isEmpty ? 'Liked Books' : 'Search Results',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_searchQuery.isEmpty)
                const Icon(Icons.grid_view_rounded,
                    color: Colors.white54, size: 20),
            ],
          ),
        ),
        Expanded(
          child: filteredBooks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off_rounded,
                          size: 60, color: Colors.white12),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'No books found for "$_searchQuery"'
                            : 'No liked books yet',
                        style: const TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    return CompactBookCard(
                      book: filteredBooks[index],
                      colorIndex: index % AppData.primaryColors.length,
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
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white54,
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 35,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create',
              style: TextStyle(
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
      onTap: () {
        setState(() {
          _openedCollection = collection;
        });
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF2A2A3E),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4)
                    ],
                  ),
                  child: ClipOval(
                    child: coverUrl != null
                        ? CachedNetworkImage(
                            imageUrl:
                                'https://wsrv.nl/?url=${Uri.encodeComponent(coverUrl)}',
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                _buildDefaultCollectionIcon(),
                          )
                        : _buildDefaultCollectionIcon(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_horiz_rounded,
                          size: 16, color: Colors.white),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteCollection(collection);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'delete',
                          height: 32,
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  color: Colors.redAccent, size: 16),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                      color: const Color(0xFF2A2A3E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              collection.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCollectionIcon() {
    return Container(
      color: Colors.grey.withOpacity(0.2),
      child: const Icon(Icons.collections_bookmark_rounded,
          color: Colors.white54, size: 30),
    );
  }

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => setState(() => _openedCollection = null),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent),
                onPressed: () => _deleteCollection(collection),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: const Center(
                    child: Icon(Icons.auto_stories_rounded,
                        size: 60, color: Colors.white)),
              ),
              const SizedBox(height: 24),
              Text(
                collection.name,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${collectionBooks.length} Books in collection',
                style: const TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () => _addBookToCollection(collection, favorites),
                child: const Text('Add Books',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: collectionBooks.isEmpty
              ? const Center(
                  child: Text("Collection Empty",
                      style: TextStyle(color: Colors.white24)))
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  itemCount: collectionBooks.length,
                  itemBuilder: (context, index) {
                    final book = collectionBooks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          // Menggunakan GoRouter untuk pindah ke detail buku
                          context.push('/book/${book.id}', extra: book);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: CachedNetworkImage(
                            imageUrl:
                                'https://wsrv.nl/?url=${Uri.encodeComponent(book.imageUrl)}',
                            width: 48,
                            height: 72,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                                color: Colors.white10,
                                width: 48,
                                height: 72,
                                child: const Icon(Icons.book,
                                    color: Colors.white)),
                          ),
                        ),
                        title: Text(book.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        subtitle: Text(book.author,
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 13),
                            maxLines: 1),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded,
                              color: Colors.white54),
                          onSelected: (value) {
                            if (value == 'delete') {
                              context
                                  .read<UserLibraryCubit>()
                                  .removeBookFromCollection(
                                      collection.id, book.id.toString());

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${book.title} removed from collection'),
                                  backgroundColor: Colors.redAccent,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.remove_circle_outline_rounded,
                                      color: Colors.redAccent, size: 20),
                                  SizedBox(width: 12),
                                  Text('Remove from collection',
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                          color: const Color(0xFF2A2A3E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
