// Enhanced User class
class User {
  String _username;
  String _password;
  String _email;
  DateTime _joinDate;
  Set<String> _readBooks;

  User(this._username, this._password, this._email)
    : _joinDate = DateTime.now(),
      _readBooks = {};

  // Getters
  String get username => _username;
  String get password => _password;
  String get email => _email;
  DateTime get joinDate => _joinDate;
  Set<String> get readBooks => _readBooks;

  // Methods
  void addReadBook(String bookTitle) {
    _readBooks.add(bookTitle);
  }

  bool hasReadBook(String bookTitle) {
    return _readBooks.contains(bookTitle);
  }

  int get totalBooksRead => _readBooks.length;
}
