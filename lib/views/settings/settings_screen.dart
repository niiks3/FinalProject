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
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette, color: Colors.blue),
            title: const Text('Appearance'),
            subtitle: const Text('Make Ziar\'App yours'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle appearance settings tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.red),
            title: const Text('Privacy'),
            subtitle: const Text('Lock Ziar\'App to improve your privacy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle privacy settings tap
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode, color: Colors.black),
            title: const Text('Dark mode'),
            subtitle: const Text('Automatic'),
            value: true,
            onChanged: (bool value) {
              // Handle dark mode switch
            },
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.purple),
            title: const Text('About'),
            subtitle: const Text('Learn more about Ziar\'App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle about tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback, color: Colors.orange),
            title: const Text('Send Feedback'),
            subtitle: const Text('Let us know how we can make Ziar\'App better'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle send feedback tap
            },
          ),
          const Divider(height: 20, thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Account',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.blue),
            title: const Text('Sign Out'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Log out and navigate to login screen
              FirebaseAuth.instance.signOut();
              Get.offAll(const LoginSignupView());
            },
          ),
          ListTile(
            leading: const Icon(Icons.email, color: Colors.blue),
            title: const Text('Change email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle change email tap
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete account'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Handle delete account tap
            },
          ),
        ],
      ),
    );
  }
}
