import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'events screen/events_screen.dart';
import 'Payouts/payouts_screen.dart';
import 'settings/settings_screen.dart';
import 'events screen/event_analytics.dart';
import 'package:project/views/event_space_search_page.dart';
import 'package:project/views/event_space_bid_management.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'BidForumScreen.dart';
class ProfileScreen extends StatefulWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      ProfileDetails(email: widget.email, greeting: getGreeting()), // Pass greeting and email to ProfileDetails
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
      extendBody: true, // Extend the body behind the bottom navigation bar
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
                stops: [0, 1],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _selectedIndex == 0
              ? SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Add bottom padding
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  decoration: BoxDecoration(
                    color: Color(0xff2575fc),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${getGreeting()} !',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Welcome back, hope you\'re feeling good today',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                ProfileDetails(email: widget.email, greeting: getGreeting()),
              ],
            ),
          )
              : Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(50),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
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
          unselectedItemColor: Colors.white,
          backgroundColor: const Color(0xff283048),
          elevation: 5,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: false,
          iconSize: 30,
          selectedIconTheme: const IconThemeData(size: 40),
        ),
      ),
    );
  }
}

class ProfileDetails extends StatefulWidget {
  final String email;
  final String greeting;

  const ProfileDetails({super.key, required this.email, required this.greeting});

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  int totalEvents = 0;
  int upcomingEvents = 0;
  double amountEarned = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateProfileStatistics();
  }

  void _calculateProfileStatistics() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        print('No user is currently logged in');
        return;
      }

      print('Fetching events for user ID: ${user.uid}');

      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: user.uid)
          .get();

      if (eventsSnapshot.docs.isEmpty) {
        print('No events found for user ID: ${user.uid}');
      } else {
        print('Events found for user ID: ${user.uid}');
        for (var event in eventsSnapshot.docs) {
          print('Event data: ${event.data()}');
        }
      }

      DateTime now = DateTime.now();
      int upcomingEventsCount = eventsSnapshot.docs.where((event) {
        var data = event.data() as Map<String, dynamic>;
        return data['eventDate'] != null && data['eventDate'].toDate().isAfter(now);
      }).length;

      setState(() {
        totalEvents = eventsSnapshot.docs.length;
        upcomingEvents = upcomingEventsCount;

        // Placeholder for amountEarned calculation, update as needed
        amountEarned = eventsSnapshot.docs.fold(0.0, (sum, event) {
          var data = event.data() as Map<String, dynamic>;
          return sum + (data['amountEarned']?.toDouble() ?? 0.0);
        });

        print('Total events: $totalEvents');
        print('Upcoming events: $upcomingEvents');
        print('Amount earned: $amountEarned');
      });
    } catch (e) {
      print('Error calculating profile statistics: $e');
      Fluttertoast.showToast(
        msg: "Error calculating profile statistics",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildProfileInfo(context, totalEvents, amountEarned, upcomingEvents);
  }

  Widget _buildProfileInfo(BuildContext context, int totalEvents, double amountEarned, int upcomingEvents) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoCard(
                    context,
                    "Total Events",
                    "assets/images/totalevents.png",
                    totalEvents.toString(),
                  ),
                  _buildInfoCard(
                    context,
                    "Upcoming Events",
                    "assets/images/upcoming.png",
                    upcomingEvents.toString(),
                  ),
                  _buildInfoCard(
                    context,
                    "Amount Earned",
                    "assets/images/currency.png",
                    "GHc${amountEarned.toStringAsFixed(2)}",
                  ),
                ],
              ),
            ),
          ),
          const Divider(color: Colors.white, thickness: 1, indent: 50, endIndent: 50),
          const Padding(
            padding: EdgeInsets.all(15),
            child: Text(
              "Event Operations",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const Divider(color: Colors.white, thickness: 1, indent: 50, endIndent: 50),
          _buildOperationCard(
            context,
            'Analytics',
            'https://cdn.pixabay.com/photo/2023/11/21/17/28/market-analytics-8403845_960_720.png',
            const EventAnalyticsScreen(),
          ),
          _buildOperationCard(
            context,
            'Search Event Spaces',
            'https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg',
            const EventSpaceSearchScreen(),
          ),
          _buildOperationCard(
            context,
            'Bid Forum',
            'https://cdn.pixabay.com/photo/2020/02/06/19/24/forum-4827715_960_720.jpg',
            const BidForumScreen(),
          ),
          _buildOperationCard(
            context,
            'Manage Bids',
            'https://cdn.pixabay.com/photo/2023/04/17/22/17/auction-7933637_1280.png',
            const EventSpaceBidManagementScreen(),
          ),

        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String imagePath, String value) {
    return Card(
      elevation: 1,
      color: Colors.white70,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        height: MediaQuery.of(context).size.height * 0.1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.15,
                    height: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.01),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationCard(BuildContext context, String title, String imageUrl, Widget destination) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.28,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 23,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

