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
        backgroundColor: Colors.black, // Top bar color
        title: const Text('Settings', style: TextStyle(color: Colors.white)), // Set text color to white
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildSettingsTile(
                    icon: Icons.block,
                    color: Colors.grey[400]!,
                    title: 'My Profile',
                    onTap: () {
                      // Handle blocked accounts tap
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildSettingsTile(
                    icon: Icons.notifications,
                    color: Colors.grey[400]!,
                    title: 'Notifications',
                    onTap: () {
                      // Handle notifications tap
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildSettingsTile(
                    icon: Icons.privacy_tip,
                    color: Colors.grey[400]!,
                    title: 'Privacy Policy',
                    onTap: () {
                      // Handle privacy policy tap
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildSettingsTile(
                    icon: Icons.description,
                    color: Colors.grey[400]!,
                    title: 'Terms of Service',
                    onTap: () {
                      // Handle terms of service tap
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildSettingsTile(
                    icon: Icons.rule,
                    color: Colors.grey[400]!,
                    title: 'Community Guidelines',
                    onTap: () {
                      // Handle community guidelines tap
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildSettingsTile(
                    icon: Icons.support,
                    color: Colors.grey[400]!,
                    title: 'Support',
                    onTap: () {
                      // Handle support tap
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 20, thickness: 1, color: Colors.grey),
            _buildSettingsTile(
              icon: Icons.logout,
              color: Colors.red,
              title: 'Log out',
              onTap: () {
                // Log out and navigate to login screen
                FirebaseAuth.instance.signOut();
                Get.offAll(const LoginSignupView());
              },
            ),
            const SizedBox(height: 16.0), // Add some space at the bottom
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({required IconData icon, required Color color, required String title, required Function() onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: onTap,
      ),
    );
  }
}

