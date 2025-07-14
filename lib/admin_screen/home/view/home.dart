import 'package:branch_comm/screen/sign_in/view/signin.dart';
import 'package:branch_comm/services/admin_shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:branch_comm/admin_screen/admin/view/add_admin.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await AdminSharedPreferenceHelper().clearAllPref();

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignIn()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Panel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Confirm Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            
              if (confirm == true) {
                if (!context.mounted) return;
                _logout(context); // Direct logout with no extra dialog
              }
            }
          ),
        ],
      ),
      body: const Center(child: Text("Welcome to Admin Panel")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAdmin()),
          );
        },
        tooltip: 'Add New Admin',
        child: const Icon(Icons.add),
      ),
    );
  }
}
