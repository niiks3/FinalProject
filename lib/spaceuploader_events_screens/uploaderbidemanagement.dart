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
      // Fetch the bid data to get the bid date
      DocumentSnapshot bidSnapshot = await FirebaseFirestore.instance.collection('bids').doc(bidId).get();
      var bidData = bidSnapshot.data() as Map<String, dynamic>;
      String? intendedDateStr = bidData['intendedDate'];

      if (intendedDateStr == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid date is not available.')));
        return;
      }

      DateTime intendedDate = DateFormat('yyyy-MM-dd').parse(intendedDateStr);

      if (isAccepted) {
        // Fetch all bids on the same intended date for this space
        QuerySnapshot otherBidsSnapshot = await FirebaseFirestore.instance
            .collection('bids')
            .where('spaceId', isEqualTo: spaceId)
            .where('intendedDate', isEqualTo: intendedDateStr)
            .get();

        // Update the status of all bids on the same date to 'declined'
        for (var otherBid in otherBidsSnapshot.docs) {
          await FirebaseFirestore.instance.collection('bids').doc(otherBid.id).update({
            'status': otherBid.id == bidId ? 'accepted' : 'declined',
          });
        }

        // Update the space status to 'booked'
        await FirebaseFirestore.instance.collection('spaces').doc(spaceId).update({
          'status': 'booked',
        });
      } else {
        // If the bid is declined, just update the status of the current bid
        await FirebaseFirestore.instance.collection('bids').doc(bidId).update({
          'status': 'declined',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isAccepted ? 'Bid accepted, all other bids on the same date declined' : 'Bid declined')));
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder<QuerySnapshot>(
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

                      // Group bids by intended date
                      Map<String, List<DocumentSnapshot>> groupedBids = {};
                      for (var bid in bids) {
                        var bidData = bid.data() as Map<String, dynamic>;
                        String? intendedDateStr = bidData['intendedDate'];
                        if (intendedDateStr != null) {
                          if (!groupedBids.containsKey(intendedDateStr)) {
                            groupedBids[intendedDateStr] = [];
                          }
                          groupedBids[intendedDateStr]!.add(bid);
                        }
                      }

                      return Column(
                        children: groupedBids.entries.map((entry) {
                          DateTime intendedDate = DateFormat('yyyy-MM-dd').parse(entry.key);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: const Offset(0, 3), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: ExpansionTile(
                                title: ListTile(
                                  leading: spaceData['imageUrls'] != null && spaceData['imageUrls'].isNotEmpty
                                      ? Image.network(spaceData['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                                      : const Icon(Icons.image, size: 50),
                                  title: Text(spaceData['title']),
                                  subtitle: Text(DateFormat('yyyy-MM-dd').format(intendedDate)),
                                ),
                                children: entry.value.map((bid) {
                                  var bidData = bid.data() as Map<String, dynamic>;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(10.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0, 2), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: Text('Bid Amount: GHC${bidData['amount']}'),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Placed on: ${bidData['timestamp'] != null ? DateFormat('yyyy-MM-dd – kk:mm').format(bidData['timestamp'].toDate()) : 'N/A'}',
                                            ),
                                            Text('Status: ${bidData['status']}'),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                padding: const EdgeInsets.all(10),
                                                backgroundColor: Colors.green, // Background color
                                              ),
                                              onPressed: () => _handleBidAction(context, bid.id, space.id, true),
                                              child: const Icon(Icons.check, color: Colors.white),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: const CircleBorder(),
                                                padding: const EdgeInsets.all(10),
                                                backgroundColor: Colors.red, // Background color
                                              ),
                                              onPressed: () => _handleBidAction(context, bid.id, space.id, false),
                                              child: const Icon(Icons.close, color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
