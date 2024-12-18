import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/home_screen.dart';
import 'package:task_manager_app/services/auth_service.dart';

class ConfirmSignUpScreen extends StatefulWidget {
  final String username;

  const ConfirmSignUpScreen({
    super.key,
    required this.username,
  });

  @override
  State<ConfirmSignUpScreen> createState() => _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends State<ConfirmSignUpScreen> {
  final _confirmationCodeController = TextEditingController();

  void confirmSignUp() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final confirmationCode = _confirmationCodeController.text.trim();

    final error =
        await authService.confirmSignUp(widget.username, confirmationCode);

    if (!mounted) return;

    if (error == null) {
      // Confirmation successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Account confirmed successfully! Please sign in.')),
      );

      // Navigate to the Sign-In screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(),
        ),
      );
    } else {
      // Handle error during confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation failed: $error')),
      );
    }
  }

  void resendCode() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    final error = await authService.resendConfirmationCode(widget.username);

    if (!mounted) return;

    if (error == null) {
      // Resend successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation code resent successfully!')),
      );
    } else {
      // Handle error during resend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resending code: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm Sign Up',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _confirmationCodeController,
              decoration: InputDecoration(labelText: 'Confirmation Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmSignUp,
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: resendCode,
              child: Text('Resend Confirmation Code'),
            ),
          ],
        ),
      ),
    );
  }
}
