import 'package:branch_comm/model/admin_model.dart';
import 'package:branch_comm/services/database/admin_service.dart';
import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/utils/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final AdminService _adminService = AdminService();
  String name = '';
  String email = '';
  String password = '';
  String encryptPassword ='';
  bool isLoading = false;

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    try {
      // 🔹 Step 1: Check email existence
      final adminEmailExists = await _adminService.isEmailExists(email);
      final userEmailExists = await _userService.isEmailExists(email);
      final uid = await _userService.getUidFromUserEmail(email);

      // 🔹 Step 2: If email exists in users but not in admins → Promote user to admin
      if (!adminEmailExists && userEmailExists && uid != null) {
        final adminInfo = _buildAdminInfoMap(uid);
        final success = await _adminService.addAdminDetails(adminInfo, uid);

        if (!mounted) return;
        return _showSnackbar(
          success ? "Admin added successfully" : "Error adding admin, please try again",
          success ? Colors.green : Colors.redAccent,
        );
      }

      // 🔹 Step 3: Create a new Firebase Auth user (if not already a user)
      final newAdminCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email.trim(), password: password);

      final newAdmin = newAdminCredential.user;
      if (newAdmin == null) {
        throw FirebaseAuthException(code: 'user-not-created', message: 'Failed to create admin user.');
      }

      // 🔹 Step 4: Save admin info in Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(newAdmin.uid)
          .set(_buildAdminInfoMap(newAdmin.uid));

      if (mounted) {
        _showSnackbar("New admin created successfully", Colors.green);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      await _handleFirebaseAuthError(e);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _buildAdminInfoMap(String uid) {
    return {
      "uid": uid,
      "name": name.trim(),
      "email": email.trim(),
      "password": password,
      "encrypt_password": EncryptionService.hashPassword(encryptPassword),
      "editor_type": 100,
      "role": 'admin',
      "status": Admin.active,
      "created_at": FieldValue.serverTimestamp(),
      "updated_at": FieldValue.serverTimestamp(),
    };
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleFirebaseAuthError(FirebaseAuthException e) async {
    String errorMsg = "Something went wrong.";

    switch (e.code) {
      case 'email-already-in-use':
        errorMsg = 'Email already in use.';
        final query = await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('admins').add({
            'email': email.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
          if (mounted) _showSnackbar("Admin role added to Firestore.", Colors.green);
        }
        break;

      case 'weak-password':
        errorMsg = 'Password too weak.';
        break;

      default:
        errorMsg = e.message ?? "An unknown error occurred.";
    }

    if (mounted) _showSnackbar(errorMsg, Colors.red);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create New Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (val) => val == null || val.isEmpty ? 'Enter a name' : null,
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                      onChanged: (val) => email = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (val) => val == null || val.length < 6 ? 'Min 6 characters' : null,
                      onChanged: (val) => password = val,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createAdmin,
                      child: const Text('Create Admin'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
