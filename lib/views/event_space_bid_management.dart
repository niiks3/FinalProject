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
        appBar: AppBar(
          title: const Text('Manage Bids'),
          backgroundColor: Colors.transparent, // Transparent background for AppBar
          elevation: 0, // No shadow
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
              stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(child: Text('Please sign in to view your bids', style: TextStyle(color: Colors.white))),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Bids'),
        backgroundColor: Colors.transparent, // Transparent background for AppBar
        elevation: 0, // No shadow
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff283048), Color(0xff859398)],
            stops: [0, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('bids')
              .where('bidderId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No bids available.', style: TextStyle(color: Colors.white)));
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

                    if (spaceSnapshot.hasError) {
                      return ListTile(
                        title: Text('Error: ${spaceSnapshot.error}'),
                      );
                    }

                    if (!spaceSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Space not found'),
                      );
                    }

                    var spaceData = spaceSnapshot.data!.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                spaceData['imageUrls'] != null && spaceData['imageUrls'].isNotEmpty
                                    ? Image.network(spaceData['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 50),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    spaceData['title'],
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Bid Amount: GH₵${bidData['amount']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Placed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(bidData['timestamp'].toDate())}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${bidData['status'] ?? 'Pending'}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventSpaceDetailsScreen(
                                      eventSpace: spaceSnapshot.data!,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View Details'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
