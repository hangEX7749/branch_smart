import 'package:branch_comm/admin_screen/sign_in/view/signin.dart';
import 'package:branch_comm/screen/forgot_password/view/forgot_password_front.dart';
import 'package:branch_comm/services/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:branch_comm/screen/home_page/view/home.dart';
import 'package:branch_comm/screen/sign_up/view/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:branch_comm/services/widget_support.dart';
import 'package:branch_comm/services/user_auth_data.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  String? email, password;
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController(); 
  TextEditingController passwordController = TextEditingController();

  // Email validator function
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    
    // Basic email format validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Password validator function
  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  userSignIn() async {
    try {
      if (!_formKey.currentState!.validate()) {
        // Form validation will show individual field errors
        return;
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email!, password: password!);
      var userData = await UserAuthData().getUserData(email!);

      if (userData.docs.isNotEmpty) {
        var userDoc = userData.docs.first;
        var data = userDoc.data() as Map<String, dynamic>;

        // Save user data to shared preferences
        bool saved = await SharedpreferenceHelper().saveUserData(
          userId: userDoc.id,
          userName: data["name"] ?? 'unknown',
          userEmail: email!,
          //userImage: 'path/to/image.jpg', // Optional
        );
        
        if (!mounted) return;
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar( 
              content: Text("Failed to save user data"),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        if (!mounted) return;
        
        if (saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "Signed in successfully!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
              ),
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(const Duration(milliseconds: 100));
          
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Home()),
            (route) => false,
          );
        }

        //Reset form
        _formKey.currentState!.reset();

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No account found with email: $email"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMsg = "An unexpected error occurred";
      switch (e.code) {
        case 'user-not-found':
          errorMsg = "No account found with this email";
          break;
        case 'wrong-password':
          errorMsg = "Incorrect password";
          break;
        case 'invalid-email':
          errorMsg = "Invalid email format";
          break;
        case 'user-disabled':
          errorMsg = "This account has been disabled";
          break;
        case 'too-many-requests':
          errorMsg = "Too many failed attempts. Please try again later";
          break;
        case 'network-request-failed':
          errorMsg = "Network error. Please check your connection";
          break;
        case 'invalid-credential':
          errorMsg = "Invalid email or password";
          break;
        default:
          errorMsg = "Sign in failed. Please try again";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
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
                              "Log In",
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
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordFront(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "Forgot Password?",
                                  style: AppWidget.simpleTextFieldStyle().copyWith(
                                    color: Colors.blue, fontSize: 16,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              email = emailController.text.trim();
                              password = passwordController.text.trim();
                              userSignIn();
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
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: AppWidget.simpleTextFieldStyle(),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignUp(),
                                    ),
                                  );
                                },
                                child: Text(
                                  "SignUp",
                                  style: AppWidget.boldTextFieldStyle().copyWith(color: Colors.deepOrange),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AdminSignIn()),
                                );
                              },
                              child: const Text(
                                "Login as Admin",
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
            )
          ],
        ),
      ),
    );
  }
}