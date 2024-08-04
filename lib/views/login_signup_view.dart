import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project/views/space_uploader_login_signup_view.dart';
import 'profile_screen.dart';

class LoginSignupView extends StatefulWidget {
  const LoginSignupView({super.key});

  @override
  _LoginSignupViewState createState() => _LoginSignupViewState();
}

class _LoginSignupViewState extends State<LoginSignupView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController forgetEmailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isSignUp = false; // Flag to toggle between login and sign-up

  Future<void> _login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Get.snackbar('Success', 'Logged in successfully!',
          colorText: Colors.white, backgroundColor: Colors.green);
      // Navigate to ProfileScreen or any other screen on success
      _navigateToProfileScreen();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  Future<void> _signup() async {
    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match!',
          colorText: Colors.white, backgroundColor: Colors.red);
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // Additional data saving logic if needed
      Get.snackbar('Success', 'Signed up successfully!',
          colorText: Colors.white, backgroundColor: Colors.green);
      // Navigate to ProfileScreen or any other screen on success
      _navigateToProfileScreen();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  Future<void> _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: forgetEmailController.text);
      Get.snackbar('Success', 'Password reset email sent!',
          colorText: Colors.white, backgroundColor: Colors.green);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  Future<void> _googleSignInMethod() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      Get.snackbar('Success', 'Signed in with Google successfully!',
          colorText: Colors.white, backgroundColor: Colors.green);
      // Navigate to ProfileScreen or any other screen on success
      _navigateToProfileScreen();
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          colorText: Colors.white, backgroundColor: Colors.red);
    }
  }

  void _navigateToProfileScreen() {
    Get.off(const ProfileScreen(email: '',));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffa5bbef),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 170.0, horizontal: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60), // Add more space above the image
              Image.asset(
                'assets/images/onboardicon.png',
                height: 200,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20), // Space for an image (if needed)

                        // First Name and Last Name text fields (only in Sign Up)
                        if (isSignUp) ...[
                          Row(
                            children: [
                              Expanded(
                                child: myRoundedTextField(
                                  hintText: 'First Name',
                                  controller: firstNameController,
                                  validator: (input) {
                                    if (input!.isEmpty) {
                                      return 'First Name is required.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: myRoundedTextField(
                                  hintText: 'Last Name',
                                  controller: lastNameController,
                                  validator: (input) {
                                    if (input!.isEmpty) {
                                      return 'Last Name is required.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Email text field
                        myRoundedTextField(
                          hintText: 'Email',
                          controller: emailController,
                          validator: (input) {
                            if (input!.isEmpty) {
                              return 'Email is required.';
                            }
                            if (!input.contains('@')) {
                              return 'Email is invalid.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Username text field
                        if (isSignUp)
                          myRoundedTextField(
                            hintText: 'Username',
                            controller: usernameController,
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Username is required.';
                              }
                              return null;
                            },
                          ),

                        const SizedBox(height: 16),

                        // Password text field
                        myRoundedTextField(
                          hintText: 'Password',
                          obscureText: true,
                          controller: passwordController,
                          validator: (input) {
                            if (input!.isEmpty) {
                              return 'Password is required.';
                            }
                            if (input.length < 6) {
                              return 'Password should be 6+ characters.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password text field (only shown during sign up)
                        if (isSignUp)
                          myRoundedTextField(
                            hintText: 'Confirm Password',
                            obscureText: true,
                            controller: confirmPasswordController,
                            validator: (input) {
                              if (input!.isEmpty) {
                                return 'Confirm password is required.';
                              }
                              if (input != passwordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),

                        const SizedBox(height: 16),

                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (isSignUp) {
                                _signup();
                              } else {
                                _login();
                              }
                            }
                          },
                          color: Colors.blue,
                          minWidth: double.infinity,
                          height: 50,
                          child: Text(
                            isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        InkWell(
                          onTap: () {
                            setState(() {
                              isSignUp = !isSignUp;
                            });

                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(25.0),
                                ),
                              ),
                              builder: (BuildContext context) {
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginSignupView()));
                                        },
                                        child: const Text('Register as Normal User'),
                                      ),
                                      const SizedBox(height: 25),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const SpaceUploaderLoginSignupView()));
                                        },
                                        child: const Text('Register as Space Uploader'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            isSignUp ? 'Already have an account? Login' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 16),

                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          onPressed: _googleSignInMethod,
                          color: Colors.white,
                          elevation: 2,
                          minWidth: double.infinity,
                          height: 50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/google.png', height: 24),
                              const SizedBox(width: 12),
                              const Text(
                                'Sign In with Google',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget myRoundedTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    );
  }
}
