import 'package:flutter/material.dart';

class PayoutsScreen extends StatelessWidget {
  const PayoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts'),
      ),
      body: const Center(
        child: Text('Payouts Page Content'),
      ),
    );
  }
}
