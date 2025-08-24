import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/glass_container.dart';

class LoadingPage extends StatefulWidget {
  final VoidCallback onLoadingComplete;

  const LoadingPage({super.key, required this.onLoadingComplete});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startLoading();
  }

  void _startLoading() async {
    // Start animations
    _fadeController.forward();
    _rotationController.repeat();

    // Simulate loading time
    await Future.delayed(const Duration(milliseconds: 2500));

    // Complete loading
    widget.onLoadingComplete();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _rotationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationController.value * 2 * pi,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // App name
                const Text(
                  'TOTEM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Fitness Tracking & Clan Competition',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 40),

                // Loading indicator
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue.shade400,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Loading your journey...',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
