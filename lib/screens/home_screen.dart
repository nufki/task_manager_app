import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/auth/signin_screen.dart';
import 'package:task_manager_app/screens/task_manager_screen.dart';

import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void signOut(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signOut();

    if (!context.mounted) return;

    if (error == null) {
      // Sign-out successful, navigate to sign-in screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignInScreen(),
        ),
      );
    } else {
      // Display error message if sign-out fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout,
            ),
            onPressed: () => signOut(context),
            color: Colors.white,
          ),
        ],
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: TaskManagerScreen(),
    );
  }
}
