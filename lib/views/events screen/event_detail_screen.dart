import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    var guestsSnapshot = await FirebaseFirestore.instance
        .collection('guests')
        .where('eventId', isEqualTo: widget.event.id)
        .get();

    setState(() {
      numberOfGuests = guestsSnapshot.docs.length;
      seatsConfirmed = guestsSnapshot.docs
          .where((guest) => guest['admitted'] == true)
          .length;
      grossAmount = guestsSnapshot.docs
          .fold(0.0, (sum, guest) => sum + guest['ticketPrice']);
      netAmount = grossAmount * 0.95;
    });
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      Fluttertoast.showToast(msg: "Scanned: ${scanData.code}");
      controller.pauseCamera(); // Pause the camera after scanning
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Details'),
              Tab(text: 'Protocol'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
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
        body: TabBarView(
          children: [
            _buildDetailsTab(eventData),
            _buildProtocolTab(),
          ],
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
          _buildDetailCard('Gross Amount: \$${grossAmount.toStringAsFixed(2)}'),
          _buildDetailCard('Net Amount: \$${netAmount.toStringAsFixed(2)}'),
          const SizedBox(height: 16),
          if (eventData['link'] != null)
            _buildDetailCard('Event Link: ${eventData['link']}'),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
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

  Widget _buildProtocolTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search Guests',
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  setState(() {
                    searchQuery = '';
                  });
                },
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

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No guests registered.'));
                }

                var filteredGuests = snapshot.data!.docs.where((guest) {
                  return guest['name']
                      .toString()
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredGuests.length,
                  itemBuilder: (context, index) {
                    var guest = filteredGuests[index];

                    return ListTile(
                      title: Text(guest['name']),
                      subtitle: Text(guest['email']),
                      trailing: Switch(
                        value: guest['admitted'] ?? false,
                        onChanged: (value) {
                          FirebaseFirestore.instance
                              .collection('guests')
                              .doc(guest.id)
                              .update({
                            'admitted': value,
                          });
                        },
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
