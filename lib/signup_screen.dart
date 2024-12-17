import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';

import 'confirm_signup_screen.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;

  const SignUpScreen({
    super.key,
    required this.onSignedIn,
    required this.onSignedOut,
  });

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
          'Sign Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
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
                errorText: _isEmailValid ? null : 'Invalid email format',
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
              onChanged: _checkPasswordMatch,
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                errorText: _passwordsMatch ? null : 'Passwords do not match',
              ),
              obscureText: _obscureConfirmPassword,
              onChanged: _checkPasswordMatch,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (_passwordsMatch && _isEmailValid) ? _signUp : null,
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  void _checkPasswordMatch(String _) {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    if (!EmailValidator.validate(_emailController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    try {
      await Amplify.Auth.signUp(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
        options: SignUpOptions(userAttributes: {
          AuthUserAttributeKey.email: _emailController.text.trim(),
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Sign up successful! Please confirm your account.')),
      );

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConfirmSignUpScreen(
          username: _usernameController.text,
          onSignedOut: widget.onSignedOut,
        ),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: ${e.toString()}')),
      );
    }
  }
}
