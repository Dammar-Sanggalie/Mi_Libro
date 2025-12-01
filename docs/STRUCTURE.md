# Struktur Proyek — Ringkasan (Generated)

Dokumentasi ringkas struktur `lib/` dan deskripsi tiap halaman UI (`lib/presentation/pages/`).

## Tree `lib/` (ringkas)

- lib/
  - `main.dart` — titik masuk aplikasi (setup router, theme, dll).
  - data/
    - `app_data.dart` — penyimpanan data app (mock data, cache, currentUser).
    - datasources/
      - `book_local_data_source.dart` — akses data lokal / cache.
      - `book_remote_data_source.dart` — akses API / remote.
    - models/
      - `book_model.dart` — mapping JSON <-> model (serialisasi).
    - repositories/
      - `book_repository_impl.dart` — implementasi kontrak repository (menggabungkan data sources).
  - domain/
    - entities/
      - `book.dart`, `book_collection.dart`, `sort_option.dart`, `user.dart` — entitas/domain models.
    - repositories/
      - `book_repository.dart` — abstraksi repository (interface).
    - usecases/
      - `get_initial_books.dart`, `get_book_detail.dart`, `search_books.dart`, `toggle_favorite.dart`, `get_collections.dart`, `save_collections.dart`, `get_favorites.dart`, `check_favorite_status.dart` — use-case (business logic).
  - presentation/
    - `routes/app_router.dart` — definisi rute (GoRouter) dan navigasi.
    - cubit/
      - `book_library_cubit.dart`, `book_library_state.dart` — cubit untuk library utama.
      - `book_search_cubit.dart`, `book_search_state.dart` — cubit untuk pencarian buku.
      - `user_library_cubit.dart`, `user_library_state.dart` — cubit untuk data user/favorites/collections.
    - pages/
      - `splash_screen.dart`
      - `login_screen.dart`
      - `home_screen.dart`
      - `book_library_screen.dart`
      - `book_detail_screen.dart`
      - `epub_player_screen.dart`
      - `categories_screen.dart`
      - `category_books_screen.dart`
      - `favorites_screen.dart`
      - `profile_screen.dart`
      - `about_screen.dart`
      - `about_us_screen.dart`
    - widgets/
      - `compact_book_card.dart` — kartu buku ringkas (digunakan di grid/carousel).
      - `search_delegate.dart` — SearchDelegate kustom untuk pencarian.
      - `sort_filter_controls.dart` — kontrol sortir & filter pada library.

## Deskripsi lengkap `lib/presentation/pages/` (per-file)

- `splash_screen.dart`
  - Halaman splash dengan animasi (logo, shimmer, rotating bg). Setelah ~3 detik otomatis `context.go('/login')`.
  - Menggunakan beberapa `AnimationController` untuk efek visual.

- `login_screen.dart`
  - Halaman login / sign-up sederhana.
  - Validasi form, menambah user baru ke `AppData.users`, menyetel `AppData.currentUser` pada login sukses.
  - Navigasi menggunakan `GoRouter` (`context.go('/home')`).
  - UI modern dengan animasi, field password show/hide, tombol gradient.

- `home_screen.dart`
  - Container untuk `StatefulNavigationShell` (GoRouter navigation shell).
  - Menyediakan `BottomNavigationBar` kustom (Home, Favorites, Profile) dan mengubah branch via `navigationShell.goBranch()`.

- `book_library_screen.dart`
  - Halaman utama katalog: greeting, search, carousel top books, categories, grid buku.
  - Menggunakan `BookLibraryCubit` untuk fetch initial/pagination buku.
  - Contains `SortFilterControls` dan `CompactBookCard` untuk menampilkan buku.
  - Men-trigger navigasi detail via `context.push('/book/${book.id}', extra: book)`.

- `book_detail_screen.dart`
  - Detail lengkap sebuah buku: cover besar, judul, author, rating (GFRating), info card (ID, downloads, language, format).
  - Tombol "Read Now" yang navigasi ke reader (`/read`) jika EPUB tersedia, atau membuka link eksternal.
  - Menggunakan `BookRepository` untuk fetch rating & menyimpan.
  - Toggle favorite dikelola lewat `UserLibraryCubit`.

- `epub_player_screen.dart` (EpubReaderScreen)
  - Mengunduh file EPUB (dengan proxy untuk web jika perlu), lalu menampilkan dengan package `epub_view`.
  - Menangani loading / error states dan memungkinkan retry.

- `categories_screen.dart`
  - Menampilkan grid kategori (mengelompokkan `AppData.books` per `category`).
  - Tap ke kategori akan `context.push('/category/$category')`.

- `category_books_screen.dart`
  - Menampilkan buku dari satu kategori dalam grid, menerima `category` sebagai parameter.
  - Memiliki Header + back (context.pop()).

- `favorites_screen.dart`
  - Menampilkan koleksi user dan daftar buku yang disukai (favorites).
  - Fitur: buat collection baru, tambahkan buku ke collection lewat bottom sheet, hapus collection, lihat collection (list), cari di favorites.
  - Menggunakan `UserLibraryCubit` untuk state favorites & collections.

- `profile_screen.dart`
  - Halaman profil user: avatar, username, email, statistik (total books, categories, favorites), menu (About Us, Logout).
  - Logout membersihkan `AppData.currentUser`, favorites, dan navigasi ke `/login`.

- `about_screen.dart`
  - Halaman informasi aplikasi (versi, deskripsi, fitur OOP yang diimplementasikan).

- `about_us_screen.dart`
  - Halaman tim/anggota proyek (list anggota dan info singkat). Tombol back menavigasi ke `/profile`.

## Catatan Arsitektur & Hubungan Lapisan

- Struktur mengikuti prinsip mirip "Clean Architecture":
  - `domain/`: entitas, interface repository, usecases (logic murni).
  - `data/`: model, data source (local/remote), implementasi repository yang mengadopsi kontrak `domain/repositories`.
  - `presentation/`: UI + state management (Cubit/Bloc) + routing.
- `AppData` dipakai sebagai storage in-memory / simple persistence untuk demo/mocking.
- Navigasi utama menggunakan `GoRouter` (`app_router.dart`) dan `context.push` / `context.go` / `navigationShell.goBranch`.

## Saran / Next Steps (opsional)

- Jika mau, saya bisa:
  - Menambahkan file `README.md` root dengan ringkasan ini (merge ke file utama).
  - Men-generate output `tree` lengkap (plaintext) yang bisa disalin.
  - Membuat dokumentasi per-cubit atau per-usecase (detil method & contoh pemakaian).

---
File ini dihasilkan otomatis sebagai ringkasan struktur. Ingin saya commit file `docs/STRUCTURE.md` ke repo, atau gabungkan ke `README.md` utama? 


