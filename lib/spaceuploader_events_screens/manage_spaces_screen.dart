import 'package:flutter/material.dart';

class ManageSpacesScreen extends StatelessWidget {
  const ManageSpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Spaces'),
      ),
      body: Center(
        child: const Text('Manage Spaces Screen'),
      ),
    );
  }
}
