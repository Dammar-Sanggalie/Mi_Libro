
# Proyek Digital Library: Peta Jalan Pengembangan


#  Status Saat Ini (yg udah fungsi)

- **Arsitektur Inti**: Proyek memiliki struktur yang baik menggunakan BLoC (Cubit) dan Repository Pattern.
  - `BookLibraryCubit` dan `BookSearchCubit` sudah berfungsi untuk me-manage state.
  - `ApiBookRepository` berhasil memanggil endpoint `search-books` dari Big Book API menggunakan `dio`.
- **Alur Autentikasi**: Alur `SplashScreen` -> `LoginScreen` -> `HomeScreen` sudah berjalan lancar.
- **Fitur Utama (Sebagian)**:
  - **Library (Home)**: Berhasil menampilkan daftar buku awal dari API .
  - **Penyimpanan Lokal**: `AppData` sudah bisa menyimpan data favorit dan rating ke `SharedPreferences`.



## Masalah Utama (Yang Harus Diperbaiki)
  - **Pencarian**: belum bisa melakukan pencarian
  - **Detail Buku**: detail buku blm di call, jadi masih blm ada (liat dokumentasi), sesuaikan jg tampilan sesuai layout yg normal
  
  - **explore**: yg dipanggil masih model awal bukan dr api.
  - **favorit**: blm bisa menambah favorit.
  


# dokumentasi :  
    https://bigbookapi.com/docs/#Search-Books






