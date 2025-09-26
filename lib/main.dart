import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/merchant/landing_page.dart';
import 'package:flutter_application_1/screens/roles.dart';
import 'package:flutter_application_1/screens/signup.dart';
import 'firebase_options.dart';
import 'package:flutter_application_1/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JNG App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      // Start with the main app navigator
      home: const AppNavigator(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/roles': (context) => const RoleSelectionScreen(),
        '/signup': (context) => const AuthScreen(),
        '/landing': (context) => const LandingPage(),
        '/buyer_form': (context) => const BuyerFormPlaceholder(),
        '/seller_form': (context) => const SellerFormPlaceholder(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// App Navigator that handles the splash + role flow
class AppNavigator extends StatefulWidget {
  const AppNavigator({Key? key}) : super(key: key);

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Show splash screen for 9 seconds
    await Future.delayed(const Duration(seconds: 8));
    
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return const SplashScreen();
    }
    
    // After splash, ALWAYS show roles screen first
    // The AuthScreen will handle authentication state internally
    return const RoleSelectionScreen();
  }
}

// Placeholder screens for buyer/seller forms
class BuyerFormPlaceholder extends StatelessWidget {
  const BuyerFormPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buyer Registration')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Buyer Registration Form'),
            Text('(To be implemented)'),
          ],
        ),
      ),
    );
  }
}

class SellerFormPlaceholder extends StatelessWidget {
  const SellerFormPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller Registration')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Seller Registration Form'),
            Text('(To be implemented)'),
          ],
        ),
      ),
    );
  }
}
