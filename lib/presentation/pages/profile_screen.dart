// lib/presentation/pages/profile_screen.dart

import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_data.dart';
import '../cubit/book_library_cubit.dart';
import '../cubit/user_library_cubit.dart';
import '../cubit/user_library_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi Logout Fungsional
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.currentUser = null;
              AppData.favoriteBooks.clear();
              AppData.saveFavorites();
              context.go('/login');
            },
            child:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A2E)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // 1. STICKY HEADER (Konsisten dengan Home & Fav)
                _buildStickyHeader(),

                // 2. SCROLLABLE CONTENT
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Kartu Profil Utama
                          _buildProfileCard(),

                          const SizedBox(height: 32),

                          // Statistik Row (Real Data)
                          _buildStatisticsRow(),

                          const SizedBox(height: 32),

                          // Menu General (Info Aplikasi)
                          _buildSectionTitle('App Info'),
                          const SizedBox(height: 12),
                          _buildGlassMenuContainer([
                            _buildMenuItem(
                              icon: Icons.info_outline_rounded,
                              title: 'About App',
                              subtitle: 'Version & Features',
                              iconColor: const Color(0xFF3B82F6),
                              onTap: () => context.push('/profile/about'),
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.groups_rounded,
                              title: 'Meet the Team',
                              subtitle: 'Kelompok 2',
                              iconColor: const Color(0xFF10B981),
                              onTap: () => context.push('/profile/about-us'),
                            ),
                          ]),

                          const SizedBox(height: 40),

                          // Tombol Logout
                          _buildLogoutButton(),

                          const SizedBox(height: 24),
                          Text(
                            'Digital Library v2.0.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HEADER WIDGET ---
  Widget _buildStickyHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // KIRI: Logo & Teks
          Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 34,
                height: 34,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFF6366F1),
                    size: 30),
              ),
              const SizedBox(width: 12),
              const Text(
                'MI LIBRO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: 1.5,
                  fontFamily: 'Montserrat',
                ),
              ),
            ],
          ),
          // KANAN: Logout Icon
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  // --- CONTENT WIDGETS ---

  Widget _buildProfileCard() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            // Avatar Container
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 55,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Nama User
        Text(
          AppData.currentUser?.username.toUpperCase() ?? 'GUEST',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        // Email User
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            AppData.currentUser?.email ?? 'No email connected',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Join Date
        if (AppData.currentUser != null)
          Text(
            'Member since ${DateFormat('MMMM yyyy').format(AppData.currentUser!.joinDate)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.4),
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: BlocBuilder<BookLibraryCubit, BookLibraryState>(
        builder: (context, state) {
          // Default data
          String totalBooks = '0';
          String totalReviews = '0';

          if (state is BookLibraryLoaded) {
            totalBooks = '${state.totalBookCount}';
            // Menghitung jumlah buku yang memiliki rating > 0 dari state yang ada
            totalReviews =
                '${state.books.where((book) => (book.rating ?? 0) > 0).length}';
          } else {
            // Fallback ke AppData jika state belum loaded
            totalBooks = '${AppData.books.length}';
            totalReviews =
                '${AppData.books.where((book) => (book.rating ?? 0) > 0).length}';
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Library (Total Books)
              Expanded(
                child: _buildStatItem('Library', totalBooks,
                    Icons.menu_book_rounded, const Color(0xFF6366F1)),
              ),

              _buildVerticalDivider(),

              // 2. Favorites (Dari UserLibraryCubit)
              Expanded(
                child: BlocBuilder<UserLibraryCubit, UserLibraryState>(
                  builder: (context, userState) {
                    String favCount = '0';
                    if (userState is UserLibraryLoaded) {
                      favCount = '${userState.favorites.length}';
                    } else {
                      favCount = '${AppData.favoriteBooks.length}';
                    }
                    return _buildStatItem('Favorites', favCount,
                        Icons.favorite_rounded, const Color(0xFFEC4899));
                  },
                ),
              ),

              _buildVerticalDivider(),

              // 3. Reviews (Data Review dari BookLibraryCubit/AppData)
              Expanded(
                child: _buildStatItem(
                  'Reviews',
                  totalReviews,
                  Icons.star_rounded, // Menggunakan ikon Bintang
                  const Color(0xFFFFC107), // Warna Amber/Emas
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.1),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.9),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGlassMenuContainer(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.3), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 64,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
          foregroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.3)),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}