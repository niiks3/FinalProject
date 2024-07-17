import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventSpaceBidManagementScreen extends StatelessWidget {
  const EventSpaceBidManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bids'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bids').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No bids available.'));
          }

          var bids = snapshot.data!.docs;

          return ListView.builder(
            itemCount: bids.length,
            itemBuilder: (context, index) {
              var bid = bids[index];
              return ListTile(
                title: Text(bid['eventSpaceName']),
                subtitle: Text('Bid Amount: \$${bid['amount']}'),
                onTap: () {
                  // Logic to manage bid
                },
              );
            },
          );
        },
      ),
    );
  }
}
