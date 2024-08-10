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
      ),
      body: Column(
        children: [
          Expanded(child: BidPostList()), // List of posts
          const BidPostInput(), // Input for new posts
        ],
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

            return Card(
              margin: const EdgeInsets.all(10),
              child: Padding(
                padding: const EdgeInsets.all(15),
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
                      postData['timestamp'] != null
                          ? (postData['timestamp'] as Timestamp).toDate().toString()
                          : 'Unknown time',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    if (postData['response'] != null) ...[
                      const SizedBox(height: 10),
                      const Divider(),
                      const Text(
                        'Response:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(postData['response']),
                      if (postData['linkedSpaceId'] != null)
                        GestureDetector(
                          onTap: () {
                            // Navigate to the linked space details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpaceDetailScreen(spaceId: postData['linkedSpaceId']),
                              ),
                            );
                          },
                          child: Text(
                            'View Space',
                            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                    ],
                  ],
                ),
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

// SpaceDetailScreen for navigating to the space details
class SpaceDetailScreen extends StatelessWidget {
  final String spaceId;

  const SpaceDetailScreen({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Space Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('spaces').doc(spaceId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final spaceData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spaceData['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(spaceData['description']),
                // Add more space details here as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
