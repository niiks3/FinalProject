import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'event_space_details_screen.dart';

class EventSpaceSearchScreen extends StatefulWidget {
  const EventSpaceSearchScreen({super.key});

  @override
  _EventSpaceSearchScreenState createState() => _EventSpaceSearchScreenState();
}

class _EventSpaceSearchScreenState extends State<EventSpaceSearchScreen> {
  int _selectedIndex = 0;
  List<String> _categories = ['All', 'Frequent', 'Favourites'];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff283048), Color(0xff859398)],
                  stops: [0, 1],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        hintText: 'Search event spaces',
                        hintStyle: TextStyle(color: Colors.white54),
                        prefixIcon: Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _categories.map((category) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIndex = _categories.indexOf(category);
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _selectedIndex == _categories.indexOf(category)
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Text(
                              category,
                              style: GoogleFonts.poppins(
                                color: _selectedIndex == _categories.indexOf(category)
                                    ? Colors.blue
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('spaces').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No event spaces available.'));
                        }

                        var eventSpaces = snapshot.data!.docs.where((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return data['title'] != null && data['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
                        }).toList();

                        return ListView.builder(
                          itemCount: eventSpaces.length,
                          itemBuilder: (context, index) {
                            var eventSpace = eventSpaces[index];
                            var data = eventSpace.data() as Map<String, dynamic>?;

                            if (data == null) {
                              return SizedBox.shrink();
                            }

                            var name = data['title']?.toString() ?? 'Unnamed Space';
                            var description = data['description']?.toString() ?? 'No description available';
                            var imageUrl = data['imageUrls']?.first ?? 'https://via.placeholder.com/150';

                            return _buildEventCard(
                              name: name,
                              description: description,
                              imageUrl: imageUrl,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EventSpaceDetailsScreen(eventSpace: eventSpace),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String name,
    required String description,
    required String imageUrl,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Image.network(imageUrl, errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 150,
                color: Colors.grey[200],
                child: Center(
                  child: Text(
                    'Image not available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }),
            ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(description),
            ),
          ],
        ),
      ),
    );
  }
}
