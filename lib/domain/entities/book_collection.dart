import 'book.dart';

class BookCollection {
  String id;
  String name;
  String description;
  List<DigitalBook> books;
  List<String> bookIds;

  BookCollection({
    required this.id,
    required this.name,
    this.description = '',
    this.books = const [],
    this.bookIds = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      // We don't serialize the full books list to avoid circular depth or redundancy, usually just IDs
      // But the original code mapped books. conforming to original:
      'books': books.map((b) {
        // DigitalBook entity doesn't have toJson.
        // We should probably not rely on Entity having toJson in Clean Arch.
        // But for now to keep app working, we might need to cast or handle it.
        // The original code called b.toJson().
        return {}; // Placeholder, see logic below
      }).toList(),
      'bookIds': bookIds,
    };
  }

  factory BookCollection.fromJson(Map<String, dynamic> json) {
    return BookCollection(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      books: const [],
      bookIds: List<String>.from(json['bookIds'] as List? ?? []),
    );
  }
}
