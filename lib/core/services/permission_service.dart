import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Meminta izin penyimpanan (Storage).
  /// Menangani perbedaan Android SDK (sebelum dan sesudah Android 13/Tiramisu).
  Future<bool> requestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      // Untuk Android 13+ (API 33), izin penyimpanan terpecah menjadi photos, videos, audio.
      // Gunakan 'photos' atau 'manageExternalStorage' tergantung kebutuhan.
      // Di sini kita coba request storage umum dulu (untuk API < 33) atau photos untuk API >= 33.
      
      // Cek SDK version secara logic (permission_handler menghandle detailnya)
      // Tapi best practice permission_handler:
      
      final statusStorage = await Permission.storage.status;
      
      if (statusStorage.isGranted) {
        return true;
      }

      // Request permission
      // Note: Di Android 13, Permission.storage selalu return denied permanently jika targetSDK >= 33.
      // Kita harus cek permission photos/audio/videos.
      // Namun untuk kemudahan, kita request beberapa yang relevan.
      
      // Coba request storage dulu
      status = await Permission.storage.request();
      
      if (status.isGranted) return true;

      // Jika gagal (mungkin Android 13+), coba photos/videos jika itu konteksnya
       if (status.isDenied || status.isPermanentlyDenied) {
         // Fallback check for Android 13 specific permissions if needed
         // Untuk aplikasi buku/download, mungkin perlu manageExternalStorage jika ingin akses file umum,
         // tapi itu butuh review Google Play.
         // Kita coba photos sebagai fallback umum untuk media.
          var statusPhotos = await Permission.photos.request();
          if (statusPhotos.isGranted) return true;
       }
    } else {
      // iOS atau lainnya
      status = await Permission.storage.request();
    }

    return status.isGranted;
  }

  /// Meminta izin kamera.
  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    return status.isGranted;
  }

  /// Meminta izin notifikasi (Android 13+).
  Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      status = await Permission.notification.request();
    }
    return status.isGranted;
  }

  /// Membuka pengaturan aplikasi jika permission ditolak permanen.
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
