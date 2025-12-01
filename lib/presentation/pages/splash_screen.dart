// lib/presentation/pages/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Import GoRouter

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation =
        Tween<double>(begin: 0, end: 1).animate(_rotateController);

    _shimmerAnimation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _controller.forward();
    _pulseController.repeat(reverse: true);
    _rotateController.repeat();
    _shimmerController.repeat(reverse: true);

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Menggunakan GoRouter untuk navigasi ke Login
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI Code sama persis, tidak ada perubahan
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F0F23),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F0F23),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildBackgroundDecorations(),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, -_slideAnimation.value),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: Hero(
                                    tag: 'app_logo',
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF6366F1)
                                                .withOpacity(0.5),
                                            blurRadius: 60,
                                            spreadRadius: 20,
                                          ),
                                          BoxShadow(
                                            color: const Color(0xFF8B5CF6)
                                                .withOpacity(0.3),
                                            blurRadius: 80,
                                            spreadRadius: 30,
                                          ),
                                        ],
                                      ),
                                      child: Image.asset(
                                        'assets/logo.png',
                                        width: 180,
                                        height: 180,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 160,
                                            height: 160,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF6366F1),
                                                  Color(0xFF8B5CF6),
                                                  Color(0xFFEC4899),
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                            ),
                                            child: const Icon(
                                              Icons.auto_stories_rounded,
                                              size: 80,
                                              color: Colors.white,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 56),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value),
                          child: AnimatedBuilder(
                            animation: _shimmerAnimation,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  begin: Alignment(_shimmerAnimation.value, 0),
                                  end: Alignment(
                                      _shimmerAnimation.value + 0.5, 0),
                                  colors: [
                                    Colors.white.withOpacity(0.3),
                                    Colors.white,
                                    const Color(0xFF6366F1),
                                    const Color(0xFF8B5CF6),
                                    Colors.white.withOpacity(0.3),
                                  ],
                                  stops: [0.0, 0.3, 0.5, 0.7, 1.0],
                                ).createShader(bounds),
                                child: const Text(
                                  'Digital Libary',
                                  style: TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.5,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF6366F1).withOpacity(0.2),
                                  const Color(0xFF8B5CF6).withOpacity(0.2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Digital Excellence',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                        Transform.translate(
                          offset: Offset(0, _slideAnimation.value * 0.3),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF6366F1).withOpacity(0.3),
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(
                                width: 38,
                                height: 38,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    const Color(0xFF8B5CF6).withOpacity(0.5),
                                  ),
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 50),
                        Transform.translate(
                          offset: Offset(0, -_slideAnimation.value * 0.2),
                          child: Column(
                            children: [
                              Text(
                                'by Dammar Sanggalie',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.4),
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'v1.0.0',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.25),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -150,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.15),
                        const Color(0xFF6366F1).withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: -150,
          left: -150,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: -_rotateAnimation.value * 2 * 3.14159,
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.15),
                        const Color(0xFF8B5CF6).withOpacity(0.05),
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFEC4899).withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
