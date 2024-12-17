import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'signup_screen.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onSignedOut;

  SignInScreen({required this.onSignedIn, required this.onSignedOut});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  void _signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final error = await _authService.signIn(username, password);
    if (error == null) {
      widget.onSignedIn();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username')),
            TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _signIn, child: Text('Sign In')),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SignUpScreen(
                      onSignedIn: widget.onSignedIn,
                      onSignedOut: widget.onSignedOut),
                ),
              ),
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
