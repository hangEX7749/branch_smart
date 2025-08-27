import 'package:branch_comm/model/member_model.dart';
import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/screen/account_page/view/edit_user_info.dart';
import 'package:path_provider/path_provider.dart';

class Account extends StatefulWidget {
  const Account({super.key});
  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String? name, email, userId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {      
      final startTime = DateTime.now();
      Member user = Member(id: '', name: '', email: '');
      user = await SharedpreferenceHelper().getUser();

      while (user.name.isEmpty && user.email.isEmpty &&
          DateTime.now().difference(startTime).inSeconds < 5) {
        await Future.delayed(const Duration(milliseconds: 100));
        user = await SharedpreferenceHelper().getUser();
      }

      if (!mounted) return;
      if (user.id.isEmpty || user.name.isEmpty) {
        Navigator.pushReplacementNamed(context, '/signin');
      } 
      
      setState(() {
        userId = user.id;
        name = user.name;
        email = user.email;
      });

      print('Loaded user data: id=$userId, name=$name, email=$email');
      

    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Logout",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      await SharedpreferenceHelper().clearAllPref();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SignIn()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  Future<Widget> _buildProfileSection() async {
    final localPath = '${(await getApplicationDocumentsDirectory()).path}/profile_$userId.jpg';
    final localFile = File(localPath);
    final fileExists = localFile.existsSync();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ProfilePicturePage(userId: userId!),
                //   ),
                // );
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: fileExists
                        ? FileImage(localFile)
                        : const AssetImage('images/boy.jpg') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name ?? 'User Name',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email ?? 'user@example.com',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (iconColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: Text('Account', style: const TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 1,
        title: Text('Account', style: const TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Section
            FutureBuilder<Widget>(
              future: _buildProfileSection(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }
                return snapshot.data ?? const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 24),

            // Menu Options
            _buildMenuOption(
              icon: Icons.person_outline,
              title: "User Information",
              subtitle: "Edit your personal details",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserInfo(
                      userId: userId!,
                      initialName: name ?? '',
                      initialEmail: email ?? '',
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuOption(
              icon: Icons.lock_outline,
              title: "Change Password",
              subtitle: "Update your account password",
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => ChangePasswordPage(userId: userId!),
                //   ),
                // );
              },
            ),

            const SizedBox(height: 12),

            _buildMenuOption(
              icon: Icons.help_outline,
              title: "Forgot Password",
              subtitle: "Reset your password via email",
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => const ForgotPasswordPage(),
                //   ),
                // );
              },
            ),

            const SizedBox(height: 32),

            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.red[200]!),
                  ),
                  elevation: 0,
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: 2,
        context: context,
      ),
    );
  }
}