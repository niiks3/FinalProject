import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BidForumScreen extends StatelessWidget {
  const BidForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bid Forum'),
        backgroundColor: Colors.blue.shade900,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff6a11cb), Color(0xff2575fc)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(child: BidPostList()), // List of posts
            const BidPostInput(), // Input for new posts
          ],
        ),
      ),
    );
  }
}

// Widget to display the list of bid posts
class BidPostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bid_forum').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var documents = snapshot.data!.docs;

        return ListView.builder(
          itemCount: documents.length,
          itemBuilder: (context, index) {
            var post = documents[index];
            var postData = post.data() as Map<String, dynamic>;
            var timestamp = (postData['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            var dateString = "${timestamp.day}\n${timestamp.month}\n${timestamp.year}";

            return Card(
              margin: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      dateString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            postData['author'] ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(postData['content'] ?? ''),
                          const SizedBox(height: 10),
                          Text(
                            timestamp.toString(),
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Widget to input a new bid post
class BidPostInput extends StatefulWidget {
  const BidPostInput({super.key});

  @override
  _BidPostInputState createState() => _BidPostInputState();
}

class _BidPostInputState extends State<BidPostInput> {
  final TextEditingController _controller = TextEditingController();

  void _postBid() async {
    if (_controller.text.isEmpty) {
      return;
    }

    var user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to post.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('bid_forum').add({
      'author': user.email ?? 'Anonymous',
      'content': _controller.text,
      'timestamp': Timestamp.now(),
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(hintText: 'Enter your bid post'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _postBid,
          ),
        ],
      ),
    );
  }
}
