import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/auth/signin_screen.dart';
import 'package:task_manager_app/services/auth_service.dart';

class ConfirmResetPasswordScreen extends StatefulWidget {
  final String username;

  const ConfirmResetPasswordScreen({
    super.key,
    required this.username,
  });

  @override
  State<ConfirmResetPasswordScreen> createState() =>
      _ConfirmResetPasswordScreenState();
}

class _ConfirmResetPasswordScreenState
    extends State<ConfirmResetPasswordScreen> {
  final _confirmationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _passwordsMatch = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Confirm reset password',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _confirmationCodeController,
              decoration: InputDecoration(labelText: 'Confirmation code'),
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
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                errorText: _passwordsMatch ? null : 'Passwords do not match',
              ),
              obscureText: _obscureConfirmPassword,
              onChanged: checkPasswordMatch,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: confirmResetPassword,
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  void confirmResetPassword() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final confirmationCode = _confirmationCodeController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check if passwords match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final error = await authService.confirmResetPassword(
      widget.username,
      password,
      confirmationCode,
    );

    if (!mounted) return;

    if (error == null) {
      // Confirmation successful
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Password has been successfully reset. Please sign in again')),
      );

      // Navigate to the Sign-In screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignInScreen(),
        ),
      );
    } else {
      // Handle error during confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirm reset password failed: $error')),
      );
    }
  }

  void checkPasswordMatch(String _) {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }
}
