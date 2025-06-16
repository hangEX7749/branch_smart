import 'package:branch_comm/screen/account_page/utils/index.dart';

class Account extends StatefulWidget {
  const Account({super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? name, email, userId, password;
  bool isEditingInfo = false;
  bool isChangingPassword = false;

  // Password visibility flags
  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //User info controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Password change controllers
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Function to get shared preferences
  getTheSharedPref() async {
    name = await SharedpreferenceHelper().getUserName();
    userId = await SharedpreferenceHelper().getUserId();
    email = await SharedpreferenceHelper().getUserEmail();

    if (userId == null || name == null) {
      // User not logged in or prefs not set
      //Navigator.pushReplacementNamed(context, '/sigin');
      //print("name: $name, userId: $userId, email: $email");
    } else {
      setState(() {});
    }
    setState(() {
      nameController.text = name ?? '';
      emailController.text = email ?? '';      
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog first

              // Step 1: Sign out from Firebase
              await FirebaseAuth.instance.signOut();

              // Step 2: Navigate to sign-in and clear back stack
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => SignIn()), // Replace with your sign-in widget
                (route) => false, // Remove all previous routes
              );

              // Optional: show confirmation if needed
              // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged out")));
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }

  void _saveUserInfo() async {
    final userInfoMap = {
      'name': nameController.text,
      'email': emailController.text,
      // Add other fields as needed
    };

    final dbMethods = DatabaseMethods();
    final success = await dbMethods.editUserDetails(userInfoMap, userId!);

    if (success) {
      setState(() {
        isEditingInfo = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("User info updated")));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Failed to update user info")));
    }
  }

  Future<void> changePasswordWithReauth({
    required BuildContext context,
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user == null || user.email == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      // Reauthenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword, // user input for current password
      );

      await user.reauthenticateWithCredential(credential);
      // Now update password
      await user.updatePassword(newPassword);

      // Update user details in Firestore
      final dbMethods = DatabaseMethods();
      final success = await dbMethods.updateUserPassword(newPassword, userId!);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update password in database")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password changed successfully")),
      );


    } on FirebaseAuthException catch (e) {
      String message;
      print(e.code);
      switch (e.code) {
        case 'wrong-password':
          message = "Current password is incorrect";
          break;
        case 'weak-password':
          message = "The new password is too weak";
          break;
        case 'requires-recent-login':
          message = "Please log in again and try";
          break;
        default:
          message = e.message ?? "An error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $message")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unexpected error: $context")),
      );
    }
  }
  
  Widget _buildUserInfoSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              enabled: isEditingInfo,
              decoration: InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: emailController,
              enabled: isEditingInfo,
              decoration: InputDecoration(labelText: "Email"),
            ),
            SizedBox(height: 10),
            isEditingInfo
                ? Row(
                    children: [
                      ElevatedButton(onPressed: _saveUserInfo, child: Text("Save")),
                      SizedBox(width: 10),
                      TextButton(
                          onPressed: () => setState(() => isEditingInfo = false),
                          child: Text("Cancel")),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () => setState(() => isEditingInfo = true),
                    child: Text("Edit Info")),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordSection() {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Change Password", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            if (isChangingPassword) ...[
              TextField(
                controller: currentPasswordController,
                obscureText: obscureCurrent,
                decoration: InputDecoration(
                  labelText: "Current Password",
                  suffixIcon: IconButton(
                    icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() => obscureCurrent = !obscureCurrent);
                    },
                  ),
                ),
              ),
              TextField(
                controller: newPasswordController,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: "New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureNew ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureNew = !obscureNew;
                      });
                    },
                  ),
                ),
              ),

              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm New Password",
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscureConfirm ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        obscureConfirm = !obscureConfirm;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      changePasswordWithReauth(
                        context: context,
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        confirmPassword: confirmPasswordController.text,
                      );
                    },
                    child: Text("Change Password"),
                  ),
                  SizedBox(width: 10),
                  TextButton(
                      onPressed: () => setState(() => isChangingPassword = false),
                      child: Text("Cancel")),
                ],
              ),
            ] else
              ElevatedButton(
                  onPressed: () => setState(() => isChangingPassword = true),
                  child: Text("Change Password")),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: _logout,
        child: Text("Logout"),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getTheSharedPref();
    nameController.text = name ?? '';
    emailController.text = email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildUserInfoSection(),
            _buildChangePasswordSection(),
            SizedBox(height: 20),
            _buildLogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        context: context, // pass context into the widget
      ),
    );
  }
}
