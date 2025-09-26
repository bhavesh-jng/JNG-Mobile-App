import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _growthController;
  late AnimationController _expandController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderWidthAnimation;
  late Animation<double> _shineAnimation;
  late Animation<double> _expandAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _growthController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.easeOutBack),
    );

    _borderWidthAnimation = Tween<double>(begin: 2.0, end: 4.0).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.easeOut),
    );

    _shineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growthController, curve: Curves.easeInOut),
    );

    _expandAnimation = Tween<double>(
      begin: 1.0,
      end: 30.0,
    ).animate(CurvedAnimation(parent: _expandController, curve: Curves.easeIn));

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _expandController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _startAnimation();
  }

  void _startAnimation() async {
    await _mainController.forward();
    await _growthController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    await _expandController.forward();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/roles');
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _growthController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _mainController,
            _growthController,
            _expandController,
          ]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value * _expandAnimation.value,
              child: Opacity(
                // ***** THE ONLY CHANGE IS ON THIS LINE *****
                opacity: _expandController.value > 0
                    ? _fadeOutAnimation.value
                    : _fadeInAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.5),
                      width: _borderWidthAnimation.value,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'JNG',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: Colors.white.withOpacity(
                              _shineAnimation.value * 0.8,
                            ),
                            blurRadius: 20 * _shineAnimation.value,
                          ),
                          Shadow(
                            color: Colors.lightBlueAccent.withOpacity(
                              _shineAnimation.value * 0.6,
                            ),
                            blurRadius: 30 * _shineAnimation.value,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
