import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EventAnalyticsScreen extends StatefulWidget {
  const EventAnalyticsScreen({super.key});

  @override
  _EventAnalyticsScreenState createState() => _EventAnalyticsScreenState();
}

class _EventAnalyticsScreenState extends State<EventAnalyticsScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  List<Widget> _eventDetails = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _eventDetails.length - 1) {
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

  Future<List<Map<String, dynamic>>> _fetchEventDetails() async {
    QuerySnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').get();
    List<Map<String, dynamic>> events = [];

    for (var doc in eventSnapshot.docs) {
      var eventData = doc.data() as Map<String, dynamic>;
      var guestsSnapshot = await FirebaseFirestore.instance
          .collection('guests')
          .where('eventId', isEqualTo: doc.id)
          .get();
      eventData['guests'] = guestsSnapshot.size;
      events.add(eventData);
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Event Analytics',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff283048),
      ),
      body: FutureBuilder(
        future: _fetchEventDetails(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var events = snapshot.data!;

          var chartData = events.map((event) {
            return ChartData(event['name'], (event['earnings']?.toDouble() ?? 0.0));
          }).toList();

          _eventDetails = events.map((event) {
            return _buildEventDetailCard(
              event['name'] ?? 'Unknown Event',
              event['guests'] ?? 0,
              event['startDate']?.toDate() ?? DateTime.now(),
              event['endDate']?.toDate() ?? DateTime.now(),
              _getRanking(event['guests'] ?? 0, events),
            );
          }).toList();

          return SingleChildScrollView(
            child: Container(
              height: mediaQuery.size.height,
              width: mediaQuery.size.width,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff283048), Color(0xff859398)],
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
                          text: 'Event Earnings',
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
                            yValueMapper: (ChartData data, _) => data.earnings,
                            name: 'Earnings',
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
                          LineSeries<ChartData, String>(
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.name,
                            yValueMapper: (ChartData data, _) => data.earnings * 0.8,
                            name: 'Projected Avg.',
                            color: Colors.orange,
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                              color: Colors.white,
                              borderWidth: 2,
                              borderColor: Colors.orange,
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
                        children: _eventDetails,
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

  Widget _buildEventDetailCard(
      String eventName, int guests, DateTime startDate, DateTime endDate, int ranking) {
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
              eventName,
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
                  'Guests',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$guests',
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
                  'Start Date',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${startDate.toLocal()}'.split(' ')[0],
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
                  'End Date',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${endDate.toLocal()}'.split(' ')[0],
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

  int _getRanking(int guests, List<Map<String, dynamic>> events) {
    events.sort((a, b) => (b['guests'] ?? 0).compareTo(a['guests'] ?? 0));
    return events.indexWhere((event) => (event['guests'] ?? 0) == guests) + 1;
  }
}

class ChartData {
  ChartData(this.name, this.earnings);
  final String name;
  final double earnings;
}
