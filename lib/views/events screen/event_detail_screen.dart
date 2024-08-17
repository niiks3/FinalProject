import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/services.dart';

class EventDetailScreen extends StatefulWidget {
  final DocumentSnapshot event;

  const EventDetailScreen({super.key, required this.event});

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  int numberOfGuests = 0;
  int seatsConfirmed = 0;
  double grossAmount = 0.0;
  double netAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateEventStatistics();
  }

  void _calculateEventStatistics() async {
    try {
      QuerySnapshot guestsSnapshot = await FirebaseFirestore.instance
          .collection('guests')
          .where('eventId', isEqualTo: widget.event.id)
          .get();

      setState(() {
        numberOfGuests = guestsSnapshot.docs.length;
        seatsConfirmed = guestsSnapshot.docs
            .where((guest) => (guest.data() as Map<String, dynamic>)['admitted'] == true)
            .length;
        grossAmount = guestsSnapshot.docs
            .fold(0.0, (sum, guest) => sum + ((guest.data() as Map<String, dynamic>)['ticketPrice']?.toDouble() ?? 0.0));
        netAmount = grossAmount * 0.95;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error calculating event statistics",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera(); // Pause the camera after scanning

      // Print scanned QR code data for debugging
      print("Scanned QR Code: ${scanData.code}");

      // Parse QR code data
      final uri = Uri.tryParse(scanData.code ?? '');

      if (uri == null) {
        Fluttertoast.showToast(
          msg: "Invalid QR code format",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        controller.resumeCamera();
        return;
      }

      // Extract parameters from the QR code
      final eventId = uri.queryParameters['eventId'] ?? '';
      final firstName = uri.queryParameters['firstName'] ?? '';
      final lastName = uri.queryParameters['lastName'] ?? '';
      final phoneNumber = uri.queryParameters['phoneNumber'] ?? '';
      final email = uri.queryParameters['email'] ?? '';

      // Log extracted data for debugging
      print("Extracted Data - Event ID: $eventId, First Name: $firstName, Last Name: $lastName, Phone: $phoneNumber, Email: $email");

      if (firstName.isEmpty || lastName.isEmpty || eventId.isEmpty || phoneNumber.isEmpty || email.isEmpty) {
        Fluttertoast.showToast(
          msg: "Invalid QR code data",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        controller.resumeCamera();
        return;
      }

      // Proceed with checking guest registration in Firestore
      try {
        QuerySnapshot guestsSnapshot = await FirebaseFirestore.instance
            .collection('guests')
            .where('eventId', isEqualTo: eventId)
            .where('firstName', isEqualTo: firstName)
            .where('lastName', isEqualTo: lastName)
            .where('phoneNumber', isEqualTo: phoneNumber)
            .where('email', isEqualTo: email)
            .get();

        if (guestsSnapshot.docs.isNotEmpty) {
          final guestDoc = guestsSnapshot.docs.first;
          final guestData = guestDoc.data() as Map<String, dynamic>;
          final isAdmitted = guestData['admitted'] ?? false;

          if (isAdmitted) {
            Fluttertoast.showToast(
              msg: "$firstName $lastName has already been admitted",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.orange,
              textColor: Colors.white,
              fontSize: 16.0,
            );
          } else {
            await FirebaseFirestore.instance
                .collection('guests')
                .doc(guestDoc.id)
                .update({'admitted': true, 'status': 'Admitted'});

            Fluttertoast.showToast(
              msg: "$firstName $lastName has been admitted",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.green,
              textColor: Colors.white,
              fontSize: 16.0,
            );

            _calculateEventStatistics(); // Optionally update stats
          }
        } else {
          Fluttertoast.showToast(
            msg: "Guest not found",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      } catch (e) {
        print('Error admitting guest: $e');
        Fluttertoast.showToast(
          msg: "Error admitting guest",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } finally {
        controller.resumeCamera();
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var eventData = widget.event.data() as Map<String, dynamic>;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(eventData['name']),
          backgroundColor: const Color(0xff283048),
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Protocol'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRViewExample(onQRViewCreated: _onQRViewCreated),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xf95C3F1FF), Color(0xff2575fc)],
              stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: TabBarView(
            children: [
              _buildDetailsTab(eventData),
              _buildProtocolTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab(Map<String, dynamic> eventData) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          _buildDetailCard('Number of Guests Registered: $numberOfGuests'),
          _buildDetailCard('Number of Seats Confirmed: $seatsConfirmed'),
          _buildDetailCard('Gross Amount: ¢${grossAmount.toStringAsFixed(2)}'),
          _buildDetailCard('Net Amount: ¢${netAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          if (eventData['link'] != null)
            _buildDetailCardWithButton(
              'Event Link: ${eventData['link']}',
              'Copy Link',
                  () {
                Clipboard.setData(ClipboardData(text: eventData['link']));
                Fluttertoast.showToast(msg: "Link copied to clipboard");
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildDetailCardWithButton(String text, String buttonText, VoidCallback onPressed) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            spreadRadius: 1.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onPressed,
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search Guests',
              prefixIcon: const Icon(Icons.search, color: Colors.white),
              filled: true,
              fillColor: Colors.white.withOpacity(0.7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('guests')
                  .where('eventId', isEqualTo: widget.event.id)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No guests registered.'));
                }

                var filteredGuests = snapshot.data!.docs.where((guest) {
                  var guestData = guest.data() as Map<String, dynamic>;
                  var guestName = (guestData['firstName'] ?? '') +
                      ' ' +
                      (guestData['lastName'] ?? '');
                  return guestName
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredGuests.length,
                  itemBuilder: (context, index) {
                    var guest = filteredGuests[index];
                    var guestData = guest.data() as Map<String, dynamic>;
                    var guestName = (guestData['firstName'] ?? '') +
                        ' ' +
                        (guestData['lastName'] ?? '');
                    var isAdmitted = guestData['admitted'] ?? false;

                    return ListTile(
                      title: Text(
                        guestName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        isAdmitted ? 'Status: Admitted' : 'Status: Not Admitted',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: ElevatedButton(
                        onPressed: isAdmitted
                            ? null
                            : () {
                          FirebaseFirestore.instance
                              .collection('guests')
                              .doc(guest.id)
                              .update({
                            'admitted': true,
                            'status': 'Admitted'
                          }).then((_) {
                            _calculateEventStatistics(); // Recalculate stats
                            Fluttertoast.showToast(
                              msg: "$guestName has been admitted",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          }).catchError((error) {
                            Fluttertoast.showToast(
                              msg: "Error: $error",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          });
                        },
                        child: const Text('Admit'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QRViewExample extends StatelessWidget {
  final Function(QRViewController) onQRViewCreated;

  const QRViewExample({super.key, required this.onQRViewCreated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code Scanner')),
      body: QRView(
        key: GlobalKey(debugLabel: 'QR'),
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}

