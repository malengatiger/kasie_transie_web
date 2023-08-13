import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/data/association_bag.dart';
import 'package:kasie_transie_web/utils/functions.dart';

class AssociationBagWidget extends StatelessWidget {
  const AssociationBagWidget({Key? key, required this.bag, required this.width})
      : super(key: key);

  final AssociationBag bag;
  final double width;
  @override
  Widget build(BuildContext context) {
    var passengers = 0;
    for (var value in bag.passengerCounts) {
      passengers += value.passengersIn!;
    }
    final fmt = NumberFormat.decimalPattern();
    return SizedBox(
      width: width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 16,
                  color: Colors.black38,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        gapH16,
                        Text('Total Events', style: myTextStyleMediumLargeWithColor(context, Theme.of(context).primaryColorLight,
                            32),),
                        gapH16,
                        Card(
                          shape: getDefaultRoundedBorder(),
                          elevation: 12,
                          color: Colors.black26,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 100,child: Text('Dispatches')),
                                gapW32,
                                Text(
                                  fmt.format(bag.dispatchRecords.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Theme.of(context).primaryColor, 36),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 100,child: Text('Passengers')),
                                gapW32,
                                Text(
                                  fmt.format(passengers),
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Theme.of(context).primaryColor, 36),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 100,child: Text('Arrivals')),
                                gapW32,
                                Text(
                                  fmt.format(bag.arrivals.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Theme.of(context).primaryColor, 36),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 100,child: Text('Departures')),
                                gapW32,
                                Text(
                                  fmt.format(bag.departures.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Theme.of(context).primaryColor, 36),
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
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const SizedBox(width: 100,child: Text('Heartbeats')),
                                gapW32,
                                Text(
                                  fmt.format(bag.heartbeats.length),
                                  style: myTextStyleMediumLargeWithColor(
                                      context, Theme.of(context).primaryColor, 36),
                                ),
                              ],
                            ),
                          ),
                        ),
                        gapH32,
                        Row(
                          children: [
                             Text('Last Updated: ', style: myTextStyleSmall(context),),
                            gapW8,
                            Text(getFormattedDateLong(DateTime.now().toIso8601String()), style: myTextStyleMediumLargeWithColor(context, Theme.of(context).primaryColorLight,
                                14),)
                          ],
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
