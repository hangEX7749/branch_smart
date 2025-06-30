import 'package:branch_comm/services/shared_pref.dart';
import 'package:flutter/material.dart';
// import 'package:food_delivery_app/pages/bottom_nav.dart';
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
  TextEditingController emailController = TextEditingController(); 
  TextEditingController passwordController = TextEditingController();

  userSignIn() async {
    try {
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
            SnackBar(
              content: Text("Failed to save pref user data."),
            ),
          );
          return;
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "User SignIn Successfully",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home()),
          (route) => false, // Remove all previous routes
        );

      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No user data found for the email: $email"),
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      String errorMsg = "An unexpected error occurred.";
      if (e.code == 'user-not-found') {
        errorMsg = "No user found for that email.";
      } else if (e.code == 'wrong-password') {
        errorMsg = "Wrong password provided.";
      } else if (e.code == 'invalid-email') {
        errorMsg = "The email address is badly formatted.";
      } else if (e.code == 'network-request-failed') {
        errorMsg = "Network error, please check your connection.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.only(
                top: 30,
              ),
              height: MediaQuery.of(context).size.height / 2.5,
              padding: const EdgeInsets.only(top: 10),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xffffefbf),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "images/pan.png",
                    height: 180,
                    fit: BoxFit.fill,
                    width: 240,
                  ),
                  Image.asset(
                    "images/logo.png",
                    width: 150,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.75,
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
                            color: Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter your email",
                              prefixIcon: Icon(
                                Icons.email_outlined,
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
                          child: TextField(
                            obscureText: true,
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter your password",
                              prefixIcon: Icon(
                                Icons.password_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "Forgot Password?",
                              style: AppWidget.simpleTextFieldStyle(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            email = emailController.text.trim();
                            password = passwordController.text.trim();
                            if (email != null && password != null) {
                              userSignIn();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Please fill in all fields.",
                                    style: TextStyle(
                                      fontSize: 18,
                                      backgroundColor: Colors.red,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Center(
                            child: Container(
                              width: 200,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.deepOrange,
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

                                setState(() {
                                  email = emailController.text;
                                  password = passwordController.text;
                                });

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUp(),
                                  ),
                                );
                              },
                              child: Text(
                                "SignUp",
                                style: AppWidget.boldTextFieldStyle(),
                              ),
                            )
                          ],
                        )
                      ],
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