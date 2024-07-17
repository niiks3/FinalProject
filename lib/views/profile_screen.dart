import 'package:flutter/material.dart';
import 'events screen/events_screen.dart';
import 'Payouts/payouts_screen.dart';
import 'settings/settings_screen.dart';
import 'events screen/event_analytics.dart';
import 'package:project/views/event_space_search_page.dart';
import 'package:project/views/event_space_bid_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      ProfileDetails(email: widget.email),
      const EventsScreen(),
      const PayoutsScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Payouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProfileDetails extends StatelessWidget {
  final String email;

  const ProfileDetails({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('events').where('userEmail', isEqualTo: email).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildProfileInfo(context, 0, 0.0, 0);
        }

        int totalEvents = snapshot.data!.docs.length;
        double amountEarned = 0.0;
        int upcomingEvents = 0;
        DateTime now = DateTime.now();

        for (var doc in snapshot.data!.docs) {
          var data = doc.data() as Map<String, dynamic>;
          amountEarned += data['amountEarned'] ?? 0.0;
          if (data['eventDate'] != null && data['eventDate'].toDate().isAfter(now)) {
            upcomingEvents += 1;
          }
        }

        return _buildProfileInfo(context, totalEvents, amountEarned, upcomingEvents);
      },
    );
  }

  Widget _buildProfileInfo(BuildContext context, int totalEvents, double amountEarned, int upcomingEvents) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInfoCard('Total Events', totalEvents.toString(), context),
          const SizedBox(height: 16),
          _buildInfoCard('Amount Earned', '\$${amountEarned.toStringAsFixed(2)}', context),
          const SizedBox(height: 16),
          _buildInfoCard('Upcoming Events', upcomingEvents.toString(), context),
          const SizedBox(height: 16),
          _buildInfoCard('Analytics', 'View', context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventAnalyticsScreen()),
            );
          }),
          const SizedBox(height: 16),
          _buildInfoCard('Search Event Spaces', 'Search', context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventSpaceSearchScreen(  )),
            );
          }),
          const SizedBox(height: 16),
          _buildInfoCard('Manage Bids', 'Manage', context, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EventSpaceBidManagementScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, BuildContext context, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
