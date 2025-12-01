// lib/presentation/pages/profile_screen.dart

import 'dart:ui'; // Diperlukan untuk ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../data/app_data.dart';
import '../cubit/book_library_cubit.dart';

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

  // Fungsi Logout
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppData.currentUser = null;
              AppData.favoriteBooks.clear();
              AppData.saveFavorites();
              context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Background Gradient Global
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
                // 1. STICKY HEADER (Sama dengan Home & Fav)
                _buildStickyHeader(),

                // 2. SCROLLABLE CONTENT
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Profile Info Card
                          _buildProfileCard(),

                          const SizedBox(height: 24),

                          // Statistics Row
                          _buildStatisticsRow(),

                          const SizedBox(height: 24),

                          // Reading Challenge
                          _buildReadingChallenge(),

                          const SizedBox(height: 32),

                          // Menu: Account Settings
                          _buildSectionTitle('Account Settings'),
                          const SizedBox(height: 12),
                          _buildGlassMenuContainer([
                            _buildMenuItem(
                              icon: Icons.person_outline_rounded,
                              title: 'Edit Profile',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.notifications_none_rounded,
                              title: 'Notifications',
                              onTap: () {},
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.lock_outline_rounded,
                              title: 'Privacy & Security',
                              onTap: () {},
                            ),
                          ]),

                          const SizedBox(height: 24),

                          // Menu: General
                          _buildSectionTitle('General'),
                          const SizedBox(height: 12),
                          _buildGlassMenuContainer([
                            _buildMenuItem(
                              icon: Icons.info_outline_rounded,
                              title: 'About App',
                              onTap: () => context.push('/profile/about'),
                            ),
                            _buildDivider(),
                            _buildMenuItem(
                              icon: Icons.groups_rounded,
                              title: 'Meet the Team',
                              onTap: () => context.push('/profile/about-us'),
                            ),
                          ]),

                          const SizedBox(height: 32),

                          // Logout Button
                          _buildLogoutButton(),

                          const SizedBox(height: 40),
                          Text(
                            'Version 2.0.0 (Build 2025)',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 80), // Bottom padding
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

  // --- HEADER WIDGET (MATCHING HOME & FAV) ---
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
          // KANAN: Settings/Logout Icon (Contextual for Profile)
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: _handleLogout,
          ),
        ],
      ),
    );
  }

  // --- CONTENT WIDGETS ---

  Widget _buildProfileCard() {
    return Stack(
      children: [
        // Background Glow
        Positioned.fill(
          child: Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Column(
          children: [
            // Avatar
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A2E), // Fallback bg
                ),
                child: const Icon(Icons.person_rounded,
                    size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              AppData.currentUser?.username.toUpperCase() ?? 'GUEST',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            // Email
            Text(
              AppData.currentUser?.email ?? 'Sign in to sync data',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            // Level Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.3)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.military_tech_rounded,
                      color: Color(0xFFFFD700), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Bibliophile Lvl. 5',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsRow() {
    return Row(
      children: [
        Expanded(
          child: BlocBuilder<BookLibraryCubit, BookLibraryState>(
            builder: (context, state) {
              String total = '0';
              if (state is BookLibraryLoaded) {
                total = '${state.totalBookCount}';
              } else {
                total = '${AppData.books.length}';
              }
              return _buildStatItem('Library', total, Icons.menu_book_rounded);
            },
          ),
        ),
        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
        Expanded(
          child: _buildStatItem(
              'Favorites', '${AppData.favoriteBooks.length}', Icons.favorite_rounded),
        ),
        Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
        Expanded(
          child: _buildStatItem('Reviews', '12', Icons.star_rate_rounded),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8B5CF6), size: 22),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingChallenge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.15),
            const Color(0xFF8B5CF6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Goal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '3 / 5 Books',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 0.6, // 60%
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'You are on a 5-day streak! Keep reading to earn the "Bookworm" badge.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
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
              Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
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
      indent: 58,
    );
  }

  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: _handleLogout,
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFFEF4444),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.3)),
        ),
      ),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text(
        'Log Out',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}