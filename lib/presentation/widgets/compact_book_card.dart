// lib/presentation/widgets/compact_book_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart'; // WAJIB IMPORT INI
import '../../data/app_data.dart';
import '../../domain/entities/book.dart';

class CompactBookCard extends StatelessWidget {
  final DigitalBook book;
  final int colorIndex;

  const CompactBookCard({
    super.key,
    required this.book,
    required this.colorIndex,
  });

  String _getProxyUrl(String url) {
    // Menggunakan wsrv.nl sebagai proxy image cache agar gambar bisa dimuat
    return 'https://wsrv.nl/?url=${Uri.encodeComponent(url)}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // PERBAIKAN: Menggunakan context.push dari GoRouter
        // Ini memastikan URL di browser berubah menjadi /book/:id
        context.push('/book/${book.id}', extra: book);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppData.primaryColors[colorIndex].withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image dengan Proxy
              CachedNetworkImage(
                imageUrl: _getProxyUrl(book.imageUrl),
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppData.primaryColors[colorIndex],
                        AppData.primaryColors[colorIndex].withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white.withOpacity(0.7),
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
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
                    child: Center(
                      child: Icon(
                        Icons.book_rounded,
                        size: 28,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  );
                },
              ),

              // Gradient Overlay (Agar teks terbaca)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85)
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),

              // Text Content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge Bahasa (Jika ada)
                    Row(
                      children: [
                        if (book.languages.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              book.languages.first.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),

                    // Judul & Penulis
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                book.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                  letterSpacing: -0.2,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: constraints.maxWidth,
                              child: Text(
                                book.author,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: -0.1,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 3),

                            // Rating Row
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 8,
                                  color: Colors.amber.shade300,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  book.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),

                            // Footer (Category & Download Count)
                            Row(
                              children: [
                                Flexible(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      book.category,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 7,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  flex: 1,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.download_rounded,
                                        size: 7,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          book.getFormattedDownloads(),
                                          style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.7),
                                            fontSize: 7,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
