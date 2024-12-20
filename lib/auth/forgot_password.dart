import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/auth/confirm_reset_password_screen.dart';
import 'package:task_manager_app/services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Forgot password',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text('Send code'),
            ),
          ],
        ),
      ),
    );
  }

  void resetPassword() async {
    final username = _usernameController.text.trim();
    final authService = Provider.of<AuthService>(context, listen: false);

    // Trigger password reset
    final error = await authService.resetPassword(username);

    if (!mounted) return;

    if (error == null) {
      // Reset password trigger successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset password trigger successful')),
      );

      // Navigate to ConfirmResetPasswordScreen
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConfirmResetPasswordScreen(username: username),
      ));
    } else {
      // Sign-up failed, display the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trigger reset password failed: $error')),
      );
    }
  }
}
