import 'package:flutter/material.dart';
import '../../data/app_data.dart';
import '../../domain/entities/book.dart';
import 'category_books_screen.dart';

// Enhanced Categories Screen
class CategoriesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Map<String, List<DigitalBook>> categorizedBooks = {};
    for (var book in AppData.books) {
      if (!categorizedBooks.containsKey(book.category)) {
        categorizedBooks[book.category] = [];
      }
      categorizedBooks[book.category]!.add(book);
    }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ).createShader(bounds),
                      child: Text(
                        'Explore Categories',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Text(
                      'Browse books by subject',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
              // Categories Grid
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 120),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categorizedBooks.keys.length,
                  itemBuilder: (context, index) {
                    String category = categorizedBooks.keys.elementAt(index);
                    List<DigitalBook> books = categorizedBooks[category]!;
                    int colorIndex = index % AppData.primaryColors.length;

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  CategoryBooksScreen(category: category),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                                return SlideTransition(
                                  position: Tween<Offset>(
                                    begin: Offset(1.0, 0.0),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                );
                              },
                          transitionDuration: Duration(milliseconds: 400),
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppData.primaryColors[colorIndex].withOpacity(
                                0.8,
                              ),
                              AppData.primaryColors[colorIndex].withOpacity(
                                0.6,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppData.primaryColors[colorIndex]
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Background pattern
                            Positioned(
                              right: -20,
                              bottom: -20,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                            ),
                            // Content
                            Padding(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    _getCategoryIcon(category),
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '${books.length} books',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'programming':
        return Icons.code_rounded;
      case 'science':
        return Icons.science_rounded;
      case 'business':
        return Icons.business_rounded;
      case 'technology':
        return Icons.computer_rounded;
      case 'design':
        return Icons.design_services_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'futurism':
        return Icons.rocket_launch_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'literature':
        return Icons.book_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}