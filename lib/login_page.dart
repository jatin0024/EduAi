// lib/login_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Get the Firebase Auth instance
  bool _isLoading = false; // To show a loading indicator

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Basic validation
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar('Please enter both email and password.', isError: true);
      return;
    }

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      // Attempt to sign in with email and password
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Login successful, navigate to the home page (AI Tutor page)
      // pushReplacementNamed prevents going back to login via back button
      Navigator.of(context).pushReplacementNamed('/home');

    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Authentication errors
      String message = 'An unknown error occurred. Please try again.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed login attempts. Please try again later.';
      } else {
        message = e.message ?? message; // Use Firebase's error message if available
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      // Catch any other unexpected errors
      _showSnackBar('An unexpected error occurred: ${e.toString()}', isError: true);
      print('Login error: $e'); // For debugging
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  // Helper function to show a SnackBar message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Makes it float above content
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Background Image and space
          Column(
            children: <Widget>[
              const SizedBox(height: 50),
              Image.network(
                'https://thumbs.dreamstime.com/b/woman-working-remote-project-home-cartoon-character-female-freelancer-sitting-table-fulfilling-tasks-laptop-flat-181611910.jpg',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
          // Login Form Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: const BoxDecoration(
                color: Color(0xFFECE6E6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min, // Use min to wrap content
                  children: <Widget>[
                    const Text(
                      'LOGIN',
                      style: TextStyle(
                        color: Color(0xFF002131),
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Email Input Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress, // Suggest email keyboard
                      decoration: InputDecoration(
                        hintText: 'Email', // Changed from 'Name' to 'Email'
                        hintStyle: const TextStyle(color: Color(0xFF531002)),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Password Input Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true, // Hide password
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: Color(0xFF531002)),
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Login Button or Loading Indicator
                    _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF48A9A6), // Progress indicator color
                      ),
                    )
                        : ElevatedButton(
                      onPressed: _login, // Call the login method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48A9A6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Don't have an account? Sign Up text
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text('Don\'t have an account?'),
                          TextButton(
                            onPressed: () {
                              // Navigate to the signup page
                              Navigator.of(context).pushNamed('/signup');
                            },
                            child: const Text(
                              'SIGN UP',
                              style: TextStyle(
                                color: Color(0xFF002131),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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