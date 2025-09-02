import 'package:branch_comm/model/member_model.dart';
import 'package:branch_comm/screen/account_page/utils/index.dart';
import 'package:branch_comm/services/database.dart';
import 'package:branch_comm/services/database/admin_service.dart';
import 'package:branch_comm/services/widget_support.dart';
import 'package:branch_comm/utils/bcrypt.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {  

  final UserService _userService = UserService();
  final AdminService _adminService = AdminService();

  String? name, email, password, encryptPassword, phone;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController(); 
  TextEditingController passwordController = TextEditingController();
  TextEditingController encryptPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  // Enhanced password validator
  // String? _validatePassword(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Please enter your password';
  //   }
    
  //   if (value.length < 8) {
  //     return 'Password must be at least 8 characters long';
  //   }
    
  //   if (!value.contains(RegExp(r'[A-Z]'))) {
  //     return 'Password must contain at least one uppercase letter';
  //   }
    
  //   if (!value.contains(RegExp(r'[a-z]'))) {
  //     return 'Password must contain at least one lowercase letter';
  //   }
    
  //   if (!value.contains(RegExp(r'[0-9]'))) {
  //     return 'Password must contain at least one number';
  //   }
    
  //   if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
  //     return 'Password must contain at least one special character';
  //   }
    
  //   return null;
  // }

  // Check if passwords match
  String? _validatePasswordMatch(String? value) {
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> registration() async {
    if (name == null || email == null || password == null || encryptPassword == null || phone == null) {
      _showSnackbar("Missing required fields.", Colors.redAccent);
      return;
    }

    try {
      // 🔹 Step 1: Check if email exists
      final adminEmailExists = await _adminService.isEmailExists(email!);
      final userEmailExists = await _userService.isEmailExists(email!);
      final uid = await _adminService.getUidFromAdminEmail(email!);

      // 🔹 Step 2: If already in admin but not in users → Promote to user
      if (adminEmailExists && !userEmailExists && uid != null) {
        final userId = await _userService.getNewId();
        final userInfo = _buildUserInfoMap(userId, uid);

        final success = await DatabaseMethods().addUserDetails(userInfo, userId);
        if (!mounted) return;

        return success
            ? _showSnackbar("User registered successfully", Colors.green)
            : _showSnackbar("Error in registration, please try again.", Colors.redAccent);
      }

      // 🔹 Step 3: Otherwise, create new Firebase Auth user
      final newUserCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email!.trim(), password: password!);

      final newUser = newUserCredential.user;
      if (newUser == null) {
        throw FirebaseAuthException(code: 'user-not-created', message: 'Failed to create user.');
      }

      final userId = await _userService.getNewId();
      final userInfo = _buildUserInfoMap(userId, newUser.uid);

      final success = await DatabaseMethods().addUserDetails(userInfo, userId);
      if (!mounted) return;

      //if success show success message and return to previous screen
      if (success) {
        _showSnackbar("User registered successfully", Colors.green);
        
        //return to sign in screen
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => SignIn(),
          ),
        );

      } else {
        _showSnackbar("Error in registration, please try again.", Colors.redAccent);
      }

    } on FirebaseAuthException catch (e) {
      _handleRegistrationError(e);
    }
  }

  Map<String, dynamic> _buildUserInfoMap(String userId, String uid) {
    return {
      "id": userId,
      "uid": uid,
      "name": name,
      "email": email,
      "phone": phone,
      "password": password,
      "encrypt_password": EncryptionService.hashPassword(encryptPassword!),
      "role": "user",
      "status": Member.active,
      "created_at": DateTime.now().toIso8601String(),
      "updated_at": DateTime.now().toIso8601String(),
    };
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: Text(
          message,
          style: AppWidget.simpleTextFieldStyle(),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleRegistrationError(FirebaseAuthException e) {
    String errorMsg;
    switch (e.code) {
      case 'weak-password':
        errorMsg = "The password provided is too weak.";
        break;
      case 'email-already-in-use':
        errorMsg = "The account already exists for that email.";
        break;
      default:
        errorMsg = e.message ?? "Something went wrong.";
    }
    if (mounted) _showSnackbar(errorMsg, Colors.redAccent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        color: Colors.black,
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(top: 30),
                height: MediaQuery.of(context).size.height / 2.5,
                padding: const EdgeInsets.only(top: 10),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 0, 0, 0),
                  borderRadius: const BorderRadius.only(
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
              // Single scrollable container
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
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        // Main scrollable content
                        Scrollbar(
                          thumbVisibility: true,
                          thickness: 6,
                          radius: Radius.circular(10),
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    "Sign Up",
                                    style: AppWidget.headlineTextFieldStyle(),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Name",
                                  style: AppWidget.signUpTextFieldStyle(),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your name';
                                      }
                                      return null;
                                    },
                                    controller: nameController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your name",
                                      prefixIcon: Icon(
                                        Icons.person_outline,
                                      ),
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
                                  "Email",
                                  style: AppWidget.signUpTextFieldStyle(),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your email';
                                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your email",
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                      ),
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
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your password';
                                      } else if (value.length < 6) {
                                        return 'Password must be at least 6 characters long';
                                      }
                                      return null;
                                    },
                                    //validator: _validatePassword,
                                    obscureText: true,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your password",
                                      prefixIcon: Icon(
                                        Icons.password_outlined,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Confirm Password",
                                  style: AppWidget.signUpTextFieldStyle(),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    validator: _validatePasswordMatch,
                                    obscureText: true,
                                    controller: encryptPasswordController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Confirm your password",
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                      ),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  "Phone",
                                  style: AppWidget.signUpTextFieldStyle(),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFececf8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your phone number';
                                      } else if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
                                        return 'Please enter a valid phone number';
                                      }
                                      return null;
                                    },
                                    controller: phoneController,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter your phone number",
                                      prefixIcon: Icon(
                                        Icons.phone_outlined,
                                      ),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                                      errorStyle: TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      setState(() {
                                        name = nameController.text;
                                        email = emailController.text;
                                        password = passwordController.text;
                                        encryptPassword = passwordController.text;
                                        phone = phoneController.text;
                                      });
                                      registration();
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
                                          "Sign Up",
                                          style: AppWidget.boldWhiteTextFieldStyle(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account?",
                                      style: AppWidget.simpleTextFieldStyle(),
                                    ),
                                    const SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignIn(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "SignIn",
                                        style: AppWidget.boldTextFieldStyle().copyWith(
                                          color: Colors.deepOrange,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 40), // Extra padding at bottom
                              ],
                            ),
                          ),
                        ),
                        // Bottom fade indicator
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.white,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}