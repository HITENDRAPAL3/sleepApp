import 'package:flutter/material.dart';
import '../models/sleep_quote.dart';
import '../services/quote_service.dart';
import '../services/preferences_service.dart';
import '../widgets/background_container.dart';
import 'night_timer_page.dart';
import 'white_noise_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  SleepQuote? _currentQuote;
  bool _isFirstTime = true;
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  Future<void> _loadData() async {
    try {
      final quote = await QuoteService.getRandomQuote();
      final isFirstTime = await PreferencesService.isFirstTimeUser();

      setState(() {
        _currentQuote = quote;
        _isFirstTime = isFirstTime;
        _isLoading = false;
      });

      // Start animations
      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 500), () {
        _scaleController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToNightTimer() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NightTimerPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90E2),
        ),
      )
          : WelcomeBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App Icon/Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A90E2),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4A90E2).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.bedtime_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App Title
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Sleep Cycle',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    'Improve Your Sleep, Improve Your Life',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF4A90E2),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 48),

                // Quote Section
                if (_currentQuote != null)
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D3748),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A90E2).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.format_quote,
                            color: const Color(0xFF4A90E2),
                            size: 32,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _currentQuote!.quote,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '— ${_currentQuote!.author}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF4A90E2),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                const Spacer(),

                // Action Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _navigateToNightTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: const Color(0xFF4A90E2).withOpacity(0.4),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isFirstTime ? Icons.play_arrow_rounded : Icons.settings_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isFirstTime ? "Let's fix your sleep cycle" : "Change settings",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // White Noise Button
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _navigateToWhiteNoise,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF4A90E2), width: 2),
                          foregroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.waves,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'White Noise & Sounds',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToWhiteNoise() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WhiteNoisePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }
}