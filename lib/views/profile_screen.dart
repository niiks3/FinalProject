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
          Positioned(
            top: 100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xff283048).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: 700,
            right: -100,
            child: Container(
              width: 200,
              height: 500,
              decoration: BoxDecoration(
                color: Colors.blue.shade800.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
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
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.event),
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

class ProfileDetails extends StatelessWidget {
  final String email;

  const ProfileDetails({super.key, required this.email});

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${getGreeting()} !',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Welcome back, hope you\'re feeling good today',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                      elevation: 1,
                      color: Colors.blueGrey,
                      child: SizedBox(

                        //create boxdecoration and add image
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
                                    width:
                                    MediaQuery.of(context).size.width * 0.1,
                                    height: double.maxFinite,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xff283048),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width * 0.01,
                                  ),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Events",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "(0)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Colors.blueGrey,
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
                                    width:
                                    MediaQuery.of(context).size.width * 0.1,
                                    height: double.maxFinite,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xff283048),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                    MediaQuery.of(context).size.width * 0.01,
                                  ),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Upcoming Events",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "(0)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 1,
                      color: Colors.blueGrey,
                      child: SizedBox(
                        //create boxdecoration and add image
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
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    height: double.maxFinite,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xff283048),
                                    ),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.01,
                                  ),
                                  const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Amount Earned",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      Text(
                                        "(GHc0.00)",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,

                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),

                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                "Event Operations",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage('https://cdn.pixabay.com/photo/2023/11/21/17/28/market-analytics-8403845_960_720.png'),
                      fit: BoxFit.cover
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
                child: InkWell( // Wrap with InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventAnalyticsScreen()),
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
                          child: const Text(
                            'Analytics',
                            style: TextStyle(
                              fontSize: 18,
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
            ),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage('https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg'),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: InkWell( // Wrap with InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventSpaceSearchScreen()),
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
                          child: const Text(
                            'Search Event Spaces',
                            style: TextStyle(
                              fontSize: 18,
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
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage('https://cdn.pixabay.com/photo/2023/04/17/22/17/auction-7933637_1280.png'),
                      fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: InkWell( // Wrap with InkWell
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EventSpaceBidManagementScreen()),
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
                          child: const Text(
                            'Manage bids',
                            style: TextStyle(
                              fontSize: 18,
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
              ))],
        ),

      ),
    );
  }

  Widget _buildInfoCard(String title, String value, BuildContext context, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xff283048),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(

              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
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


