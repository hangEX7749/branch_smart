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
  String name = '';
  String email = '';
  String password = '';
  bool isLoading = false;

  Future<void> _createAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      // 1. Create new admin in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final newUser = userCredential.user!;
      // 2. Add user data to Firestore with admin role
      await FirebaseFirestore.instance.collection('admins').doc(newUser.uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'editor_type': 100,
        'status': 10, 
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('New admin created successfully'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = "Something went wrong.";
      if (e.code == 'email-already-in-use') {
        errorMsg = 'Email already in use.';
        
        // Workaround: Search Firestore by email
        final query = await FirebaseFirestore.instance
            .collection('admins')
            .where('email', isEqualTo: email.trim())
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          // 4. Email exists in Auth but not in Firestore — Save as admin
          await FirebaseFirestore.instance.collection('admins').add({
            'email': email.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Admin role added to Firestore.")),
            );
          }

        }
      } else if (e.code == 'weak-password') {
        errorMsg = 'Password too weak.';
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ));

    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
