import 'package:branch_comm/screen/sign_in/view/signin.dart';
import 'package:branch_comm/services/admin_shared_pref.dart';
import 'package:branch_comm/services/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:branch_comm/admin_screen/home/view/home.dart';

class AdminSignIn extends StatefulWidget {
  const AdminSignIn({super.key});

  @override
  State<AdminSignIn> createState() => _AdminSignInState();
}

class _AdminSignInState extends State<AdminSignIn> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? email, password;

  Future<void> adminSignIn() async {

    try { 
      
      if (!_formKey.currentState!.validate()) return;

      final adminCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );

      final admin = adminCredential.user;
      if (admin == null) return;

      final doc = await FirebaseFirestore.instance.collection('admins').doc(admin.uid).get();
      final data = doc.data();

      bool saved = await AdminSharedPreferenceHelper().saveAdminData(
        adminId: admin.uid,
        adminName: data?['name'] ?? '',
        adminEmail: data?['email'] ?? '',
        adminStatus: data?['status'] ?? '',
      );
      
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to save admin data."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (data != null) {
        // Admin found, navigate to admin home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Admin login successful."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
          (route) => false,
        );
      } else {
        FirebaseAuth.instance.signOut(); // Not admin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Access denied. Not an admin account."),
            backgroundColor: Colors.red,
          ),
        );
      }

      //Reset the form fields
      _formKey.currentState!.reset();

    } on FirebaseAuthException catch (e) {
      String msg = "An error occurred.";
      //print("Admin Sign In Error: ${e.code}");
      if (e.code == 'admin-not-found') {
        msg = "No admin found.";
      } else if (e.code == 'wrong-password') {
        msg = "Wrong password.";
      } else if (e.code == 'invalid-email') {
        msg = "Invalid email format.";
      } else if (e.code == 'invalid-credential') {
        msg = "Invalid credentials.";
      } else if (e.code == 'user-disabled') {
        msg = "User account is disabled.";
      } else if (e.code == 'network-request-failed') {
        msg = "Network error. Please check your connection.";
      } else if (e.code == 'too-many-requests') {
        msg = "Too many requests. Please try again later.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30),
              height: MediaQuery.of(context).size.height / 2.5,
              padding: const EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 0, 0, 0),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "images/branch.png",
                    height: 180,
                    fit: BoxFit.fill,
                    width: 240,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height / 3.6,
                left: 20,
                right: 20
              ),
              child: Material(
                elevation: 3.0,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: MediaQuery.of(context).size.height / 1.65,
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              "Admin Log In",
                              style: AppWidget.headlineTextFieldStyle(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Email",
                            style: AppWidget.signUpTextFieldStyle(),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your email",
                                prefixIcon: Icon(Icons.email_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Password",
                            style: AppWidget.signUpTextFieldStyle(),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFececf8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextFormField(
                              obscureText: true,
                              controller: passwordController,
                              validator: _validatePassword,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter your password",
                                prefixIcon: Icon(Icons.password_outlined),
                                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "Forgot Password?",
                                style: AppWidget.simpleTextFieldStyle(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              email = emailController.text.trim();
                              password = passwordController.text.trim();
                              if (email!.isNotEmpty && password!.isNotEmpty) {
                                adminSignIn();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter email and password"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Center(
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    "Log In",
                                    style: AppWidget.boldWhiteTextFieldStyle(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignIn()),
                                );
                              },
                              child: const Text(
                                "Login as Member",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}
