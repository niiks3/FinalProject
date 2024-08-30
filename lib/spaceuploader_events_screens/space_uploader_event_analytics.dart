import 'package:flutter/material.dart';

class SpaceUploaderEventAnalyticsScreen extends StatelessWidget {
  const SpaceUploaderEventAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analytics'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Event Analytics for Space Uploader',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),


            Placeholder(
              fallbackHeight: 200,
              fallbackWidth: 200,
            ),
          ],
        ),
      ),
    );
  }
}
