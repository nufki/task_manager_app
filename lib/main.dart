import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:task_manager_app/signin_screen.dart';

import 'amplifyconfiguration2.dart';
import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  runApp(const TaskManagerApp());
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured Amplify');
  } on AmplifyAlreadyConfiguredException {
    safePrint('Amplify was already configured. Skipping configuration.');
  } catch (e) {
    safePrint('Error configuring Amplify: $e');
  }
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  bool _isSignedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager App',
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Task Manager App',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: _isSignedIn
            ? HomeScreen(
                onSignedOut: _onSignedOut,
              )
            : SignInScreen(
                onSignedIn: _onSignedIn,
                onSignedOut: _onSignedOut,
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      final authSession = await Amplify.Auth.fetchAuthSession();
      setState(() {
        _isSignedIn = authSession.isSignedIn;
      });
    } catch (e) {
      setState(() {
        _isSignedIn = false;
      });
    }
  }

  void _onSignedIn() {
    setState(() {
      _isSignedIn = true;
    });
  }

  void _onSignedOut() {
    setState(() {
      _isSignedIn = false;
    });
  }
}

/* the shit below does not work for me
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      signUpForm: SignUpForm.custom(
        fields: [
          SignUpFormField.email(),
          SignUpFormField.username(),
          SignUpFormField.password(),
          SignUpFormField.passwordConfirmation(),
        ],
      ),
      child: MaterialApp(
        builder: Authenticator.builder(),
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SignOutButton(),
                Text('TODO Application'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
*/
