import 'package:branch_comm/admin_screen/home/view/home.dart';
import 'package:branch_comm/services/sigin_auth.dart';
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
      // Define your named routes
      home: AuthWrapper(),
      routes: {
        '/signin': (context) => const SignIn(),
        '/home': (context) => const Home(),
        '/admin': (context) => const AdminHome(),
      },
      // Optional: Fallback for unknown routes
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (context) => const SignIn());
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User not authenticated
        if (snapshot.data == null) {
          return const SignIn();
        }

        // User is authenticated, now check their role
        return FutureBuilder<UserRole?>(
          future: SiginAuth.getUserRole(),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading...'),
                    ],
                  ),
                ),
              );
            }

            print("User role: ${roleSnapshot.data}");

            // Update last login
            SiginAuth.updateLastLogin();

            // Handle different role scenarios
            if (roleSnapshot.data == UserRole.admin) {
              return const AdminHome();
            } else if (roleSnapshot.data == UserRole.user) {
              return const Home();
            } else {

              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.black),
                      SizedBox(height: 16),
                      Text(
                        'Account not found in system',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Please contact administrator',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: Text(
                          'Sign Out',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}
