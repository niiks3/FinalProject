import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts package
import 'package:project/views/events%20screen/new_event_screen.dart';
import 'events screen/events_screen.dart';
import 'Payouts/payouts_screen.dart';
import 'settings/settings_screen.dart';
import 'package:project/views/event_space_search_page.dart';
import 'package:project/views/event_space_bid_management.dart';
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
  int _currentCardIndex = 0;
  late Timer _timer;
  late List<_ShufflingCardData> _cardData;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();

    _widgetOptions = [
      ProfileDetails(email: widget.email, greeting: getGreeting()),
      const EventsScreen(),
      const PayoutsScreen(),
      const SettingsScreen(),
    ];

    _cardData = [
      _ShufflingCardData(
        title: 'Welcome to Eventy',
        imageUrl:
        'https://cdn.pixabay.com/photo/2015/04/27/11/48/sign-741813_1280.jpg',
      ),
      _ShufflingCardData(
        title: 'Create Event',
        imageUrl:
        'https://cdn.pixabay.com/photo/2017/11/24/10/43/ticket-2974645_1280.jpg',
      ),
      _ShufflingCardData(
        title: 'Search Event Spaces',
        imageUrl:
        'https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg',
      ),
      _ShufflingCardData(
        title: 'Bid Forum',
        imageUrl:
        'https://cdn.pixabay.com/photo/2015/02/22/17/46/forum-645246_1280.jpg',
      ),
      _ShufflingCardData(
        title: 'Manage Bids',
        imageUrl:
        'https://cdn.pixabay.com/photo/2023/04/17/22/17/auction-7933637_1280.png',
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
                        '${getGreeting()}!',
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
                  child: Text(
                    'Event Operations',
                    style: const TextStyle(
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
                style: GoogleFonts.openSans(
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
            title: 'Create Event',
            imageUrl: 'https://cdn.pixabay.com/photo/2017/11/24/10/43/ticket-2974645_1280.jpg',
            destination: NewEventScreen(),
          ),
          _buildCardItem(
            context,
            title: 'Search Venues',
            imageUrl: 'https://cdn.pixabay.com/photo/2016/01/07/19/06/event-1126344_1280.jpg',
            destination: const EventSpaceSearchScreen(),
          ),
          _buildCardItem(
            context,
            title: 'Bid Forum',
            imageUrl: 'https://cdn.pixabay.com/photo/2015/02/22/17/46/forum-645246_1280.jpg',
            destination: const BidForumScreen(),
          ),
          _buildCardItem(
            context,
            title: 'Manage Bids',
            imageUrl: 'https://cdn.pixabay.com/photo/2023/04/17/22/17/auction-7933637_1280.png',
            destination: const EventSpaceBidManagementScreen(),
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

class ProfileDetails extends StatelessWidget {
  final String email;
  final String greeting;

  const ProfileDetails({super.key, required this.email, required this.greeting});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueAccent,
              child: Text(
                email[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '$greeting!',
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              email,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
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

  _ShufflingCardData({
    required this.title,
    required this.imageUrl,
  });
}
