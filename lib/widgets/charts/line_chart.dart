import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../../data/association_heartbeat_aggregation_result.dart';
import '../../network.dart';
import '../../utils/emojis.dart';
import 'my_chart_data.dart';

class AssociationHeartbeatChart extends StatefulWidget {
  const AssociationHeartbeatChart({super.key});

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
  List<AssociationHeartbeatAggregationResult> results = [];
  List<FlSpot> spots = [];
  String? date;
  int days = 7;
  bool busy = false;

  void initState() {
    super.initState();
    pp('$mm ....... initState ...');
    _getData();
  }

  Future _getData() async {
    pp('$mm _getData: ${E.appleRed} getting heartbeat aggregates ....');

    setState(() {
      busy = true;
    });
    try {
      final user = await prefs.getUser();
      date = DateTime.now()
          .subtract(Duration(days: days))
          .toUtc()
          .toIso8601String();
      results = await networkHandler.getAssociationHeartbeatTimeSeries(
          user!.associationId!, date!);

      results.sort((a, b) => a.id!.hour!.compareTo(b.id!.hour!));

      if (results.isNotEmpty) {
        _buildSpots();
      } else {
        if (mounted) {
          showSnackBar(message: 'No data for the chart', context: context);
        }
      }
    } catch (e) {
      pp(e);
      showSnackBar(message: '$e', context: context);
    }
    setState(() {
      busy = false;
    });
  }

  void _buildSpots() {
    pp('$mm ... _buildSpots: ... to create graph spots ... ${results.length}');

    results = results.reversed.toList();
    int count = 0;
    for (var value in results) {
      spots.add(FlSpot((value.id!.hour!).toDouble(), value.total!.toDouble()));
      pp('$mm Heartbeat Aggregate Time Series ${E.redDot} '
          '... hour: ${value.id!.hour!} ${E.pear} total: ${value.total}');
      count++;
      if (count > 11) {
        break;
      }
    }
    spots = spots.reversed.toList();
    List<FlSpot> newSpots = [];
    int index = 0;
    for (var value1 in spots) {
      final m = FlSpot(index.toDouble(), value1.y);
      newSpots.add(m);
      pp('$mm new spot reversed: ${E.appleRed} x: ${m.x} y: ${m.y}');
      index++;
    }
    spots = newSpots;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: SizedBox(height: 600, width: 800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Vehicle Heartbeats', style: myTextStyleLarge(context),),
                ),
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1.70,
                    child: spots.isEmpty
                        ? gapW32
                        : LineChart(
                            MyChartData.getData(
                                colors: [Colors.teal, Colors.blue], spots: spots),
                            curve: Curves.bounceInOut,
                            duration: Duration(milliseconds: 1500),
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

