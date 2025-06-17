import 'package:flutter/material.dart';
import 'package:branch_comm/screen/sign_in/view/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:branch_comm/widgets/network_wrapper.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  //await dotenv.load(fileName: '.env');

  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode("en");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),

      home: NetworkWrapper(child: SignIn()),
    );
  }
}

