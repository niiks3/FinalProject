import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventSpaceDetailsScreen extends StatelessWidget {
  final DocumentSnapshot eventSpace;

  const EventSpaceDetailsScreen({super.key, required this.eventSpace});

  @override
  Widget build(BuildContext context) {
    var eventSpaceData = eventSpace.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(eventSpaceData['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Capacity: ${eventSpaceData['capacity']}'),
            Text('Location: ${eventSpaceData['location']}'),
            // Add more details as needed
            ElevatedButton(
              onPressed: () {
                // Logic to place a bid
              },
              child: Text('Place Bid'),
            ),
          ],
        ),
      ),
    );
  }
}
