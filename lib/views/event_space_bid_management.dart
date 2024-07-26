import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'event_space_details_screen.dart';

class EventSpaceBidManagementScreen extends StatelessWidget {
  const EventSpaceBidManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manage Bids')),
        body: const Center(child: Text('Please sign in to view your bids')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .where('bidderId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No bids available.'));
          }

          var bids = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              var bid = bids[index];
              var bidData = bid.data() as Map<String, dynamic>;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('spaces')
                    .doc(bidData['spaceId'])
                    .get(),
                builder: (context, spaceSnapshot) {
                  if (spaceSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  if (!spaceSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Space not found'),
                    );
                  }

                  var spaceData = spaceSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: spaceData['imageUrls'] != null && spaceData['imageUrls'].isNotEmpty
                        ? Image.network(spaceData['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    title: Text(spaceData['title']),
                    subtitle: Text(
                      'Bid Amount: \$${bidData['amount']}\nPlaced on: ${DateFormat('yyyy-MM-dd – kk:mm').format(bidData['timestamp'].toDate())}',
                    ),
                    isThreeLine: true,
                    trailing: Text(bidData['amount'].toStringAsFixed(2)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EventSpaceDetailsScreen(eventSpace: spaceSnapshot.data!),
                        ),
                      );
                    },
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
