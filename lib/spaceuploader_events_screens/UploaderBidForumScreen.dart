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
              String requestId = requests[index].id; // Get the document ID

              // Handle potential null values
              String message = request['message'] ?? 'No message provided';
              String? response = request['response']; // Can be null
              String? linkedSpaceId = request['linkedSpaceId']; // Can be null

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(message),
                  subtitle: response != null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Response: $response'),
                      if (linkedSpaceId != null)
                        GestureDetector(
                          onTap: () {
                            // Navigate to the linked space details page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SpaceDetailScreen(spaceId: linkedSpaceId),
                              ),
                            );
                          },
                          child: Text(
                            'View Space',
                            style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          ),
                        ),
                    ],
                  )
                      : const Text('No response yet'),
                  trailing: ElevatedButton(
                    onPressed: () => _showResponseDialog(context, requestId), // Pass the correct requestId
                    child: const Text('Reply'),
                  ),
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
              // Dropdown or list to select a space
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
                        child: Text(space['title'] ?? 'Untitled Space'),
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
                if (selectedSpaceId != null && responseController.text.isNotEmpty) {
                  _submitResponse(requestId, responseController.text, selectedSpaceId!);
                  Navigator.pop(context);
                } else {
                  // Handle case where no space is selected or no response is provided
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
    FirebaseFirestore.instance.collection('bid_forum').doc(requestId).update({
      'response': response,
      'linkedSpaceId': linkedSpaceId,
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
                // Add more space details here as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
