import 'package:flutter/material.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/car_list.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:badges/badges.dart' as bd;
import '../data/generation_request.dart';
import '../data/route.dart' as lib;
import '../data/vehicle.dart' as lib;

class DemoDriver extends StatefulWidget {
  const DemoDriver(
      {Key? key, required this.routes, required this.associationId})
      : super(key: key);
  final List<lib.Route> routes;
  final String associationId;

  @override
  _DemoDriverState createState() => _DemoDriverState();
}

class _DemoDriverState extends State<DemoDriver>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<lib.Vehicle> cars = [];
  bool busy = false;
  static const mm = '🍎🍎🍎🍎 DemoDriver 🍎🍎';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getCars();
  }

  void _getCars() async {
    setState(() {
      busy = true;
    });
    try {
      cars = await networkHandler.getAssociationVehicles(associationId: widget.associationId, refresh: true);
    } catch (e) {
      print(e);
    }
    setState(() {
      busy = false;
    });
  }

  void _startGeneratorForSelectedCar() async {
    if (car == null || route == null) {
      return;
    }
    setState(() {
      busy = true;
    });
    pp('\n$mm ... start generation for car: ${car!.vehicleReg} on route: ${route!.name}..');

    try {
      final startDate = DateTime.now()
          .toUtc()
          .subtract(Duration(minutes: 30))
          .toIso8601String();

      final gen =
          GenerationRequest(route!.routeId!, startDate, [car!.vehicleId!], 5);
      await networkHandler.generateRouteDispatchRecords(gen);
      await networkHandler.generateRouteCommuterRequests(route!.routeId!);

      _showGoodMessage();
      Navigator.of(context).pop();
    } catch (e) {
      pp(e);
      _showError(e);
    }

    if (mounted) {
      setState(() {
        busy = false;
      });
    }
  }

  void _showGoodMessage() {
    showSnackBar(
        backgroundColor: Colors.green.shade700,
        message: 'Demo data generation started OK',
        context: context);
  }

  void _showError(e) {
    showSnackBar(
        backgroundColor: Colors.red.shade700,
        message: 'Error: $e',
        context: context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  lib.Vehicle? car;
  lib.Route? route;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'KasieTransie Demo Driver',
          style: myTextStyleLarge(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(100.0),
            child: Column(
              children: [
                gapH32,
                Text(
                  'Select route and car',
                  style: myTextStyleMediumLarge(context, 24),
                ),
                gapH32,
                car == null
                    ? gapW16
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Selected Car:'),
                          gapW16,
                          Text(
                            '${car!.vehicleReg}',
                            style: myTextStyleMediumLargeWithColor(
                                context, Theme.of(context).primaryColor, 24),
                          ),
                          gapW32,
                          route == null
                              ? gapW32
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Selected Route:'),
                                    gapW16,
                                    Text(
                                      '${route!.name}',
                                      style: myTextStyleMediumLargeWithColor(
                                          context,
                                          Theme.of(context).primaryColorLight,
                                          16),
                                    ),
                                  ],
                                ),
                        ],
                      ),
                gapH16,
                gapH32,
                car != null && route != null
                    ? ElevatedButton(
                        onPressed: () {
                          _startGeneratorForSelectedCar();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text('Start Demo Data Generation'),
                        ))
                    : gapW16,
                gapH16,
                Expanded(
                    child: Row(
                  children: [
                    SizedBox(width: (width/2),
                      child: RouteList(
                          onRoutePicked: (r) {
                            setState(() {
                              route = r;
                            });
                          },
                          routes: widget.routes),
                    ),
                    gapW16,
                    SizedBox(
                      width: (width/3),
                      child: CarList(
                          onCarPicked: (c) {
                            setState(() {
                              car = c;
                            });
                          },),
                    )
                  ],
                ))
              ],
            ),
          ),
          busy
              ? Positioned(
                  child: Center(child: TimerWidget(title: 'Loading cars ...')))
              : gapH16,
        ],
      ),
    ));
  }
}


class RouteList extends StatelessWidget {
  const RouteList(
      {super.key, required this.onRoutePicked, required this.routes});

  final Function(lib.Route) onRoutePicked;
  final List<lib.Route> routes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: routes.length,
        itemBuilder: (ctx, index) {
          final route = routes.elementAt(index);
          return GestureDetector(
            onTap: () {
              onRoutePicked(route);
            },
            child: Card(
              shape: getDefaultRoundedBorder(),
              elevation: 8,
              child: ListTile(
                leading: Icon(
                  Icons.roundabout_right,
                  color: Theme.of(context).primaryColor,
                ),
                title: Text(
                  '${route.name}',
                  style: myTextStyleMedium(context),
                ),
              ),
            ),
          );
        });
  }
}
