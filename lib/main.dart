import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'views/onboarding_screen.dart';
import 'views/login_signup_view.dart';
import 'views/profile_screen.dart';
import 'views/space_uploader_login_signup_view.dart';
import 'spaceuploader_events_screens/space_uploader_profile_screen.dart';
import 'spaceuploader_events_screens//space_uploader_events_screen.dart';
import 'views/events screen/new_event_screen.dart';
import 'views/event_space_search_page.dart';
import 'views/event_space_details_screen.dart';
import 'views/events screen/event_detail_screen.dart';
import 'views/event_space_bid_management.dart';
import 'spaceuploader_events_screens/add_space_screen.dart'; // Changed to add_space_screen.dart
import 'spaceuploader_events_screens//manage_spaces_screen.dart';
import 'spaceuploader_events_screens//space_uploader_event_analytics.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
        GetPage(name: '/space-uploader-profile', page: () => SpaceUploaderProfileScreen(email: '')),
        GetPage(name: '/space-uploader-events', page: () => const SpaceUploaderEventsScreen()),
        GetPage(name: '/new-event', page: () => NewEventScreen()),
        GetPage(name: '/search-event-spaces', page: () => const EventSpaceSearchScreen()),
        GetPage(name: '/event-space-details', page: () {
          var eventSpace = Get.arguments as DocumentSnapshot;
          return EventSpaceDetailsScreen(eventSpace: eventSpace);
        }),
        GetPage(name: '/event-detail', page: () {
          var event = Get.arguments as DocumentSnapshot;
          return EventDetailScreen(event: event);
        }),
        GetPage(name: '/manage-bids', page: () => const EventSpaceBidManagementScreen()),
        GetPage(name: '/space-uploader-login-signup', page: () => const SpaceUploaderLoginSignupView()),
        GetPage(name: '/add-space', page: () => AddSpaceScreen()), // Changed to AddSpaceScreen
        GetPage(name: '/manage-spaces', page: () => const ManageSpacesScreen()),
        GetPage(name: '/space-uploader-event-analytics', page: () => const SpaceUploaderEventAnalyticsScreen()),
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
