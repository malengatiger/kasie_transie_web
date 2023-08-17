import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/data/association_bag.dart';
import 'package:kasie_transie_web/utils/functions.dart';

class AssociationBagWidget extends StatelessWidget {
  const AssociationBagWidget(
      {Key? key,
      required this.bag,
      required this.width,
      required this.operationsSummary,
      required this.dispatches,
      required this.passengers,
      required this.arrivals,
      required this.departures,
      required this.heartbeats,
      required this.lastUpdated, required this.date})
      : super(key: key);

  final AssociationBag bag;
  final double width;
  final String operationsSummary,
      dispatches,
      passengers,
      arrivals,
      departures,
      heartbeats,
      lastUpdated, date;
  @override
  Widget build(BuildContext context) {
    var totalPassengers = 0;
    for (var value in bag.passengerCounts) {
      totalPassengers += value.passengersIn!;
    }
    final fmt = NumberFormat.decimalPattern();
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 16,
                  color: Colors.black54,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        gapH16,
                        Text(
                          operationsSummary,
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColorLight, 20),
                        ),
                        gapH16,
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text(dispatches)),
                                gapW16,
                                Text(
                                  fmt.format(bag.dispatchRecords.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black54,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text(passengers)),
                                gapW16,
                                Text(
                                  fmt.format(totalPassengers),
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text(arrivals)),
                                gapW16,
                                Text(
                                  fmt.format(bag.arrivals.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text(departures)),
                                gapW16,
                                Text(
                                  fmt.format(bag.departures.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                SizedBox(width: 100, child: Text(heartbeats)),
                                gapW16,
                                Text(
                                  fmt.format(bag.heartbeats.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      24),
                                ),
                              ],
                            ),
                          ),
                        ),
                        gapH32,
                        Text(
                          lastUpdated,
                          style: myTextStyleSmall(context),
                        ),
                        gapH8,
                        Text(date,
                          style: myTextStyleMediumLargeWithColor(context,
                              Theme.of(context).primaryColorLight, 14),
                        ),
                        gapH32,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
