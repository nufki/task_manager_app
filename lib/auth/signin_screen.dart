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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sign-in',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signIn,
              child: Text('Sign-in'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SignUpScreen()),
              ),
              child: Text('Don\'t have an account? Sign-up'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
              ),
              child: Text('Reset password'),
            ),
          ],
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
      print('error: $error');
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
}
