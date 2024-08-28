import 'dart:async';
import 'package:flutter/material.dart';

class ShufflingCard extends StatefulWidget {
  final List<_ShufflingCardData> cardData;
  final Duration interval;

  const ShufflingCard({
    Key? key,
    required this.cardData,
    this.interval = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  _ShufflingCardState createState() => _ShufflingCardState();
}

class _ShufflingCardState extends State<ShufflingCard> {
  int _currentCardIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (Timer timer) {
      setState(() {
        _currentCardIndex = (_currentCardIndex + 1) % widget.cardData.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardData = widget.cardData[_currentCardIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _buildOperationCard(context, cardData),
    );
  }

  Widget _buildOperationCard(BuildContext context, _ShufflingCardData cardData) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        key: ValueKey<int>(_currentCardIndex), // Ensures the AnimatedSwitcher works properly
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
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => cardData.destination),
            );
          },
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(16),
                    ),
                  ),
                  child: Text(
                    cardData.title,
                    style: const TextStyle(
                      fontSize: 23,
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
      ),
    );
  }
}

class _ShufflingCardData {
  final String title;
  final String imageUrl;
  final Widget destination;

  _ShufflingCardData({
    required this.title,
    required this.imageUrl,
    required this.destination,
  });
}
