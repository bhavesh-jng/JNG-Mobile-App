// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui'; // Required for blur effects if ever needed.

// NOTE TO DEVELOPER: If you encounter a 'withOpacity' error on web,
// run the app with the HTML renderer using the command:
// flutter run -d chrome --web-renderer html

// Enum to manage which role is currently selected.
enum UserRole { none, buyer, vendor }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  UserRole _selectedRole = UserRole.none;
  late AnimationController _borderAnimationController;
  late AnimationController _pulseAnimationController;

  bool _areAnimationsInitialized = false;

  // NEW: Professional white theme color palette
  final Color _backgroundColor = const Color(0xFFFFFFFF); // White
  final Color _primaryText = const Color(0xFF212121); // Almost Black
  final Color _secondaryText = const Color(0xFF757575); // Medium Grey
  final Color _buttonColor = const Color(0xFF2D2D2F); // Dark grey for button

  // NEW: Gradient colors for cards inspired by the reference image
  final List<Color> _buyerGradient = const [
    Color(0xFFD0BCFF), // Light Purple
    Color(0xFFF3EFFF), // Very Light Lilac
  ];

  final List<Color> _vendorGradient = const [
    Color(0xFFADC6FF), // Light Blue
    Color(0xFFF0F4FF), // Very Light Sky Blue
  ];

  // Google Gemini inspired gradient for the border animation
  final List<Color> _geminiBorderGradient = const [
    Color(0xFF4285F4), // Google Blue
    Color(0xFF34A853), // Google Green
    Color(0xFFFBBC05), // Google Yellow
    Color(0xFFEA4335), // Google Red
    Color(0xFF4285F4), // Loop back to Blue
  ];

  @override
  void initState() {
    super.initState();
    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      reverseDuration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _areAnimationsInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _borderAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  void _onRoleSelected(UserRole role) {
    if (!mounted) return;

    setState(() {
      _selectedRole = role;
    });

    _borderAnimationController.forward(from: 0.0);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _borderAnimationController.stop();
        // UPDATED: Conditional navigation based on the selected role
        if (role == UserRole.buyer) {
          Navigator.pushReplacementNamed(context, '/buyer_form');
        } else if (role == UserRole.vendor) {
          Navigator.pushReplacementNamed(context, '/seller_form');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: !_areAnimationsInitialized
          ? Center(child: CircularProgressIndicator(color: _primaryText))
          : Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 80),
                          Text(
                            'Choose Your Role',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: _primaryText,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Select how you want to experience our platform.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: _secondaryText,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 60),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleCard(
                                  role: UserRole.buyer,
                                  icon: Icons.shopping_bag_outlined,
                                  title: 'Buyer',
                                  description: 'Browse some products.',
                                  gradientColors: _buyerGradient,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: _buildRoleCard(
                                  role: UserRole.vendor,
                                  icon: Icons.storefront_outlined,
                                  title: 'Seller',
                                  description: 'Sell your products.',
                                  gradientColors: _vendorGradient,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildVerifyButton(),
              ],
            ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required IconData icon,
    required String title,
    required String description,
    required List<Color> gradientColors,
  }) {
    final bool isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => _onRoleSelected(role),
      child: AnimatedScale(
        scale: isSelected ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: AnimatedBuilder(
          animation: _borderAnimationController,
          builder: (context, child) {
            final borderDecoration = isSelected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: SweepGradient(
                      colors: _geminiBorderGradient,
                      transform: GradientRotation(
                        _borderAnimationController.value * 6.28,
                      ),
                    ),
                  )
                : null;

            return Container(
              padding: isSelected ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
              decoration: borderDecoration,
              child: Container(
                height: 230,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: _primaryText),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: _primaryText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: _secondaryText,
                  fontWeight: FontWeight.w400,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Positioned(
      bottom: 40,
      right: 24,
      child: ScaleTransition(
        scale: Tween<double>(
          begin: 0.96,
          end: 1.0,
        ).animate(_pulseAnimationController),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/signup');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shadowColor: Colors.black.withOpacity(0.2),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          icon: const Icon(Icons.verified_user_outlined),
          label: const Text(
            'Verify as Merchant',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
