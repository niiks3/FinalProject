import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:project/views/login_signup_view.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Settings Page Content'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Log out and navigate to login screen
                FirebaseAuth.instance.signOut();
                Get.offAll(const LoginSignupView());
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
