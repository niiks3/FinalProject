import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SpaceUploaderEventAnalyticsScreen extends StatefulWidget {
  const SpaceUploaderEventAnalyticsScreen({super.key});

  @override
  _SpaceUploaderEventAnalyticsScreenState createState() => _SpaceUploaderEventAnalyticsScreenState();
}

class _SpaceUploaderEventAnalyticsScreenState extends State<SpaceUploaderEventAnalyticsScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  List<Widget> _spaceDetails = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _spaceDetails.length - 1) {
        setState(() {
          _currentPage++;
        });
      } else {
        setState(() {
          _currentPage = 0;
        });
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    });
  }

  Future<List<Map<String, dynamic>>> _fetchSpaceDetails() async {
    QuerySnapshot spaceSnapshot = await FirebaseFirestore.instance.collection('spaces').get();
    List<Map<String, dynamic>> spaces = [];

    for (var doc in spaceSnapshot.docs) {
      var spaceData = doc.data() as Map<String, dynamic>;
      var bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('spaceId', isEqualTo: doc.id)
          .get();
      spaceData['bookings'] = bookingsSnapshot.size;
      spaceData['totalPaid'] = bookingsSnapshot.docs
          .map((booking) => booking.data()['amountPaid'] ?? 0)
          .reduce((a, b) => a + b);
      spaces.add(spaceData);
    }

    return spaces;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Space Analytics',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff283048),
      ),
      body: FutureBuilder(
        future: _fetchSpaceDetails(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var spaces = snapshot.data!;

          var chartData = spaces.map((space) {
            return ChartData(space['name'], (space['totalPaid']?.toDouble() ?? 0.0));
          }).toList();

          _spaceDetails = spaces.map((space) {
            return _buildSpaceDetailCard(
              space['name'] ?? 'Unknown Space',
              space['bookings'] ?? 0,
              _getRanking(space['bookings'] ?? 0, spaces),
            );
          }).toList();

          return SingleChildScrollView(
            child: Container(
              height: mediaQuery.size.height,
              width: mediaQuery.size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff5C3F1FF), Color(0xff2575fc)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      height: mediaQuery.size.height * 0.4,
                      width: mediaQuery.size.width * 0.9,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          minimum: 0,
                          maximum: 20000,
                          interval: 5000,
                          labelFormat: '₵{value}k',
                        ),
                        title: ChartTitle(
                          text: 'Total Amount Paid for Spaces',
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        legend: Legend(
                          isVisible: true,
                          textStyle: const TextStyle(color: Colors.white),
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <ChartSeries>[
                          LineSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.name,
                            yValueMapper: (ChartData data, _) => data.totalPaid,
                            name: 'Total Paid',
                            color: Colors.blue,
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                              color: Colors.white,
                              borderWidth: 2,
                              borderColor: Colors.blue,
                            ),
                            dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.auto,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: mediaQuery.size.height * 0.3,
                      width: mediaQuery.size.width * 0.9,
                      child: PageView(
                        controller: _pageController,
                        children: _spaceDetails,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpaceDetailCard(String spaceName, int bookings, int ranking) {
    return Card(
      color: const Color(0xff283048),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              spaceName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$bookings',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ranking',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$ranking',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _getRanking(int bookings, List<Map<String, dynamic>> spaces) {
    spaces.sort((a, b) => (b['bookings'] ?? 0).compareTo(a['bookings'] ?? 0));
    return spaces.indexWhere((space) => (space['bookings'] ?? 0) == bookings) + 1;
  }
}

class ChartData {
  ChartData(this.name, this.totalPaid);
  final String name;
  final double totalPaid;
}
