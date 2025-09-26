import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignUp = true;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final GoogleSignIn _googleSignInClient = GoogleSignIn(
    clientId: '686756139829-3kkm76dnuae6ugjrcenvh9dstv8mlb08.apps.googleusercontent.com',
    scopes: ['email', 'profile', 'openid'],
  );

  // NEW: A set of allowed domains for efficient lookup.
  final Set<String> _allowedDomains = {
    'jnitin.com',
    'jnitinglobal.com',
    'originate.in',
    'societyoflifestyle.in',
    'abia.in',
    'arpl-alm.in',
    'home4u.in',
    'housedoctor.org.in',
    'inv-studio.in',
    'invhome.in',
    'invstudio.in',
  };

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

// NEW: An elegant dialog to show authorization errors.
void _showAuthErrorDialog(String message) {
  showDialog(
    context: context,
    // Prevents dismissing the dialog by tapping outside of it
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return BackdropFilter(
        // This applies the blur effect to the background
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white,
          elevation: 24.0,
          // Defines the card-like shape with rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          // Icon for visual context
          icon: const Icon(Icons.lock_outline, color: Colors.black87, size: 40),
          title: const Text(
            'Access Denied',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            // A more prominent button for the primary action
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('OK', style: TextStyle(fontSize: 16)),
              onPressed: () {
                // First, pop the dialog
                Navigator.of(ctx).pop();
                // Then, navigate to the roles screen
                Navigator.pushReplacementNamed(context, '/roles');
              },
            )
          ],
        ),
      );
    },
  );
}

  // ... (Your other methods like _inputDecoration, _showErrorSnackBar, )

  // UPDATED: This method now contains the domain check logic.
  Future<void> _handleGoogleSignInSuccess(GoogleSignInAccount googleUser) async {
    // --- DOMAIN CHECK ---
    final String email = googleUser.email;
    final String domain = email.split('@').last;

    if (!_allowedDomains.contains(domain)) {
      print('❌ Domain not allowed: $domain');
      // Sign out to clear the session for the unauthorized user.
      await _googleSignInClient.signOut();
      _showAuthErrorDialog('You are not authorized as a Merchant');
      // Stop the process here.
      return;
    }
    // --- END DOMAIN CHECK ---

    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null) {
        throw Exception('Access token is missing from Google Auth.');
      }
      
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔄 Signing in to Firebase...');
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('✅ Firebase sign-in successful: ${userCredential.user?.email}');
      _showSuccessSnackBar('Welcome ${userCredential.user?.displayName ?? ''}!');

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } catch (e) {
      print('❌ Error handling Google sign-in success: ${e.toString()}');
      _showErrorSnackBar('Failed to complete Google sign-in. Please try again.');
    }
  }

  Future<void> _googleSignIn() async {
    if (_isGoogleLoading) return;

    setState(() {
      _isGoogleLoading = true;
    });

    try {
      await _googleSignInClient.signOut();
      await FirebaseAuth.instance.signOut();

      print('🔄 Starting Google Sign-In...');
      final GoogleSignInAccount? googleUser = await _googleSignInClient.signIn();

      if (googleUser == null) {
        print('❌ Google sign-in canceled by user.');
        return; // User cancelled the sign-in
      }

      print('✅ Google user obtained: ${googleUser.email}');
      await _handleGoogleSignInSuccess(googleUser);
    } catch (e) {
      print('❌ Google Sign-In Error: ${e.toString()}');
      _showErrorSnackBar('Failed to sign in with Google: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  // ... (The rest of your code (_submit, build methods, etc.) )

  InputDecoration _inputDecoration(
    String label,
    IconData icon, {
    Widget? prefix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefix ?? Icon(icon, color: Colors.grey.shade500, size: 20),
      filled: true,
      fillColor: Colors.grey.shade100,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message, style: const TextStyle(color: Colors.white)),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(message, style: const TextStyle(color: Colors.white)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (isSignUp) {
        final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (_nameController.text.trim().isNotEmpty) {
          await userCredential.user?.updateDisplayName(_nameController.text.trim());
        }

        _showSuccessSnackBar('Account created successfully!');
        print('✅ Email signup successful: ${userCredential.user?.email}');
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSuccessSnackBar('Signed in successfully!');
        print('✅ Email signin successful');
      }

      if (mounted) {
        print('🔄 Navigating to landing page...');
        Navigator.pushReplacementNamed(context, '/landing');
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred. Please check your credentials.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Invalid email or password.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      _showErrorSnackBar('An unexpected error occurred: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: _buildAuthCard(),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCustomToggle(),
            const SizedBox(height: 32),
            _buildForm(),
            _buildSeparator(),
            const SizedBox(height: 24),
            _buildGoogleSignInButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomToggle() {
    const double toggleWidth = 400 - 56;
    const double buttonWidth = toggleWidth / 2;

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isSignUp ? 0 : buttonWidth,
            right: isSignUp ? buttonWidth : 0,
            top: 0,
            bottom: 0,
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(child: _toggleButton("Sign Up", true)),
              Expanded(child: _toggleButton("Sign In", false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _toggleButton(String text, bool forSignUp) {
    bool isSelected = isSignUp == forSignUp;
    return GestureDetector(
      onTap: () {
        setState(() {
          isSignUp = forSignUp;
        });
      },
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        child: Column(
          children: [
            if (isSignUp) _buildNameField(),
            if (isSignUp) const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            if (isSignUp) _buildPhoneField(),
            if (isSignUp) const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 16),
            if (isSignUp) _buildConfirmPasswordField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              "OR",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300)),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black87,
          backgroundColor: Colors.grey.shade100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          side: BorderSide(color: Colors.grey.shade300),
        ),
        onPressed: _isGoogleLoading ? null : _googleSignIn,
        icon: _isGoogleLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              )
            : Image.asset(
                'assets/images/google_logo.png',
                height: 24.0,
              ),
        label: Text(
          _isGoogleLoading ? 'Signing in...' : 'Sign in with Google',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.black87),
      decoration: _inputDecoration('Full Name', Icons.person_outline),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      style: const TextStyle(color: Colors.black87),
      decoration: _inputDecoration('Email Address', Icons.email_outlined),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildIndiaCodePrefix() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "🇮🇳 +91",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(height: 20, width: 1, color: Colors.grey.shade400),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      style: const TextStyle(color: Colors.black87),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      decoration: _inputDecoration(
        'Phone Number',
        Icons.phone_outlined,
        prefix: _buildIndiaCodePrefix(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a phone number';
        }
        if (value.length != 10) {
          return 'Please enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      style: const TextStyle(color: Colors.black87),
      obscureText: _obscurePassword,
      decoration: _inputDecoration('Password', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade500,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      style: const TextStyle(color: Colors.black87),
      obscureText: _obscureConfirmPassword,
      decoration: _inputDecoration('Confirm Password', Icons.lock_outline)
          .copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey.shade500,
          ),
          onPressed: () => setState(
            () => _obscureConfirmPassword = !_obscureConfirmPassword,
          ),
        ),
      ),
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: _isLoading ? null : _submit,
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isSignUp ? 'Create Account' : 'Sign In',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}