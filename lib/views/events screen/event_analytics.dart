import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EventAnalyticsScreen extends StatelessWidget {
  const EventAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Analytics'),
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('events').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var events = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
          var chartData = events.map((event) {
            return ChartData(event['name'], event['earnings']?.toDouble() ?? 0.0);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: ChartTitle(text: 'Event Earnings'),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries>[
                BarSeries<ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (ChartData data, _) => data.name,
                  yValueMapper: (ChartData data, _) => data.earnings,
                  name: 'Earnings',
                  color: Colors.blue,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChartData {
  ChartData(this.name, this.earnings);
  final String name;
  final double earnings;
}
