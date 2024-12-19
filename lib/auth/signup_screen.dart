import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/services/auth_service.dart';

import 'confirm_signup_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = true;
  bool _isEmailValid = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign-up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
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
                'Sign-up in the silly demo app :)',
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(labelText: 'Username'),
                      ),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          errorText:
                              _isEmailValid ? null : 'Invalid email format',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _isEmailValid = EmailValidator.validate(value);
                          });
                        },
                      ),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        obscureText: _obscurePassword,
                        onChanged: checkPasswordMatch,
                      ),
                      TextField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm password',
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          errorText:
                              _passwordsMatch ? null : 'Passwords do not match',
                        ),
                        obscureText: _obscureConfirmPassword,
                        onChanged: checkPasswordMatch,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed:
                            (_passwordsMatch && _isEmailValid) ? signUp : null,
                        child: Text('Sign-up'),
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

  void checkPasswordMatch(String _) {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final authService = Provider.of<AuthService>(context, listen: false);

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    // Validate email
    if (!EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    // Attempt sign-up using AuthService
    final error = await authService.signUp(username, email, password);

    if (!mounted) return;

    if (error == null) {
      // Sign-up successful, prompt for confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Sign up successful! Please confirm your account.')),
      );

      // Navigate to the ConfirmSignUpScreen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConfirmSignUpScreen(username: username),
      ));
    } else {
      // Sign-up failed, display the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $error')),
      );
    }
  }
}
