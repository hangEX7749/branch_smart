import 'package:branch_comm/services/database/user_service.dart';
import 'package:branch_comm/widgets/custom_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChangePassword extends StatefulWidget {
  final String userId;

  const ChangePassword({
    super.key,
    required this.userId,
  });

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Password strength indicators
  bool hasMinLength = false;
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumbers = false;
  bool hasSpecialChars = false;

  @override
  void initState() {
    super.initState();
    newPasswordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    final password = newPasswordController.text;
    setState(() {
      hasMinLength = password.length >= 8;
      hasUppercase = password.contains(RegExp(r'[A-Z]'));
      hasLowercase = password.contains(RegExp(r'[a-z]'));
      hasNumbers = password.contains(RegExp(r'[0-9]'));
      hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool get isPasswordStrong => hasMinLength && hasUppercase && hasLowercase && hasNumbers;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;

      if (user == null || user.email == null) {
        throw Exception("User not found");
      }

      // Method 1: Try the current standard approach
      AuthCredential credential;
      
      try {
        // This should work in most current versions
        credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPasswordController.text,
        );
      } catch (e) {
        // If credential() is not available, use alternative approach
        // Sign out and sign back in (alternative to reauthentication)
        await _auth.signOut();
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: user.email!,
          password: currentPasswordController.text,
        );
        
        if (userCredential.user == null) {
          throw FirebaseAuthException(
            code: 'user-not-found',
            message: 'Failed to reauthenticate user',
          );
        }
        
        user = userCredential.user!;
        
        // Skip the reauthentication step and go directly to password update
        await user.updatePassword(newPasswordController.text);
        
        // Update user details in Firestore
        final dbMethods = UserService();
        final success = await dbMethods.updateUserPassword(newPasswordController.text, widget.userId);

        if (!success) {
          throw Exception("Failed to update password in database");
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Password changed successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
        return; // Exit early since we've completed the process
      }

      await user.reauthenticateWithCredential(credential);
      
      // Update password in Firebase Auth
      await user.updatePassword(newPasswordController.text);

      // Update password in Firestore
      final dbMethods = UserService();
      final success = await dbMethods.updateUserPassword(newPasswordController.text, widget.userId);

      if (!success) {
        throw Exception("Failed to update password in database");
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password changed successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      String message;
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
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Password Requirements:",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        _buildRequirementItem("At least 8 characters", hasMinLength),
        _buildRequirementItem("Uppercase letter (A-Z)", hasUppercase),
        _buildRequirementItem("Lowercase letter (a-z)", hasLowercase),
        _buildRequirementItem("Number (0-9)", hasNumbers),
        _buildRequirementItem("Special character (!@#\$%^&*)", hasSpecialChars),
      ],
    );
  }

  Widget _buildRequirementItem(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isValid ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isValid ? Colors.green : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Change Password'),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Security Settings",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Current Password
                      _buildPasswordField(
                        controller: currentPasswordController,
                        label: "Current Password",
                        obscureText: obscureCurrent,
                        toggleVisibility: () => setState(() => obscureCurrent = !obscureCurrent),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Current password is required';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // New Password
                      _buildPasswordField(
                        controller: newPasswordController,
                        label: "New Password",
                        obscureText: obscureNew,
                        toggleVisibility: () => setState(() => obscureNew = !obscureNew),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'New password is required';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          if (value == currentPasswordController.text) {
                            return 'New password must be different from current password';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Confirm Password
                      _buildPasswordField(
                        controller: confirmPasswordController,
                        label: "Confirm New Password",
                        obscureText: obscureConfirm,
                        toggleVisibility: () => setState(() => obscureConfirm = !obscureConfirm),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value != newPasswordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Password Strength Indicator
                      if (newPasswordController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: _buildPasswordStrengthIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Security Tips
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Security Tips",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "• Use a unique password you don't use elsewhere\n"
                        "• Mix uppercase, lowercase, numbers, and symbols\n"
                        "• Avoid personal information like names or birthdays\n"
                        "• Consider using a password manager",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Change Password Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _changePassword,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    backgroundColor: isPasswordStrong 
                        ? Theme.of(context).primaryColor 
                        : Colors.grey[400],
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}