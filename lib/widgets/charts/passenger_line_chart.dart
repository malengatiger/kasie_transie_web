import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/passenger_aggregate.dart';
import 'package:kasie_transie_web/local_storage/storage_manager.dart';
import 'package:kasie_transie_web/maps/association_route_maps.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../../blocs/stream_bloc.dart';
import '../../data/vehicle_heartbeat.dart';
import '../../data/route.dart' as lib;

import '../../network.dart';
import '../../utils/emojis.dart';
import '../../utils/prefs.dart';
import 'my_chart_data.dart';

class PassengerLineChart extends StatefulWidget {
  const PassengerLineChart({
    super.key,
    required this.numberOfDays,
  });

  final int numberOfDays;
  @override
  State<PassengerLineChart> createState() =>
      _PassengerLineChartState();
}

class _PassengerLineChartState extends State<PassengerLineChart> {
  List<Color> gradientColors = [
    Colors.blue,
    Colors.amber,
  ];
  static const mm = '🔵🔵🔵🔵🔵 PassengerLineChart 🔵🔵';
  List<FlSpot> spots = [];
  String? date;
  int days = 7;
  bool busy = false;
  List<VehicleHeartbeat> heartbeats = [];
  List<PassengerAggregate> timeSeriesResults = [];
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  int counter = 0;

  @override
  void initState() {
    super.initState();
    pp('$mm ....... initState ... will listen to stream to get active data ...');
    days = widget.numberOfDays;
    _listen();
    _getRoutes();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listen() async {

  }

  Future _getRoutes() async {
    pp('$mm ... getting routes ....');
    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      routes = await storageManager.getRoutes();
      pp('$mm ... getting routes .... ${routes.length} found in cache');

      if (routes.isEmpty) {
        final bags = await networkHandler.getRouteBags(associationId: user!.associationId!, refresh: true);
        for (var value in bags) {
          routes.add(value.route!);
        }
        pp('$mm ... getting routes .... ${routes.length} found in backend');
      }
    } catch (e, s) {
      pp('$e $s');
    }
    setState(() {
      busy = false;
    });
  }

  void _buildSpots(lib.Route route) async {
    pp('$mm _buildSpots ...................');
    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      final date = DateTime.now().toUtc().subtract(Duration(days: days));
      timeSeriesResults =
          await networkHandler.getPassengerTimeSeries(associationId:
              user!.associationId!,
              routeId: route.routeId!,
              startDate: date.toIso8601String());
      timeSeriesResults.sort((a,b) => b.id!.compareTo(a.id!));
      pp('$mm _buildSpots .. association 🔵🔵 timeSeries : ${E.appleRed} ${timeSeriesResults.length}');
      pp('$mm ... _buildSpots: ......... to create graph spots, timeSeriesResults: ${timeSeriesResults.length}');
      //limit to 24 series points and fill empty spots ...
      int count = 0;
      var delta = 0;
      spots.clear();
      if (timeSeriesResults.length == 0) {
        pp('$mm ... _buildSpots: timeSeriesResults no mas! is zero!');
      } else {
        for (var i = 0; i < 24; i++) {
          spots.add( FlSpot(i.toDouble(), 0.0));
        }
        for (var r in timeSeriesResults) {
          pp('$mm ... aggregate: ${r.toJson()}');
          var fHour = r.id?.substring(11);
          var hour = fHour?.substring(0,2);
          pp('$mm ... aggregate: fHour: $fHour  hour: $hour');

          spots[int.parse(hour!)] = FlSpot(double.parse(hour), r.totalPassengers!.toDouble());
        }
        for (var s in spots) {
          pp('$mm ... x: ${s.x} y: ${s.y}');
        }
      }
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  List<lib.Route> routes = [];

  void _onRoutePicked(lib.Route route) async {
    pp('$mm route picked : ${route.name}');
    _buildSpots(route);
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: busy
              ? TimerWidget(title: 'Loading Passengers ...')
              : SizedBox(
                  height: 800,
                  width: 800,
                  child: Column(
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          'Passengers',
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 24),
                        ),
                      ),
                      Text(
                        'Data shown is for the last 24 hours',
                        style: myTextStyleSmall(context),
                      ),
                      gapH16,
                      RouteDropDown(routes: routes, onRoutePicked: (route){
                        _onRoutePicked(route);
                      }),
                      gapH16,
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.70,
                          child: spots.isEmpty
                              ? Center(
                                  child: Text(
                                    'No Current Passengers',
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
