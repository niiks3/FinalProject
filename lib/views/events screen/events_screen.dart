
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/views/event_space_bid_management.dart';
import 'package:project/views/profile_screen.dart';
import 'new_event_screen.dart';
import 'event_analytics.dart';
import 'view_event_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) =>  ProfileScreen(email: AutofillHints.email)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['Bids']
                        .map((category) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const EventSpaceBidManagementScreen()),
                          );

                          // Handle category selection
                        },

                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: category == 'All' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white),
                          ),
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              color: category == 'All' ? Colors.blue : Colors.white,
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
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: <Widget>[
                      EventCard(
                        date: 'New Event',
                        title: 'Create a new event',
                        location: 'Tap to create',
                        imageUrl: 'https://cdn.pixabay.com/photo/2017/11/24/10/43/ticket-2974645_1280.jpg', // Replace with actual image URL
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => NewEventScreen()),
                          );
                        },
                      ),
                      EventCard(
                        date: 'View Events',
                        title: 'View all events',
                        location: 'Tap to view',
                        imageUrl: 'https://cdn.pixabay.com/photo/2018/05/31/11/54/celebration-3443779_960_720.jpg',
                        // Replace with actual image URL
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
                          );
                        },


                      ),
                      EventCard(
                        date: 'Event Analytics',
                        title: 'View event analytics',
                        location: 'Tap to view analytics',
                        imageUrl: 'https://cdn.pixabay.com/photo/2023/11/21/17/28/market-analytics-8403845_960_720.png', // Replace with actual image URL
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EventAnalyticsScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final String date;
  final String title;
  final String location;
  final String imageUrl;
  final VoidCallback onTap;

  const EventCard({
    required this.date,
    required this.title,
    required this.location,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Image.network(imageUrl),
            ListTile(
              contentPadding: EdgeInsets.all(15),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: GoogleFonts.poppins(fontSize: 14)),
                  Text(location, style: GoogleFonts.poppins(fontSize: 14)),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://via.placeholder.com/20')),
                      SizedBox(width: 5),
                      CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://via.placeholder.com/20')),
                      SizedBox(width: 5),
                      CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://via.placeholder.com/20')),
                    ],
                  ),
                ],
              ),
              trailing: Icon(Icons.arrow_forward, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}