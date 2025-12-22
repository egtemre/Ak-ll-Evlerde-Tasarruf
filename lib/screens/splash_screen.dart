import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

/// Splash Screen - Uygulama açılışında gösterilir
/// Database initialize ve oturum kontrolü yapar
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _houseController;
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _houseScaleAnimation;
  late Animation<double> _houseOpacityAnimation;
  late Animation<Offset> _houseSlideAnimation;
  late Animation<double> _houseRotationAnimation;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoGlowAnimation;
  late Animation<double> _logoRotationAnimation;

  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Ev animasyonu (0-1.8 saniye) - daha dramatik
    _houseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _houseScaleAnimation = Tween<double>(begin: 0.1, end: 3.5).animate(
      CurvedAnimation(
        parent: _houseController,
        curve: Curves.easeInOutBack,
      ),
    );

    _houseOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _houseController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _houseSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.4),
    ).animate(
      CurvedAnimation(
        parent: _houseController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutCubic),
      ),
    );

    _houseRotationAnimation =
        Tween<double>(begin: 0.0, end: math.pi * 2).animate(
      CurvedAnimation(
        parent: _houseController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    // Logo animasyonu (1.2-2.8 saniye) - daha dramatik
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1600),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.elasticOut,
      ),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeIn),
      ),
    );

    _logoGlowAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeInOut,
      ),
    );

    _logoRotationAnimation =
        Tween<double>(begin: -math.pi / 4, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutBack,
      ),
    );

    // Text animasyonu (2.2-3.2 saniye)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Particle animasyonu - sürekli
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Rotasyon animasyonu - sürekli
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 8000),
      vsync: this,
    )..repeat();

    // Pulse animasyonu - sürekli
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Animasyonları sırayla başlat
    _startAnimations();

    // Initialization
    _initialize();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _houseController.forward();

    await Future.delayed(const Duration(milliseconds: 1200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  Future<void> _initialize() async {
    // Animasyonların bitmesini bekle + ek süre (toplam ~4.5 saniye)
    await Future.delayed(const Duration(milliseconds: 4500));

    if (!mounted) return;

    // Onboarding kontrolü
    final prefs = await SharedPreferences.getInstance();

    // İlk kurulum için onboarding'i göster (sadece test/geliştirme için)
    // Production'da bu satırı kaldırın veya yoruma alın
    await prefs.remove('onboarding_completed');

    final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
    if (!mounted) return;

    if (onboardingCompleted) {
      // Onboarding tamamlanmış, login'e git
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // İlk kullanım, onboarding göster
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  void dispose() {
    _houseController.dispose();
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
              Colors.teal.shade600,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated particles arka planda
            ...List.generate(15, (index) {
              final delay = index * 0.2;
              return AnimatedBuilder(
                animation: _particleController,
                builder: (context, child) {
                  final progress = (_particleController.value + delay) % 1.0;
                  final x = math.cos(progress * math.pi * 2 + index) * 150;
                  final y = math.sin(progress * math.pi * 2 + index) * 150;
                  final opacity = (1 - progress) * 0.6;
                  return Positioned(
                    left: MediaQuery.of(context).size.width / 2 + x,
                    top: MediaQuery.of(context).size.height / 2 + y,
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 8 + (index % 3) * 4,
                        height: 8 + (index % 3) * 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.8),
                              Colors.white.withOpacity(0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // Arka plandaki ev ikonu - büyüyüp dönerek öne çıkıyor
            Center(
              child: AnimatedBuilder(
                animation: _houseController,
                builder: (context, child) {
                  return SlideTransition(
                    position: _houseSlideAnimation,
                    child: Opacity(
                      opacity: _houseOpacityAnimation.value,
                      child: Transform.rotate(
                        angle: _houseRotationAnimation.value,
                        child: Transform.scale(
                          scale: _houseScaleAnimation.value,
                          child: Icon(
                            Icons.home_rounded,
                            size: 120,
                            color: Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Dönen çemberler - arka planda
            Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_rotationController.value * 2 * math.pi,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Logo ve yazılar - ön planda
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container - parlama ve rotasyon efektiyle
                  AnimatedBuilder(
                    animation:
                        Listenable.merge([_logoController, _pulseController]),
                    builder: (context, child) {
                      final pulseScale = 1.0 + (_pulseController.value * 0.1);
                      return Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotationAnimation.value,
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value * pulseScale,
                            child: Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(38),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      0.8 * _logoGlowAnimation.value,
                                    ),
                                    blurRadius: 40 * _logoGlowAnimation.value,
                                    spreadRadius: 15 * _logoGlowAnimation.value,
                                  ),
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(
                                        0.4 * _logoGlowAnimation.value),
                                    blurRadius: 35 * _logoGlowAnimation.value,
                                    spreadRadius: 5 * _logoGlowAnimation.value,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 30,
                                    offset: const Offset(0, 18),
                                  ),
                                ],
                              ),
                              child: AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale:
                                        1.0 + (_pulseController.value * 0.15),
                                    child: const Icon(
                                      Icons.bolt,
                                      size: 75,
                                      color: AppTheme.primaryColor,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // App name ve açıklama - dramatik giriş
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.03),
                                child: const Text(
                                  'Akıllı Ev Enerji',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        blurRadius: 15,
                                        offset: Offset(0, 3),
                                      ),
                                      Shadow(
                                        color: Colors.white24,
                                        blurRadius: 20,
                                        offset: Offset(0, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enerji Tüketiminizi Optimize Edin',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.95),
                              fontSize: 17,
                              letterSpacing: 1.0,
                              fontWeight: FontWeight.w400,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 50),

                          // Loading indicator - pulse efektiyle
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.2),
                                child: Container(
                                  width: 45,
                                  height: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(
                                          0.3 * _pulseController.value,
                                        ),
                                        blurRadius: 20 * _pulseController.value,
                                        spreadRadius:
                                            5 * _pulseController.value,
                                      ),
                                    ],
                                  ),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white.withOpacity(0.95),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
