// lib/presentation/pages/login_screen.dart

import 'dart:ui'; // Diperlukan untuk ImageFilter (Blur effect)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/app_data.dart';
import '../../domain/entities/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // --- Logic Variables ---
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLogin = true;
  bool _isLoading = false;

  // --- UI/Animation Variables ---
  late AnimationController _animationController;
  late Animation<double> _mainFadeAnimation;
  late Animation<Offset> _mainSlideAnimation;

  // Animasi tambahan untuk elemen form agar muncul bertahap
  late Animation<double> _formDelayedFadeAnimation;
  late Animation<Offset> _formDelayedSlideAnimation;

  // Focus Nodes untuk efek highlight pada input field
  final FocusNode _userFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  bool _isUserFocused = false;
  bool _isPassFocused = false;

  @override
  void initState() {
    super.initState();

    // Setup listener untuk fokus input field
    _userFocusNode.addListener(() {
      setState(() => _isUserFocused = _userFocusNode.hasFocus);
    });
    _passFocusNode.addListener(() {
      setState(() => _isPassFocused = _passFocusNode.hasFocus);
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Durasi sedikit diperpanjang
      vsync: this,
    );

    // Animasi Utama (Logo & Teks Header) - Muncul lebih awal
    _mainFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _mainSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Animasi Tertunda (Form Fields & Button) - Muncul sedikit setelah header
    _formDelayedFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    _formDelayedSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _userFocusNode.dispose();
    _passFocusNode.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _usernameController.clear();
      _passwordController.clear();
      // Reset state animation saat toggle mode
      _animationController.reset();
      _animationController.forward();
    });
  }

  Future<void> _submitForm() async {
    // Tutup keyboard saat submit
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulasi loading network
      await Future.delayed(const Duration(milliseconds: 1500));

      String username = _usernameController.text.trim();
      String password = _passwordController.text;

      if (_isLogin) {
        User? user = AppData.users.cast<User?>().firstWhere(
              (user) =>
                  user?.username == username && user?.password == password,
              orElse: () => null,
            );

        if (user != null) {
          AppData.currentUser = user;
          if (mounted) context.go('/home');
        } else {
          _showMessage('Invalid credentials.', isError: true);
        }
      } else {
        bool userExists = AppData.users.any((u) => u.username == username);
        if (userExists) {
          _showMessage('Username already exists!', isError: true);
        } else {
          if (password.length < 6) {
            _showMessage('Password min 6 characters!', isError: true);
            setState(() => _isLoading = false);
            return;
          }
          AppData.users.add(User(username, password, '$username@email.com'));
          _showMessage('Account created successfully!');
          _toggleAuthMode();
        }
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(20),
        width: 400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0F23),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),

          // 2. BACKGROUND PARTICLES (Decorations)
          _buildBackgroundDecorations(),

          // 3. MAIN CONTENT
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              // Menggunakan animasi utama untuk container keseluruhan
              child: FadeTransition(
                opacity: _mainFadeAnimation,
                child: SlideTransition(
                  position: _mainSlideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/logo.png',
                          width: 100,
                          height: 100,
                          errorBuilder: (ctx, _, __) => const Icon(
                            Icons.auto_stories_rounded,
                            size: 80,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // HEADER TEXT
                      Text(
                        _isLogin ? 'Welcome Back!' : 'Join Us Today',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // TAMBAHAN: Tagline Text
                      Text(
                        _isLogin
                            ? 'Unlock a universe of stories and knowledge.'
                            : 'Begin your digital reading adventure.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.5),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // --- FORM CARD (GLASSMORPHISM) ---
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Form(
                                key: _formKey,
                                // Menggunakan animasi tertunda untuk isi form
                                child: FadeTransition(
                                  opacity: _formDelayedFadeAnimation,
                                  child: SlideTransition(
                                    position: _formDelayedSlideAnimation,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _buildTextField(
                                          controller: _usernameController,
                                          focusNode: _userFocusNode,
                                          isFocused: _isUserFocused,
                                          label: 'Username',
                                          icon: Icons.person_outline_rounded,
                                        ),
                                        const SizedBox(height: 20),
                                        _buildTextField(
                                          controller: _passwordController,
                                          focusNode: _passFocusNode,
                                          isFocused: _isPassFocused,
                                          label: 'Password',
                                          icon: Icons.lock_outline_rounded,
                                          isPassword: true,
                                        ),
                                        const SizedBox(height: 32),

                                        // BUTTON
                                        _buildGradientButton(),

                                        const SizedBox(height: 24),

                                        // TOGGLE
                                        _buildAuthToggle(),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Text(
                        '© 2025 Kelompok 2 Digital Library',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            // PERBAIKAN: Border menyala saat fokus
            border: Border.all(
              color: isFocused
                  ? const Color(0xFF6366F1).withOpacity(0.5)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2)
                  ]
                : [],
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isPassword && _obscureText,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.white54, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        // PERBAIKAN: Warna ikon mata disamakan dengan prefixIcon
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              isDense: true,
            ),
            validator: (value) => value!.isEmpty ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildGradientButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submitForm,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _isLogin ? 'Sign In' : 'Create Account',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthToggle() {
    return GestureDetector(
      onTap: _toggleAuthMode,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent, // Hitbox lebih besar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "New here? " : "Already have an account? ",
              style:
                  TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
            ),
            Text(
              _isLogin ? "Create Account" : "Sign In",
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.15),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}