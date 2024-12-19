import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class AuthService {
  // Signup
  Future<String?> signUp(String username, String email, String password) async {
    try {
      await Amplify.Auth.signUp(
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

  // Confirm sign-up
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

  // Sign-in
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

  // Sign-out
  Future<String?> signOut() async {
    try {
      await Amplify.Auth.signOut();
      return null;
    } on AuthException catch (e) {
      return e.message;
    }
  }

  // Resend sign-up confirmation code
  Future<String?> resendSignupCode(String username) async {
    try {
      await Amplify.Auth.resendSignUpCode(username: username);
      return null; // Success
    } on AuthException catch (e) {
      return e.message; // Return error message on failure
    }
  }

  // Reset password
  Future<String?> resetPassword(String username) async {
    try {
      await Amplify.Auth.resetPassword(username: username);
      return null; // Success
    } on AuthException catch (e) {
      return e.message; // Return error message on failure
    }
  }

  // Confirm reset password
  Future<String?> confirmResetPassword(
      String username, String newPassword, String confirmationCode) async {
    try {
      await Amplify.Auth.confirmResetPassword(
          username: username,
          newPassword: newPassword,
          confirmationCode: confirmationCode);
      return null; // Success
    } on AuthException catch (e) {
      return e.message; // Return error message on failure
    }
  }

  Future<String?> getToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      );
      if (session is CognitoAuthSession && session.isSignedIn) {
        return session.userPoolTokensResult.value.idToken.raw;
      } else {
        return null;
      }
    } on AuthException catch (e) {
      return null; // Return null if there's an error fetching the token
    }
  }
}
