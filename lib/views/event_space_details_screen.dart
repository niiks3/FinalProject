import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventSpaceDetailsScreen extends StatelessWidget {
  final DocumentSnapshot eventSpace;

  const EventSpaceDetailsScreen({super.key, required this.eventSpace});

  @override
  Widget build(BuildContext context) {
    final data = eventSpace.data() as Map<String, dynamic>;
    final title = data['title'] ?? 'Unnamed Space';
    final description = data['description'] ?? 'No description available';
    final imageUrls = (data['imageUrls'] as List<dynamic>?)?.map((url) => url.toString()).toList() ?? [];

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
          ],
        ),
      ),
    );
  }
}
