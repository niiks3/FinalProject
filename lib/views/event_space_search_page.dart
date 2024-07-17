import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_space_details_screen.dart';

class EventSpaceSearchScreen extends StatelessWidget {
  const EventSpaceSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Event Spaces'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('event_spaces').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No event spaces available.'));
          }

          var eventSpaces = snapshot.data!.docs;

          return ListView.builder(
            itemCount: eventSpaces.length,
            itemBuilder: (context, index) {
              var eventSpace = eventSpaces[index];
              return ListTile(
                title: Text(eventSpace['name']),
                subtitle: Text('Capacity: ${eventSpace['capacity']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventSpaceDetailsScreen(eventSpace: eventSpace),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
