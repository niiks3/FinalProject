import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageSpacesScreen extends StatefulWidget {
    const ManageSpacesScreen({super.key});

    @override
    _ManageSpacesScreenState createState() => _ManageSpacesScreenState();
}

class _ManageSpacesScreenState extends State<ManageSpacesScreen> {
    String searchQuery = '';

    @override
    Widget build(BuildContext context) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser == null) {
            return Scaffold(
                appBar: AppBar(
                    title: const Text('Manage Spaces'),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
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
                    child: const Center(
                        child: Text(
                            'User not logged in',
                            style: TextStyle(color: Colors.white),
                        ),
                    ),
                ),
            );
        }

        return Scaffold(
            appBar: AppBar(
                title: const Text('Manage Spaces'),
                backgroundColor: Colors.transparent,
                elevation: 0,
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
                child: Column(
                    children: [
                        SizedBox(height: kToolbarHeight + 16), // Add space for the AppBar
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                                decoration: InputDecoration(
                                    hintText: 'Search Spaces',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30.0),
                                        borderSide: BorderSide.none,
                                    ),
                                ),
                                onChanged: (value) {
                                    setState(() {
                                        searchQuery = value.toLowerCase();
                                    });
                                },
                            ),
                        ),
                        Expanded(
                            child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('spaces')
                                    .where('createdBy', isEqualTo: currentUser.uid)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(child: CircularProgressIndicator());
                                    }

                                    if (snapshot.hasError) {
                                        return Center(
                                            child: Text('Error: ${snapshot.error}',
                                                style: const TextStyle(color: Colors.white)));
                                    }

                                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Center(
                                            child: Text('No spaces available.',
                                                style: TextStyle(color: Colors.white)));
                                    }

                                    var filteredSpaces = snapshot.data!.docs.where((doc) {
                                        var spaceName = (doc.data() as Map<String, dynamic>)['title']
                                            .toString()
                                            .toLowerCase();
                                        return spaceName.contains(searchQuery);
                                    }).toList();

                                    return ListView.builder(
                                        itemCount: filteredSpaces.length,
                                        itemBuilder: (context, index) {
                                            var space = filteredSpaces[index];
                                            var spaceData = space.data() as Map<String, dynamic>;

                                            return Card(
                                                margin: const EdgeInsets.symmetric(
                                                    horizontal: 16.0, vertical: 8.0),
                                                child: Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                            Row(
                                                                children: [
                                                                    spaceData['imageUrls'] != null &&
                                                                        spaceData['imageUrls'].isNotEmpty
                                                                        ? Image.network(
                                                                        spaceData['imageUrls'][0],
                                                                        width: 50,
                                                                        height: 50,
                                                                        fit: BoxFit.cover,
                                                                    )
                                                                        : const Icon(Icons.image, size: 50),
                                                                    const SizedBox(width: 10),
                                                                    Expanded(
                                                                        child: Text(
                                                                            spaceData['title'] ?? 'Unnamed Space',
                                                                            style: Theme.of(context)
                                                                                .textTheme
                                                                                .headlineSmall,
                                                                        ),
                                                                    ),
                                                                ],
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Text(
                                                                spaceData['description'] ?? 'No description',
                                                                style: const TextStyle(
                                                                    fontSize: 16, fontWeight: FontWeight.bold),
                                                            ),
                                                            const SizedBox(height: 10),
                                                            Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                    ElevatedButton(
                                                                        onPressed: () {
                                                                            // Implement view details functionality here
                                                                        },
                                                                        child: const Text(''),
                                                                    ),
                                                                    IconButton(
                                                                        icon: const Icon(Icons.delete,
                                                                            color: Colors.red),
                                                                        onPressed: () =>
                                                                            _deleteSpace(space.id),
                                                                    ),
                                                                ],
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            );
                                        },
                                    );
                                },
                            ),
                        ),
                    ],
                ),
            ),
        );
    }

    void _deleteSpace(String spaceId) async {
        try {
            await FirebaseFirestore.instance
                .collection('spaces')
                .doc(spaceId)
                .delete();
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Space deleted successfully')),
            );
        } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete space: $e')),
            );
        }
    }
}
