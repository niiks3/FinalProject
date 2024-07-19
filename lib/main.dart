import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/onboarding_screen.dart';
import 'views/login_signup_view.dart';
import 'views/profile_screen.dart';
import 'views/events screen/new_event_screen.dart';
import 'views/event_space_search_page.dart';
import 'views/event_space_details_screen.dart';
import 'views/events screen/event_detail_screen.dart';
import 'views/event_space_bid_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: _buildTheme(Brightness.light),
      home: const OnBoardingScreen(),
      getPages: [
        GetPage(name: '/', page: () => const OnBoardingScreen()),
        GetPage(name: '/login', page: () => const LoginSignupView()),
        GetPage(name: '/profile', page: () => ProfileScreen(email: '')),
        GetPage(name: '/new-event', page: () => NewEventScreen()),
        GetPage(name: '/search-event-spaces', page: () => const EventSpaceSearchScreen()),
        // For these routes, we assume you'll pass the actual data when navigating
        GetPage(name: '/event-space-details', page: () {
          var eventSpace = Get.arguments as DocumentSnapshot;
          return EventSpaceDetailsScreen(eventSpace: eventSpace);
        }),
        GetPage(name: '/event-detail', page: () {
          var event = Get.arguments as DocumentSnapshot;
          return EventDetailScreen(event: event);
        }),
        GetPage(name: '/manage-bids', page: () => const EventSpaceBidManagementScreen()),
      ],
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(brightness: brightness);
    return baseTheme.copyWith(
      textTheme: GoogleFonts.latoTextTheme(baseTheme.textTheme).copyWith(
        bodyMedium: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: Colors.black,
        ),
      ),
    );
  }
}
