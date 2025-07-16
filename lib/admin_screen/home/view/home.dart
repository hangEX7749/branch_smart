import 'package:branch_comm/admin_screen/admin/view/add_admin.dart';
import 'package:branch_comm/admin_screen/appointment/view/appointment_list.dart';
import 'package:branch_comm/screen/sign_in/view/signin.dart';
import 'package:branch_comm/services/admin_shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TODO: Import your Booking and Member Management pages here
// import 'package:branch_comm/admin_screen/booking/view/manage_bookings.dart';
// import 'package:branch_comm/admin_screen/member/view/manage_members.dart';

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
    final List<_AdminMenuItem> adminItems = [
      _AdminMenuItem(
        title: "Manage Appointments",
        icon: Icons.calendar_today,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AppointmentList()));
        },
      ),
      _AdminMenuItem(
        title: "Manage Bookings",
        icon: Icons.event_available,
        onTap: () {
          // Replace with your booking page
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ManageBookings()));
        },
      ),
      _AdminMenuItem(
        title: "Manage Members",
        icon: Icons.people,
        onTap: () {
          // Replace with your member management page
          // Navigator.push(context, MaterialPageRoute(builder: (_) => ManageMembers()));
        },
      ),
      _AdminMenuItem(
        title: "Add New Admin",
        icon: Icons.admin_panel_settings,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAdmin()));
        },
      ),
    ];

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

              if (confirm == true && context.mounted) {
                _logout(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: adminItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final item = adminItems[index];
            return GestureDetector(
              onTap: item.onTap,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 10),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AdminMenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _AdminMenuItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
