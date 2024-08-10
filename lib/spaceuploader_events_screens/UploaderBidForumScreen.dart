import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UploaderBidForumScreen extends StatelessWidget {
  const UploaderBidForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bid Forum'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bid_forum').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              String requestId = requests[index].id;

              // Ensure message field is properly retrieved
              String message = request['content'] ?? 'No message provided';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ExpansionTile(
                  title: Text(message),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bid_forum')
                          .doc(requestId)
                          .collection('responses')
                          .snapshots(),
                      builder: (context, responseSnapshot) {
                        if (!responseSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final responses = responseSnapshot.data!.docs;

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: responses.length,
                          itemBuilder: (context, responseIndex) {
                            var response = responses[responseIndex].data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text('Response: ${response['response']}'),
                              subtitle: response['linkedSpaceId'] != null
                                  ? GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SpaceDetailScreen(spaceId: response['linkedSpaceId']),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'View Space',
                                  style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                                ),
                              )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () => _showResponseDialog(context, requestId),
                      child: const Text('Reply'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showResponseDialog(BuildContext context, String requestId) {
    final TextEditingController responseController = TextEditingController();
    String? selectedSpaceId;

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
                        value: space.id,
                        child: Text(space['title'] ?? 'Untitled Space'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      selectedSpaceId = value;
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
                if (selectedSpaceId != null && responseController.text.isNotEmpty) {
                  _submitResponse(requestId, responseController.text, selectedSpaceId!);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a response and select a space to link.')),
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

  void _submitResponse(String requestId, String response, String linkedSpaceId) {
    FirebaseFirestore.instance
        .collection('bid_forum')
        .doc(requestId)
        .collection('responses')
        .add({
      'response': response,
      'linkedSpaceId': linkedSpaceId,
      'timestamp': Timestamp.now(),
    });
  }
}

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

          final spaceData = snapshot.data!.data() as Map<String, dynamic>?;

          if (spaceData == null) {
            return const Center(child: Text('Space details not found.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spaceData['title'] ?? 'Untitled Space',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(spaceData['description'] ?? 'No description provided.'),
              ],
            ),
          );
        },
      ),
    );
  }
}
