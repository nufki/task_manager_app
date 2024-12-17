import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/signin_screen.dart';

class ConfirmSignUpScreen extends StatefulWidget {
  final String username;
  final VoidCallback onSignedOut;

  const ConfirmSignUpScreen({
    super.key,
    required this.username,
    required this.onSignedOut,
  });

  @override
  State<ConfirmSignUpScreen> createState() => _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends State<ConfirmSignUpScreen> {
  final _confirmationCodeController = TextEditingController();

  void _confirmSignUp() async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: widget.username,
        confirmationCode: _confirmationCodeController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Account confirmed successfully! Please sign in.')),
      );

      // Navigate to the Sign-In screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SignInScreen(
                  onSignedOut: widget.onSignedOut,
                  onSignedIn: () {},
                )),
      );

      /*
      // Navigate to the HomeScreen after successful sign-up confirmation
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(onSignedOut: widget.onSignedOut)),
      );

       */
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Confirmation failed: ${e.toString()}')),
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
      ),
      backgroundColor: Colors.deepPurpleAccent,
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
              onPressed: _confirmSignUp,
              child: Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }
}
