import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
//import 'event_space_details_screen.dart';
import '';
class UploaderbidemanagementScreen extends StatelessWidget {
  const UploaderbidemanagementScreen({super.key});

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
            .collection('spaces')
            .where('createdBy', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No spaces available.'));
          }

          var spaces = snapshot.data!.docs;

          return ListView.builder(
            itemCount: spaces.length,
            itemBuilder: (context, index) {
              var space = spaces[index];
              var spaceData = space.data() as Map<String, dynamic>;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('bids')
                    .where('spaceId', isEqualTo: space.id)
                    .snapshots(),
                builder: (context, bidSnapshot) {
                  if (bidSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  if (!bidSnapshot.hasData || bidSnapshot.data!.docs.isEmpty) {
                    return const ListTile(
                      title: Text('No bids available for this space.'),
                    );
                  }

                  var bids = bidSnapshot.data!.docs;

                  return ExpansionTile(
                    title: Text(spaceData['title']),
                    leading: spaceData['imageUrls'] != null && spaceData['imageUrls'].isNotEmpty
                        ? Image.network(spaceData['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.image, size: 50),
                    children: bids.map((bid) {
                      var bidData = bid.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text('Bid Amount: \$${bidData['amount']}'),
                        subtitle: Text(
                          'Placed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(bidData['timestamp'].toDate())}',
                        ),
                        isThreeLine: true,
                        trailing: Text(bidData['amount'].toStringAsFixed(2)),
                      );
                    }).toList(),
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
