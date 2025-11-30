import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AboutUsScreen extends StatelessWidget {
  // HAPUS 'const' di sini karena halaman ini dinamis (warna acak)
  AboutUsScreen({super.key});

  // Data Anggota Tim (7 Orang)
  final List<Map<String, String>> members = const [
    {'name': 'Rayhan Nafish Dwi Prananda', 'id': '24111814098', 'role': 'Kelas D'},
    {'name': 'Kevin Dzaky Hendratama', 'id': '24111814055', 'role': 'Kelas D'},
    {'name': 'Fathan Orvala', 'id': '24111814063', 'role': 'Kelas D'},
    {'name': 'Dammar Sanggalie', 'id': '24111814051', 'role': 'Kelas D'},
    {'name': 'Fatecha Dena Angga Rahmatulloh', 'id': '24111814039', 'role': 'Kelas D'},
    {'name': 'Randy Dinky Saputra', 'id': '24111814052', 'role': 'Kelas D'},
    {'name': 'Muhammad Hafizh Shafa Rabbani', 'id': '24111814053', 'role': 'Kelas D'},
  ];

  // Daftar warna-warna cerah
  final List<Color> _iconColors = [
    Colors.blueAccent, Colors.redAccent, Colors.green, Colors.orange,
    Colors.purpleAccent, Colors.teal, Colors.pinkAccent, Colors.indigoAccent,
  ];

  Color _getRandomColor(int index) {
    return _iconColors[index % _iconColors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Our Team',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          // PERUBAHAN DI SINI:
          // Menggunakan context.go('/profile') untuk memaksa pindah ke halaman profile
          // alih-alih menggunakan pop().
          onPressed: () => context.go('/profile'),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 20, top: 10),
            decoration: const BoxDecoration(
               color: Color(0xFF1A1A2E),
               borderRadius: BorderRadius.only(
                 bottomLeft: Radius.circular(24),
                 bottomRight: Radius.circular(24),
               ),
            ),
            child: Column(
              children: [
                const Text(
                  'Meet The Makers',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelompok 2 • 7 Anggota',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: members.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8), 
              itemBuilder: (context, index) {
                final member = members[index];
                final iconBgColor = _getRandomColor(index);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38, height: 38,
                        decoration: BoxDecoration(
                          color: iconBgColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: iconBgColor.withOpacity(0.5), width: 1.5),
                        ),
                        child: Icon(Icons.person_rounded, color: iconBgColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member['name']!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              member['id']!,
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: iconBgColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          member['role']!,
                          style: TextStyle(color: iconBgColor, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}