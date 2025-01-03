import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:task_manager_app/auth/signin_screen.dart';
import 'package:task_manager_app/providers/task_provider.dart';
import 'package:task_manager_app/providers/user_provider.dart';
import 'package:task_manager_app/services/auth_service.dart';

import 'config/amplifyconfiguration.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureAmplify();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) =>
              TaskProvider(Provider.of<AuthService>(context, listen: false)),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (context) =>
              UserProvider(Provider.of<AuthService>(context, listen: false)),
        ),
      ],
      child: const TaskManagerApp(),
    ),
  );
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyconfig);
    safePrint('Successfully configured Amplify');
  } on AmplifyAlreadyConfiguredException {
    safePrint('Amplify was already configured. Skipping config.');
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
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        cardTheme: CardTheme(
          //color: Color(0xffd1c4e9), // White cards to stand out
          elevation: 1, // Slight shadow for depth
          margin: EdgeInsets.symmetric(vertical: 5.0),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0)), // Rounded edges
        ),
        appBarTheme: AppBarTheme(
            color: Colors
                .deepPurple, // Set AppBar color to primary color (same as the primarySwatch)
            elevation: 0, // Optional: Flat design for a cleaner look
            iconTheme: IconThemeData(
                color: Colors.white), // Set icons in the app bar to white
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 18)),
      ),
      // theme: ThemeData(
      //   primaryColor: Color(0xffd1c4e9), // Deep Purple
      //   hintColor: Color(0xFF00BCD4), // Cyan
      //   buttonTheme: ButtonThemeData(
      //     buttonColor: Color(0xffd1c4e9), // Deep Purple for buttons
      //   ),
      //   appBarTheme: AppBarTheme(
      //     color: Color(0xffd1c4e9), // Deep Purple for AppBar
      //   ),
      //   scaffoldBackgroundColor: Colors.white,
      //   textTheme: TextTheme(
      //     bodyLarge: TextStyle(color: Color(0xFF00BCD4)), // Cyan text
      //   ),
      //   // Add more customizations if necessary
      // ),
      home: Scaffold(
        body: _isSignedIn ? HomeScreen() : SignInScreen(),
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
}
