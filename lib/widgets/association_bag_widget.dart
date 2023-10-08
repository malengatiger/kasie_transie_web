import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/dashboard.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../data/association_counts.dart';
import '../network.dart';
import '../utils/emojis.dart';
import '../utils/prefs.dart';

class AssociationCountsWidget extends StatefulWidget {
  const AssociationCountsWidget({
    Key? key,
    required this.width,
    required this.operationsSummary,
    required this.dispatches,
    required this.passengers,
    required this.arrivals,
    required this.departures,
    required this.heartbeats,
  }) : super(key: key);

  final double width;
  final String operationsSummary,
      dispatches,
      passengers,
      arrivals,
      departures,
      heartbeats;

  @override
  State<AssociationCountsWidget> createState() =>
      _AssociationCountsWidgetState();
}

class _AssociationCountsWidgetState extends State<AssociationCountsWidget> {
  final mm = ' 🔆🔆🔆🔆🔆🔆 AssociationCountsWidget: 😡';
  bool busy = false;

  late StreamSubscription<AssociationCounts> _assocCountsSubscription;
  late StreamSubscription<AmbassadorPassengerCount>
      _passengerCountsSubscription;

  @override
  void initState() {
    super.initState();
    _listen();
    _getData();
    _startTimer();
  }

  AssociationCounts? associationCounts;
  List<AmbassadorPassengerCount> passengerCounts = [];
  late Timer timer;
  int totalPassengers = 0;
  int hours = 24;
  String? date;

  void _listen() async {
    _assocCountsSubscription = associationCountsStream.listen((event) {
      pp('$mm ... associationCountsStream delivered counts.dispatchRecords for ${event.dispatchRecords}');
      associationCounts = event;
      if (mounted) {
        setState(() {});
      }
    });
    _passengerCountsSubscription = passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered counts for ${event.vehicleReg}');
      passengerCounts.add(event);
      _aggregate();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _aggregate() {
    totalPassengers = 0;
    for (var pc in passengerCounts) {
      totalPassengers += pc.passengersIn!;
    }
    pp('$mm ...aggregate: totalPassengers :$totalPassengers');

  }

  void _startTimer() {
    pp('$mm ........ startTimer: tick every ${hours} hours');
    //todo - use settings here for timer?
    date = DateTime.now()
        .toUtc()
        .subtract(Duration(hours: hours))
        .toIso8601String();

    timer = Timer.periodic(Duration(minutes: 15), (timer) {
      pp('$mm ........ timer tick: ${timer.tick} ... call getAssociationCounts ...');
      _getData();
    });
  }

  Future<void> _getData() async {
    pp('$mm _getData ............................ '
        'getting association counts ... hours: $hours');
    date = DateTime.now()
        .toUtc()
        .subtract(Duration(hours: hours))
        .toIso8601String();

    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      associationCounts = await networkHandler.getAssociationCounts(
          user!.associationId!, date!);
      passengerCounts = await networkHandler
          .getAssociationAmbassadorPassengerCounts(user.associationId!, date!);
      _aggregate();
    } catch (e,s) {
      pp('$mm ERROR: $e - $s ${E.redDot}${E.redDot}${E.redDot}');
      if (mounted) {
        showSnackBar(
            backgroundColor: Colors.red, message: '$e', context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEEE, dd MMMM HH:mm');
    final style = myTextStyleMediumLargeWithColor(context, Colors.white, 14);
    return SizedBox(
      width: widget.width,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: associationCounts == null
                ? Center(child: TimerWidget(title: 'Loading summary ...'))
                : Column(
                    children: [
                      Card(
                        shape: getDefaultRoundedBorder(),
                        elevation: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              gapH16,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.operationsSummary,
                                    style: myTextStyleMediumLargeWithColor(
                                        context,
                                        Theme.of(context).primaryColorLight,
                                        20),
                                  ),
                                  gapW32,
                                  IconButton(
                                      onPressed: () {
                                        _getData();
                                      },
                                      icon: Icon(
                                        Icons.refresh,
                                        color: getPrimaryColorLight(context),
                                      )),
                                ],
                              ),
                              gapH16,
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(
                                            widget.dispatches,
                                            style: style,
                                          )),
                                      gapW16,
                                      TotalWidget(
                                          number: associationCounts!
                                              .dispatchRecords!,
                                          width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(widget.passengers,
                                              style: style)),
                                      gapW16,
                                      TotalWidget(
                                          number: totalPassengers, width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(widget.arrivals,
                                              style: style)),
                                      gapW16,
                                      TotalWidget(
                                          number: associationCounts!.arrivals!,
                                          width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(widget.departures,
                                              style: style)),
                                      gapW16,
                                      TotalWidget(
                                          number:
                                              associationCounts!.departures!,
                                          width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 100,
                                          child: Text(widget.heartbeats,
                                              style: style)),
                                      gapW16,
                                      TotalWidget(
                                          number:
                                              associationCounts!.heartbeats!,
                                          width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              gapH32,
                              Text(
                                'Last Updated',
                                style: myTextStyleSmall(context),
                              ),
                              gapH8,
                              date == null
                                  ? gapW32
                                  : Text(
                                      '${getFormattedDateLong(DateTime.parse(date!).toLocal().toIso8601String())}',
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          14),
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

class TotalWidget extends StatelessWidget {
  const TotalWidget({super.key, required this.number, required this.width});

  final int number;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return Card(
      elevation: 16,
      shape: getDefaultRoundedBorder(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                fmt.format(number),
                style: myTextStyleMediumLargeWithColor(
                    context, Theme.of(context).primaryColor, 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
