import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pay_with_paystack/pay_with_paystack.dart';
import 'event_space_details_screen.dart';

class EventSpaceBidManagementScreen extends StatelessWidget {
  const EventSpaceBidManagementScreen({super.key});

  Future<void> _placeHigherBid(BuildContext context, String bidId, String spaceId, double currentBidAmount) async {
    final TextEditingController _bidAmountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Place a Higher Bid'),
          content: TextField(
            controller: _bidAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Enter a bid higher than GHC${currentBidAmount.toStringAsFixed(2)}',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                double newBidAmount = double.parse(_bidAmountController.text);
                if (newBidAmount > currentBidAmount) {
                  try {
                    await FirebaseFirestore.instance.collection('bids').doc(bidId).update({
                      'amount': newBidAmount,
                      'timestamp': DateTime.now(),
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid placed successfully')));
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid amount must be higher than the current bid')));
                }
              },
              child: const Text('Place Bid'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handlePaystackPayment(BuildContext context, String bidId, double amount) async {
    final uniqueTransRef = PayWithPayStack().generateUuidV4();
    final email = FirebaseAuth.instance.currentUser?.email ?? '';

    PayWithPayStack().now(
      context: context,
      secretKey: "sk_test_2130201c7d1582334fa9ebdf1a9ede41ca30e8ce",
      customerEmail: email,
      reference: uniqueTransRef,
      callbackUrl: "",
      currency: "GHS",
      paymentChannel: ["mobile_money", "card"],
      amount: (amount * 1).toDouble(),
      transactionCompleted: () {
        print("Transaction Successful");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Successful!')),
        );
        // Update the bid status to 'paid'
        FirebaseFirestore.instance.collection('bids').doc(bidId).update({
          'status': 'Paid',
        });
      },
      transactionNotCompleted: () {
        print("Transaction Not Successful!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment Failed!')),
        );
      },
    );
  }

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
            colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
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
                var bidData = bid.data();

                if (bidData == null) {
                  return Container(); // Skip this bid if bidData is null
                }

                var bidMap = bidData as Map<String, dynamic>;

                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('spaces')
                      .doc(bidMap['spaceId'])
                      .get(),
                  builder: (context, spaceSnapshot) {
                    if (spaceSnapshot.connectionState == ConnectionState.waiting) {
                      return Container(); // Skip loading space data
                    }

                    if (spaceSnapshot.hasError || !spaceSnapshot.hasData || spaceSnapshot.data == null) {
                      return Container(); // Skip this space if there's an error or no data
                    }

                    var spaceData = spaceSnapshot.data?.data();

                    if (spaceData == null) {
                      return Container(); // Skip this space if spaceData is null
                    }

                    var spaceMap = spaceData as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                spaceMap['imageUrls'] != null && spaceMap['imageUrls'].isNotEmpty
                                    ? Image.network(spaceMap['imageUrls'][0], width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.image, size: 50),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    spaceMap['title'],
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Bid Amount: GH₵${bidMap['amount']}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Placed on: ${DateFormat('yyyy-MM-dd – kk:mm').format(bidMap['timestamp'].toDate())}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Status: ${bidMap['status'] ?? 'Pending'}',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
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
                            if (bidMap['status'] == 'accepted')
                              ElevatedButton(
                                onPressed: () {
                                  final bidAmount = bidMap['amount'] is double
                                      ? bidMap['amount']
                                      : double.tryParse(bidMap['amount'].toString());

                                  if (bidAmount != null) {
                                    _handlePaystackPayment(context, bid.id, bidAmount);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Invalid bid amount')),
                                    );
                                  }
                                },
                                child: const Text('Pay Now'),
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
