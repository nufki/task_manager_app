import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/screens/home_screen.dart';

import '../../services/auth_service.dart';
import 'confirm_signup_screen.dart';
import 'forgot_password.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true; // To toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Task manager',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16), // Left and right margins
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Center the form vertically
            children: [
              SizedBox(height: 40), // Adjust the height for custom top margin
              Text(
                'Sign-in in the silly demo app :)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Adjust the height for custom top margin
              Card(
                elevation: 4, // Adds shadow for a better visual appearance
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align text to the left
                    children: [
                      SizedBox(height: 16),
                      // Username input field
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      // Password input field with toggle visibility
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // A separate Column to hold the buttons and links
                      ElevatedButton(
                        onPressed: signIn,
                        child: Text('Sign In'),
                      ),
                      SizedBox(height: 10),
                      // Link to sign-up screen
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()),
                        ),
                        child: Text('Don’t have an account? Sign up'),
                      ),
                      // Link to forgot password screen
                      TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ForgotPasswordScreen()),
                        ),
                        child: Text('Forgot your password?'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final authService = Provider.of<AuthService>(context, listen: false);

    final error = await authService.signIn(username, password);

    if (!mounted) return;

    if (error == null) {
      // Sign-in successful, navigate to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    } else {
      // Display error message if sign-in fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during sign-in: $error')),
      );
      if (error == 'Sign-in incomplete') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmSignUpScreen(username: username),
          ),
        );
      }
    }
  }

  // Toggle the password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }
}
