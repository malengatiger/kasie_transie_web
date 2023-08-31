import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../../blocs/stream_bloc.dart';
import '../../data/association_heartbeat_aggregation_result.dart';
import '../../data/vehicle_heartbeat.dart';
import '../../network.dart';
import '../../utils/emojis.dart';
import '../../utils/prefs.dart';
import 'my_chart_data.dart';

class AssociationHeartbeatChart extends StatefulWidget {
  const AssociationHeartbeatChart({
    super.key,
  });

  @override
  State<AssociationHeartbeatChart> createState() =>
      _AssociationHeartbeatChartState();
}

class _AssociationHeartbeatChartState extends State<AssociationHeartbeatChart> {
  List<Color> gradientColors = [
    Colors.blue,
    Colors.amber,
  ];
  static const mm = '🔵🔵🔵🔵🔵 AssociationHeartbeatChart 🔵🔵';
  List<FlSpot> spots = [];
  String? date;
  int days = 7;
  bool busy = false;
  List<VehicleHeartbeat> heartbeats = [];
  List<AssociationHeartbeatAggregationResult> timeSeriesResults = [];
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  int counter = 0;
  @override
  void initState() {
    super.initState();
    pp('$mm ....... initState ... will listen to stream to get active data ...');
    _listen();
    _buildSpots();
  }

  @override
  void dispose() {
    super.dispose();


  }
  void _listen() async {
    heartbeatStreamSubscription =
        streamBloc.heartbeatStreamStream.listen((event) {
          pp('$mm heartbeatStreamStream delivered event ... 😡😡😡  '
              '${event.created} - vehicleHeartbeatId: ${event.vehicleHeartbeatId} -  ${event.vehicleReg}');
          heartbeats.add(event);
          int rem = heartbeats.length % 3;
          if (rem == 0) {
            _buildSpots();
          }
        });
  }

  void _buildSpots() async {
    pp('$mm _buildSpots ...................');
    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      final date = DateTime.now().toUtc().subtract(Duration(days: 1));
      timeSeriesResults =
          await networkHandler.getAssociationHeartbeatTimeSeries(
              user!.associationId!, date.toIso8601String());
      pp('$mm _buildSpots .. association 🔵🔵 timeSeries : ${E.appleRed} ${timeSeriesResults.length}');
      pp('$mm ... _buildSpots: ... to create graph spots ... ${timeSeriesResults.length}');
      //limit to 24 series points and fill empty spots ...
      int count = 0;
      var delta = 0;
      spots.clear();
      if (timeSeriesResults.length < 24) {
        delta = 24 - timeSeriesResults.length;
        pp('$mm ... _buildSpots: ... timeSeriesResults: ${timeSeriesResults.length} delta: $delta');
        for (var i = 0; i < delta; i++) {
          spots.add(FlSpot(0.0 + i.toDouble(), 0.0));
        }
      }
      pp('$mm ... _buildSpots: ... timeSeriesResults: ${timeSeriesResults.length} spots: ${spots.length}');
      if (timeSeriesResults.length > 24) {
        delta = timeSeriesResults.length - 24;
        final list = timeSeriesResults
            .getRange(delta, timeSeriesResults.length - 1)
            .toList();
        for (var value in list) {
          setSpot(value, count);
          count++;
          if (count > 24) {
            break;
          }
        }
        pp('$mm ... _buildSpots: ... spots #2: ${spots.length}');
      } else {
        for (var i = 0; i < timeSeriesResults.length; i++) {
          setSpot(timeSeriesResults.elementAt(i), i+delta);
          count++;
        }
      }
      pp('$mm ... _buildSpots: ... spots #3: ${spots.length}');
      for (var spot in spots) {
        pp('$mm ... final spot ${E.appleGreen} x: ${spot.x} y: ${spot.y}');
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  void setSpot(AssociationHeartbeatAggregationResult value, int index) {
    final spot = FlSpot(index.toDouble(), value.total!.toDouble());
    spots.add(spot);
    pp('$mm Heartbeat Aggregate Time Series ${E.redDot} '
        'month: ${value.id!.month} day: ${value.id!.day} hour: ${value.id!.hour!} ${E.pear} total: ${value.total}');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: busy
              ? TimerWidget(title: 'Loading Heartbeats ...')
              : SizedBox(
                  height: 600,
                  width: 800,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Vehicle Heartbeats',
                          style: myTextStyleMediumLargeWithColor(context,
                          Theme.of(context).primaryColor, 24),
                        ),
                      ),
                      Text('Data shown is for the last 24 hours', style: myTextStyleSmall(context),),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.70,
                          child: spots.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Current Heartbeats',
                                    style: myTextStyleMediumLargeWithColor(
                                        context,
                                        Theme.of(context).primaryColor,
                                        24),
                                  ),
                                )
                              : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LineChart(
                                    MyChartData.getData(
                                        colors: [Colors.blue, Colors.indigo],
                                        spots: spots),
                                    curve: Curves.bounceInOut,
                                    duration: Duration(milliseconds: 1500),
                                  ),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        busy ? TimerWidget(title: 'Loading chart data ...') : gapW32,
      ],
    );
  }
}
