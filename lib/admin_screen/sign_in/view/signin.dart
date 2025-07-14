import 'package:branch_comm/services/admin_shared_pref.dart';
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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? email, password;

  Future<void> adminSignIn() async {

    try { 
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
      
      print(saved);
      
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to save admin data.")),
        );
        return;
      }

      if (data != null) {
        // Admin found, navigate to admin home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Admin login successful.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
          (route) => false,
        );
      } else {
        FirebaseAuth.instance.signOut(); // Not admin
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Access denied. Not an admin account.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String msg = "An error occurred.";
      if (e.code == 'admin-not-found') {
        msg = "No admin found.";
      } else if (e.code == 'wrong-password') {
        msg = "Wrong password.";
      }
      else if (e.code == 'invalid-email') {
        msg = "Invalid email format.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Admin Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                email = emailController.text.trim();
                password = passwordController.text.trim();
                if (email!.isNotEmpty && password!.isNotEmpty) {
                  adminSignIn();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter email and password")),
                  );
                }
              },
              child: const Text("Login as Admin"),
            ),
          ],
        ),
      ),
    );
  }
}
