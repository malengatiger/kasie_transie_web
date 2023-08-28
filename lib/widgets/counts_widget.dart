import 'package:flutter/material.dart';

import 'number_widget.dart';

class CountsGridWidget extends StatelessWidget {
  const CountsGridWidget({
    Key? key,
    required this.arrivalsText,
    required this.departuresText,
    required this.dispatchesText,
    required this.heartbeatText,
    required this.arrivals,
    required this.departures,
    required this.heartbeats,
    required this.dispatches,
    required this.passengerCountsText,
    required this.passengerCounts,
  }) : super(key: key);

  final String arrivalsText,
      departuresText,
      dispatchesText,
      heartbeatText,
      passengerCountsText;

  final int arrivals, departures, heartbeats, dispatches, passengerCounts;

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, crossAxisSpacing: 2, mainAxisSpacing: 2),
      children: [
        NumberWidget(
          title: passengerCountsText,
          number: passengerCounts,
          fontSize: 24,
          width: 100,
          height: 100,
          elevation: 12,
        ),
        NumberWidget(
          title: arrivalsText,
          number: arrivals,
          fontSize: 24,
          width: 100,
          height: 100,
          elevation: 12,
        ),
        NumberWidget(
          title: departuresText,
          number: departures,
          fontSize: 24,
          width: 100,
          height: 100,
          elevation: 12,
        ),
        NumberWidget(
          title: dispatchesText,
          number: dispatches,
          fontSize: 24,
          width: 100,
          height: 100,
          elevation: 12,
        ),
        NumberWidget(
          title: heartbeatText,
          number: heartbeats,
          fontSize: 24,
          width: 100,
          height: 100,
          elevation: 12,
        ),
      ],
    );
  }
}
