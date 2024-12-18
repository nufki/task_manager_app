import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  // Sign Up
  Future<String?> signUp(String username, String email, String password) async {
    try {
      SignUpResult result = await Amplify.Auth.signUp(
        username: username.trim(),
        password: password,
        options: SignUpOptions(userAttributes: {
          AuthUserAttributeKey.email: email.trim(),
        }),
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Confirm Sign Up
  Future<String?> confirmSignUp(String username, String code) async {
    try {
      await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: code,
      );
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Sign In
  Future<String?> signIn(String username, String password) async {
    try {
      SignInResult result = await Amplify.Auth.signIn(
        username: username,
        password: password,
      );
      return result.isSignedIn ? null : 'Sign-in incomplete';
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Sign Out
  Future<String?> signOut() async {
    try {
      await Amplify.Auth.signOut();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Resend Confirmation Code
  Future<String?> resendConfirmationCode(String username) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: username);
      return null; // Success
    } on AuthException catch (e) {
      return e.message; // Return error message on failure
    }
  }
}
