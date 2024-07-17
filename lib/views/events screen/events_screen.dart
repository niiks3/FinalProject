import 'package:flutter/material.dart';
import 'new_event_screen.dart';
import 'event_analytics.dart';
import 'view_event_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('New Event'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewEventScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('View  Events'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ViewEventsScreen()),
              );
            },
          ),
          ListTile(
            title: const Text('Event Analytics'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventAnalyticsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
