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
                    const SizedBox(height: 10),
                    _buildResponseList(post.id), // Display the list of responses
                    const Divider(),
                    ElevatedButton(
                      onPressed: () => _showResponseDialog(context, post.id), // Pass the correct post ID
                      child: const Text('Reply'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResponseList(String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('bid_forum').doc(postId).collection('responses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var responseDocs = snapshot.data!.docs;

        if (responseDocs.isEmpty) {
          return const Text('No responses yet.');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: responseDocs.map((doc) {
            var responseData = doc.data() as Map<String, dynamic>;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Response: ${responseData['response'] ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (responseData['linkedSpaceId'] != null)
                  GestureDetector(
                    onTap: () {
                      // Navigate to the linked space details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpaceDetailScreen(spaceId: responseData['linkedSpaceId']),
                        ),
                      );
                    },
                    child: Text(
                      'View Space',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  void _showResponseDialog(BuildContext context, String postId) {
    final TextEditingController responseController = TextEditingController();
    String? selectedSpaceId; // Nullable type to handle selection properly

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reply to Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: responseController,
                decoration: const InputDecoration(hintText: 'Enter your response'),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('spaces').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final spaces = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    items: spaces.map((space) {
                      return DropdownMenuItem<String>(
                        value: space.id, // Use space.id to get the document ID
                        child: Text(space['title']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedSpaceId = value; // Assign selectedSpaceId
                    },
                    decoration: const InputDecoration(hintText: 'Select a space to link'),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (responseController.text.isNotEmpty) {
                  _submitResponse(postId, responseController.text, selectedSpaceId);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a response.')),
                  );
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  void _submitResponse(String postId, String response, String? linkedSpaceId) {
    var responseData = {
      'response': response,
      'linkedSpaceId': linkedSpaceId,
    };

    FirebaseFirestore.instance.collection('bid_forum').doc(postId).collection('responses').add(responseData);
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
