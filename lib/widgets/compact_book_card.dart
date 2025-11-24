import 'package:flutter/material.dart';
import '../data/app_data.dart';
import '../models/book_model.dart';
import '../screens/book_detail_screen.dart'; // Pastikan import ini benar

class CompactBookCard extends StatelessWidget {
  final DigitalBook book;
  final int colorIndex;

  const CompactBookCard({
    Key? key,
    required this.book,
    required this.colorIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                // PERBAIKAN: Tambahkan .toString() pada book.id
                EnhancedBookDetailScreen(bookId: book.id.toString()),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
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
              // Book Cover Image
              Image.network(
                book.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
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
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
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
                  );
                },
              ),
              // Gradient Overlay
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
              // Content
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Top badges (Hanya tampilkan Bahasa)
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
                    // Book info at bottom
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title
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
                            // Author
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
                            const SizedBox(height: 4),
                            // Bottom row
                            Row(
                              children: [
                                // Category badge
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
                                // Download count
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