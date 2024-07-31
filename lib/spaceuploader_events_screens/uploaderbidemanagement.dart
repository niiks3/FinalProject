import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UploaderBidManagementScreen extends StatelessWidget {
  const UploaderBidManagementScreen({super.key});

  Future<void> _markAsUnavailable(BuildContext context, String spaceId) async {
    final TextEditingController _dateController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mark as Unavailable'),
          content: TextField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Enter date (YYYY-MM-DD)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  DateTime unavailableDate = DateFormat('yyyy-MM-dd').parse(_dateController.text);
                  await FirebaseFirestore.instance.collection('spaces').doc(spaceId).update({
                    'unavailableDates': FieldValue.arrayUnion([unavailableDate]),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as unavailable')));
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleBidAction(BuildContext context, String bidId, String spaceId, bool isAccepted) async {
    try {
      await FirebaseFirestore.instance.collection('bids').doc(bidId).update({
        'status': isAccepted ? 'accepted' : 'declined',
      });

      if (isAccepted) {
        await FirebaseFirestore.instance.collection('spaces').doc(spaceId).update({
          'status': 'booked',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAccepted ? 'Bid accepted' : 'Bid declined')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

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
                    children: [
                      ...bids.map((bid) {
                        var bidData = bid.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text('Bid Amount: \$${bidData['amount']}'),
                          subtitle: Text(
                            'Placed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(bidData['timestamp'].toDate())}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.green),
                                onPressed: () => _handleBidAction(context, bid.id, space.id, true),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _handleBidAction(context, bid.id, space.id, false),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      ListTile(
                        title: const Text('Mark as Unavailable'),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _markAsUnavailable(context, space.id),
                        ),
                      ),
                    ],
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
