import 'package:flutter/material.dart';
import 'package:branch_comm/screen/sign_in/view/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
// Import your home page or other screens
import 'package:branch_comm/screen/home_page/view/home.dart'; // Make sure to import your home screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  //await dotenv.load(fileName: '.env');

  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  FirebaseAuth.instance.setLanguageCode("en");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Initial route based on authentication state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Show a loading screen
          }
          
          // Explicitly handle null user (logged out)
          if (snapshot.data == null) {
            return const SignIn();
          }
          
          return const Home();
        },
      ),
      // Define your named routes
      routes: {
        '/signin': (context) => const SignIn(),
        '/home': (context) => const Home(),
      },
      // Optional: Handle routes not defined above
      onGenerateRoute: (settings) {
        // You can add more route handling here if needed
        return null;
      },
      // Optional: Fallback for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SignIn());
      },
    );
  }
}