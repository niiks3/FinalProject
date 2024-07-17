import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NewEventScreen extends StatefulWidget {
  @override
  _NewEventScreenState createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController urlController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  DateTime? eventDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  bool allowVirtual = false;
  bool openRsvp = false;
  bool isPaidEvent = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != eventDate) {
      setState(() {
        eventDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _onNextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _onPreviousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _submitForm() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final eventId = FirebaseFirestore.instance
          .collection('events')
          .doc()
          .id;

      final event = {
        'name': nameController.text,
        'type': typeController.text,
        'venue': venueController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'details': detailsController.text,
        'date': eventDate?.toIso8601String(),
        'start_time': startTime?.format(context),
        'end_time': endTime?.format(context),
        'allow_virtual': allowVirtual,
        'open_rsvp': openRsvp,
        'is_paid': isPaidEvent,
        'url': urlController.text,
        'price': isPaidEvent ? double.parse(priceController.text) : 0.0,
        'userId': currentUser.uid,
        'link': 'https://yourwebsite.com/register?eventId=$eventId',
      };

      await FirebaseFirestore.instance.collection('events').doc(eventId).set(event);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      print('Error saving event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Event'),
        elevation: 4,
        shadowColor: Colors.blue.withOpacity(0.5),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildEventInfoPage(),
                _buildTimingPage(),
                _buildOptionsPage(),
                _buildCustomizePage(),
              ],
            ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: EdgeInsets.all(4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.blue : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Widget _buildEventInfoPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Event Type'),
              ),
              TextField(
                controller: venueController,
                decoration: InputDecoration(labelText: 'Venue'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: detailsController,
                decoration: InputDecoration(labelText: 'Details'),
              ),
              TextField(
                controller: urlController,
                decoration: InputDecoration(labelText: 'Event URL'),
              ),
              if (isPaidEvent)
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Event Price'),
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimingPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Date and Time',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eventDate != null
                          ? DateFormat.yMMMd().format(eventDate!)
                          : 'Select Date',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context, true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      startTime != null
                          ? startTime!.format(context)
                          : 'Start Time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectTime(context, false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      endTime != null ? endTime!.format(context) : 'End Time',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionsPage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Options',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          SwitchListTile(
            title: Text('Allow Virtual Participation'),
            value: allowVirtual,
            onChanged: (value) {
              setState(() {
                allowVirtual = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Open for RSVP'),
            value: openRsvp,
            onChanged: (value) {
              setState(() {
                openRsvp = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('Paid Event'),
            value: isPaidEvent,
            onChanged: (value) {
              setState(() {
                isPaidEvent = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizePage() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          // Add any additional customization options here
          ElevatedButton(
            onPressed: _submitForm,
            child: Text('Create Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            ElevatedButton(
              onPressed: _onPreviousPage,
              child: Text('Previous'),
            ),
          if (_currentPage < 3)
            ElevatedButton(
              onPressed: _onNextPage,
              child: Text('Next'),
            ),
          if (_currentPage == 3)
            ElevatedButton(
              onPressed: _submitForm,
              child: Text('Submit'),
            ),
        ],
      ),
    );
  }
}
