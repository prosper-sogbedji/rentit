import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../main.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Redirection fluide après vérification de la session
    Future.delayed(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;

      Widget targetScreen = const LoginScreen();

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null && currentUser.email != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          if (mounted) {
            final data = doc.data();
            final name = (data != null && data['name'] != null && (data['name'] as String).isNotEmpty)
                ? data['name'] as String
                : currentUser.email!.split('@').first;
            final phone = data?['phone'] as String? ?? '';
            context.read<UserProvider>().updateProfile(
              name: name,
              email: currentUser.email!,
              phone: phone,
              location: 'Paris, France',
            );
            targetScreen = const MainShell();
          }
        }
      } catch (e) {
        debugPrint('Auto-login check notice: $e');
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, animation, _) => FadeTransition(
            opacity: animation,
            child: targetScreen,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fond subtil avec halo bleu clair
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2563EB).withValues(alpha: 0.04),
              ),
            ),
          ),

          // Contenu central animé
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Conteneur du logo officiel
                    Container(
                      width: 130,
                      height: 130,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Container(
                            color: const Color(0xFF2563EB),
                            child: const Icon(
                              Icons.handshake_rounded,
                              color: Colors.white,
                              size: 54,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Nom de l'application
                    const Text(
                      'RentIt',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.8,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Slogan
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Equipment & Tools Rental',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Indicateur discret en bas
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          const Color(0xFF2563EB).withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade400,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
