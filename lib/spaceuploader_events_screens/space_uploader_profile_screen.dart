import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/spaceuploader_events_screens/manage_spaces_screen.dart';
import 'package:project/spaceuploader_events_screens/space_uploader_events_screen.dart';
import 'package:project/spaceuploader_events_screens/uploaderbidemanagement.dart';
import '../views/Payouts/payouts_screen.dart';
import '../views/settings/settings_screen.dart';
import 'UploaderBidForumScreen.dart';

class SpaceUploaderProfileScreen extends StatefulWidget {
  final String email;

  const SpaceUploaderProfileScreen({super.key, required this.email});

  @override
  _SpaceUploaderProfileScreenState createState() => _SpaceUploaderProfileScreenState();
}

class _SpaceUploaderProfileScreenState extends State<SpaceUploaderProfileScreen> {
  int _selectedIndex = 0;
  int _currentCardIndex = 0;
  late Timer _timer;
  late List<_ShufflingCardData> _cardData;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      SpaceUploaderProfileDetails(email: widget.email),
      const SpaceUploaderEventsScreen(),
      const PayoutsScreen(),
      const SettingsScreen(),
    ];

    _cardData = [
      _ShufflingCardData(
        title: 'Manage Spaces',
        imageUrl: 'https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg',
        destination: const ManageSpacesScreen(),
      ),
      _ShufflingCardData(
        title: 'Manage Bids',
        imageUrl: 'https://cdn.pixabay.com/photo/2017/10/11/11/43/multitasking-2840792_1280.jpg',
        destination: const UploaderBidManagementScreen(),
      ),
      _ShufflingCardData(
        title: 'Bid Forum',
        imageUrl: 'https://cdn.pixabay.com/photo/2015/02/22/17/46/forum-645246_1280.jpg',
        destination: UploaderBidForumScreen(),
      ),
    ];

    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      setState(() {
        _currentCardIndex = (_currentCardIndex + 1) % _cardData.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 140,
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xff2575fc),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${SpaceUploaderProfileDetails(email: '').getGreeting()}!',
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
                const SizedBox(height: 20),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  alignment: Alignment.center,
                  child: _buildShufflingCard(
                      context, _cardData[_currentCardIndex]),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1), // Background color with some transparency
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 2,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Space Operations',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10), // Padding between text and grid
                _buildCardGrid(context),
              ],
            ),
          )
              : Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(50)),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'My Venues',
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
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.black,
          backgroundColor: const Color(0xff2575fc), // Match with page color
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

  Widget _buildShufflingCard(
      BuildContext context, _ShufflingCardData cardData) {
    // Determine the text color based on the title
    Color textColor = cardData.title == 'Bid Forum' ? Colors.black : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.28,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(cardData.imageUrl),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topLeft, // Align text to the top left
              child: Text(
                cardData.title,
                style: TextStyle(
                  fontSize: 28, // Increase font size
                  fontWeight: FontWeight.bold,
                  color: textColor, // Change color based on condition
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 15.0,
        mainAxisSpacing: 15.0,
        children: [
          _buildCardItem(
            context,
            title: 'My Venues',
            imageUrl: 'https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg',
            destination: const ManageSpacesScreen(),
          ),
          _buildCardItem(
            context,
            title: 'Manage Bids',
            imageUrl: 'https://cdn.pixabay.com/photo/2017/10/11/11/43/multitasking-2840792_1280.jpg',
            destination: const UploaderBidManagementScreen(),
          ),
          _buildCardItem(
            context,
            title: 'Bid Forum',
            imageUrl: 'https://cdn.pixabay.com/photo/2015/02/22/17/46/forum-645246_1280.jpg',
            destination: UploaderBidForumScreen(),
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(BuildContext context,
      {required String title, required String imageUrl, required Widget destination}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.8),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
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
    );
  }
}

class SpaceUploaderProfileDetails extends StatelessWidget {
  final String email;

  const SpaceUploaderProfileDetails({super.key, required this.email});

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
      future: FirebaseFirestore.instance.collection('spaces').where('userEmail', isEqualTo: email).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildProfileInfo(context, 0);
        }

        int totalSpaces = snapshot.data!.docs.length;

        return _buildProfileInfo(context, totalSpaces);
      },
    );
  }

  Widget _buildProfileInfo(BuildContext context, int totalSpaces) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                                    width: MediaQuery.of(context).size.width * 0.1,
                                    height: double.maxFinite,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color(0xff283048),
                                    ),
                                    child: const Icon(Icons.location_city, color: Colors.white),
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.01,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Total Spaces",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "($totalSpaces)",
                                        style: const TextStyle(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShufflingCardData {
  final String title;
  final String imageUrl;
  final Widget destination;

  _ShufflingCardData({
    required this.title,
    required this.imageUrl,
    required this.destination,
  });
}
