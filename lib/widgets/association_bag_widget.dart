import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/blocs/stream_bloc.dart';
import 'package:kasie_transie_web/data/dispatch_record.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../data/association_counts.dart';
import '../network.dart';
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
    required this.lastUpdated,
    this.color, required this.minutes,
  }) : super(key: key);

  final Color? color;
  final double width;
  final String operationsSummary,
      dispatches,
      passengers,
      arrivals,
      departures,
      heartbeats,
      lastUpdated;

  final int minutes;

  @override
  State<AssociationCountsWidget> createState() =>
      _AssociationCountsWidgetState();
}

class _AssociationCountsWidgetState extends State<AssociationCountsWidget> {
  final mm = ' 🔆🔆🔆🔆🔆🔆 AssociationCountsWidget: 😡';
  bool busy = false;

  late StreamSubscription<DispatchRecord> _subscription;

  @override
  void initState() {
    super.initState();
    _listen();
    _handleData();
    startTimer();
  }

  AssociationCounts? associationCounts;
  late Timer timer;
  int totalPassengers = 0;
 String? date;
  void _listen() async {
    _subscription = streamBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered dispatch for ${event.vehicleReg}');
      if (mounted) {
        _handleData();
      }
    });
  }

  void startTimer() {
    pp('$mm ........ startTimer: tick every ${widget.minutes} minutes');

    date = DateTime.now().toUtc().subtract(Duration(minutes: widget.minutes)).toIso8601String();
    timer = Timer.periodic(Duration(minutes: widget.minutes), (timer) {
      pp('$mm ........ timer tick: ${timer.tick} ... call _handleData ...');
      _handleData();
    });
  }

  Future<void> _handleData() async {
    pp('$mm _handleData ............................ '
        'getting association counts ... widget.minutes: ${widget.minutes}');
    date = DateTime.now().toUtc().subtract(Duration(minutes: widget.minutes)).toIso8601String();

    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      associationCounts = await networkHandler.getAssociationCounts(
          user!.associationId!, date!);
    } catch (e) {
      pp(e);
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
                        color: widget.color == null
                            ? Colors.black54
                            : widget.color!,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            children: [
                              gapH16,
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    widget.operationsSummary,
                                    style: myTextStyleMediumLargeWithColor(context,
                                        Theme.of(context).primaryColorLight, 20),
                                  ),
                                  gapW32,
                                  IconButton(onPressed: (){
                                    _handleData();
                                  }, icon: Icon(Icons.refresh, color: getPrimaryColorLight(context),)),
                                ],
                              ),
                              gapH16,
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                color: widget.color == null
                                    ? Colors.black26
                                    : Colors.red.shade300,
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
                                color: widget.color == null
                                    ? Colors.black26
                                    : Colors.red.shade400,
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
                                          number: associationCounts!
                                              .passengerCounts!,
                                          width: 160),
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 12,
                                color: widget.color == null
                                    ? Colors.black26
                                    : Colors.red.shade500,
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
                                color: widget.color == null
                                    ? Colors.black26
                                    : Colors.red.shade600,
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
                                color: widget.color == null
                                    ? Colors.black26
                                    : Colors.red.shade700,
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
                              date == null? gapW32: Text(
                                date!,
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
