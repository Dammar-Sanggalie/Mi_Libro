// lib/screens/epub_player_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:epub_view/epub_view.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // Untuk Uint8List

class EpubReaderScreen extends StatefulWidget {
  final String url;
  final String title;

  const EpubReaderScreen({
    Key? key, 
    required this.url,
    required this.title,
  }) : super(key: key);

  @override
  _EpubReaderScreenState createState() => _EpubReaderScreenState();
}

class _EpubReaderScreenState extends State<EpubReaderScreen> {
  late EpubController _epubController;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _downloadAndOpenBook();
  }

  Future<void> _downloadAndOpenBook() async {
    try {
      Uint8List fileBytes;

      if (kIsWeb) {
        // --- LOGIKA WEB ---
        // Proxy 'corsproxy.io' diblokir (403), kita ganti ke 'api.codetabs.com' atau 'allorigins'
        // 'codetabs' biasanya lebih andal untuk file binary (epub/pdf)
        
        // Opsi 1: CodeTabs
        final proxyUrl = 'https://api.codetabs.com/v1/proxy?quest=${widget.url}';
        
        // Opsi 2 (Cadangan): AllOrigins (Buka komen di bawah jika CodeTabs gagal)
        // final proxyUrl = 'https://api.allorigins.win/raw?url=${Uri.encodeComponent(widget.url)}';
        
        print('Web Download via Proxy: $proxyUrl');
        
        final response = await http.get(Uri.parse(proxyUrl));
        
        if (response.statusCode == 200) {
          fileBytes = response.bodyBytes;
        } else {
          // Jika gagal, coba fallback sederhana tanpa proxy (kadang browser cache membantu)
          print('Proxy failed (${response.statusCode}), trying direct...');
          final directResponse = await http.get(Uri.parse(widget.url));
           if (directResponse.statusCode == 200) {
             fileBytes = directResponse.bodyBytes;
           } else {
             throw Exception('Failed to download. Status: ${response.statusCode}');
           }
        }
      } else {
        // --- LOGIKA MOBILE (Android/iOS) ---
        // Mobile tidak butuh proxy
        print('Mobile Download Direct: ${widget.url}');
        final response = await http.get(Uri.parse(widget.url));
        
        if (response.statusCode == 200) {
          fileBytes = response.bodyBytes;
        } else {
          throw Exception('Failed to download. Status: ${response.statusCode}');
        }
      }

      // Validasi data tidak kosong
      if (fileBytes.isEmpty) {
        throw Exception('File kosong (0 bytes)');
      }

      // --- BUKA DATA ---
      _epubController = EpubController(
        document: EpubDocument.openData(fileBytes),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Gagal memuat buku.\nServer mungkin memblokir akses Web.\n\nError: ${e.toString().replaceAll('Exception:', '')}";
        });
      }
      print("Error loading epub: $e");
    }
  }

  @override
  void dispose() {
    // Hanya dispose jika controller berhasil dibuat (tidak loading & tidak error)
    if (!_isLoading && _error == null) {
      _epubController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A1A2E),
        iconTheme: IconThemeData(color: Colors.white),
        title: _isLoading || _error != null
            ? Text(
                widget.title,
                style: TextStyle(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              )
            : EpubViewActualChapter(
                controller: _epubController,
                builder: (chapterValue) => Text(
                  chapterValue?.chapter?.Title?.replaceAll('\n', '').trim() ?? widget.title,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      
      drawer: _isLoading || _error != null 
        ? null 
        : Drawer(
            backgroundColor: Color(0xFF1A1A2E),
            child: EpubViewTableOfContents(
              controller: _epubController,
              itemBuilder: (context, index, chapter, itemCount) {
                 return ListTile(
                   title: Text(
                     chapter.title!.trim(),
                     style: TextStyle(color: Colors.white70),
                   ),
                   onTap: () {
                     _epubController.jumpTo(index: index);
                     Navigator.of(context).pop(); 
                   },
                 );
              },
            ),
          ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF6366F1)),
              SizedBox(height: 20),
              Text(
                "Downloading eBook...", 
                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)
              ),
              SizedBox(height: 8),
              if (kIsWeb)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    "Menggunakan Proxy (Web Only)...", 
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 50),
              SizedBox(height: 16),
              Text(
                "Oops!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text(
                _error!, 
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _downloadAndOpenBook();
                },
                icon: Icon(Icons.refresh),
                label: Text("Coba Lagi"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    return EpubView(
      builders: EpubViewBuilders<DefaultBuilderOptions>(
        options: DefaultBuilderOptions(),
        chapterDividerBuilder: (_) => Divider(),
      ),
      controller: _epubController,
    );
  }
}