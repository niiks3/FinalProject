import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EventSpaceDetailsScreen extends StatelessWidget {
  final DocumentSnapshot eventSpace;

  const EventSpaceDetailsScreen({super.key, required this.eventSpace});

  @override
  Widget build(BuildContext context) {
    final data = eventSpace.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'Unnamed Space';
    final description = data['description'] ?? 'No description available';
    final imageUrls = (data['imageUrls'] as List<dynamic>?)?.map((url) => url.toString()).toList() ?? [];
    final startingBid = data['startingBid']?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Image.network(imageUrls[index], fit: BoxFit.cover),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey,
                child: const Center(
                  child: Text('No Images Available'),
                ),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              'Starting Bid: \₵${startingBid.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _BidSection(spaceId: eventSpace.id, startingBid: startingBid),
          ],
        ),
      ),
    );
  }
}

class _BidSection extends StatefulWidget {
  final String spaceId;
  final double startingBid;

  const _BidSection({required this.spaceId, required this.startingBid});

  @override
  __BidSectionState createState() => __BidSectionState();
}

class __BidSectionState extends State<_BidSection> {
  final TextEditingController _bidAmountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

      // Check if a bid already exists for the selected date
      QuerySnapshot existingBids = await FirebaseFirestore.instance
          .collection('bids')
          .where('spaceId', isEqualTo: widget.spaceId)
          .where('intendedDate', isEqualTo: formattedDate)
          .get();

      if (existingBids.docs.isNotEmpty) {
        // Check the status and find the highest bid
        double highestBid = 0.0;
        bool hasAcceptedBid = false;
        bool shouldProceed = false;

        for (var bidDoc in existingBids.docs) {
          var bidData = bidDoc.data() as Map<String, dynamic>;
          if (bidData['status'] == 'accepted') {
            hasAcceptedBid = true;
            break;
          } else if (bidData['status'] == 'pending') {
            double currentBidAmount = bidData['amount'];
            if (currentBidAmount > highestBid) {
              highestBid = currentBidAmount;
            }
            shouldProceed = await _showBidExistsDialog(context, highestBid);
          }
        }

        if (hasAcceptedBid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A bid has already been accepted for this date. No further bids are allowed.')),
          );
          return;
        }

        if (!shouldProceed) {
          return;
        }
      }

      setState(() {
        _dateController.text = formattedDate;
      });
    }
  }

  Future<bool> _showBidExistsDialog(BuildContext context, double highestBid) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Bid Already Exists'),
          content: Text(
              'A bid has already been placed for this date with the highest bid amount of GHC $highestBid. Do you want to proceed with a new bid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Choose Another Date'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _placeBid(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to place a bid')),
      );
      return;
    }

    final bidAmount = double.tryParse(_bidAmountController.text);
    final intendedDate = _dateController.text;

    if (bidAmount == null || bidAmount <= widget.startingBid || intendedDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please enter a valid bid amount and date'),
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('bids').add({
        'spaceId': widget.spaceId,
        'bidderId': user.uid,
        'amount': bidAmount,
        'intendedDate': intendedDate,
        'timestamp': Timestamp.now(),
        'status': 'pending', // All new bids start as pending
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid placed successfully')),
      );
      _bidAmountController.clear();
      _dateController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place bid: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Place a Bid',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _bidAmountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Bid Amount',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _dateController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Intended Date',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () => _selectDate(context),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _placeBid(context),
          child: _isLoading
              ? const CircularProgressIndicator()
              : const Text('Place Bid'),
        ),
      ],
    );
  }
}
