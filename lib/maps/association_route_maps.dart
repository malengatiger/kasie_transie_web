import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_web/email_auth_signin.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/drop_down_widgets.dart';

import '../data/association_bag.dart';
import '../data/route.dart' as lib;
import '../data/route_bag.dart';
import '../data/route_landmark.dart';
import '../data/route_point.dart';
import '../data/user.dart' as lib;
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../widgets/timer_widget.dart';

class AssociationRouteMaps extends StatefulWidget {
  const AssociationRouteMaps({
    Key? key,
    this.latitude,
    this.longitude,
    this.radiusInMetres,
  }) : super(key: key);

  final double? latitude, longitude, radiusInMetres;

  @override
  AssociationRouteMapsState createState() => AssociationRouteMapsState();
}

class AssociationRouteMapsState extends State<AssociationRouteMaps> {
  static const defaultZoom = 14.0;
  final Completer<GoogleMapController> _mapController = Completer();

  final CameraPosition _myCurrentCameraPosition = const CameraPosition(
    target: LatLng(-25.8656, 27.7564),
    zoom: defaultZoom,
  );
  static const mm = '😡😡😡😡😡😡😡 AssociationRouteMaps: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = true;
  final Set<Marker> _markers = HashSet();
  final Set<Circle> _circles = HashSet();
  final Set<Polyline> _polyLines = {};

  final List<RoutePoint> rpList = [];
  List<RoutePoint> existingRoutePoints = [];

  List<LatLng>? polylinePoints;
  Color color = Colors.black;
  var routeLandmarks = <RouteLandmark>[];
  int landmarkIndex = 0;
  var routes = <lib.Route>[];
  bool showSignIn = false;
  late StreamSubscription<AssociationBag> assocBagStreamSubscription;

  @override
  void initState() {
    super.initState();
    _control();
  }

  lib.User? user;
  AssociationBag? bag;

  void _control() async {
    user = await prefs.getUser();
    if (user == null) {
      setState(() {
        showSignIn = true;
      });
      return;
    }
    _listen();
    _startTimer();
  }
  void _listen() {
    pp('$mm will listen to associationBagStream  ${E.heartBlue} ...');

    assocBagStreamSubscription = networkHandler.associationBagStream.listen((event) {
      pp('$mm associationBagStream delivered event ... ${E.heartBlue} ');
      bag = event;
      if (mounted) {
        setState(() {

        });
      }
    });
  }

  void _getRouteBags() async {
    user = await prefs.getUser();
    if (user == null) {
      return;
    }
    pp('\n\n$mm ............. getting route data ..........');

    setState(() {
      busy = true;
    });

    try {
      pp('$mm ... calling network.getRouteBags ....!');

      bags = await networkHandler.getRouteBags(
          associationId: user!.associationId!);
      pp('$mm .... route bags: ${bags.length}, if > 0, we are in business!!');
      // for (var value in bags) {
      //   pp('$mm route: ${value.route!.name} 🔵🔵'
      //       '\n🔵 routeLandmarks: ${value.routeLandmarks.length}'
      //       '\n🔵 routePoints: ${value.routePoints.length}'
      //       '\n🔵 routeCities: ${value.routeCities.length}');
      // }
      _filter();
    } catch (e) {
      pp(e.toString());
    }
    setState(() {
      busy = false;
    });
  }

  int intervalMinutes = 2;
  int minutes = 30;

  void _startTimer() async {
    final startDate = DateTime.now()
        .toUtc()
        .subtract(Duration(minutes: minutes))
        .toIso8601String();

    networkHandler.startTimer(
        associationId: user!.associationId!,
        startDate: startDate,
        intervalMinutes: intervalMinutes);
  }

  void _printRoutes() {
    int cnt = 1;
    for (var r in routes) {
      pp('$mm route #:$cnt ${E.appleRed} ${r.name}');
      cnt++;
    }
  }

  var bags = <RouteBag>[];

  Future<void> _filter() async {
    routesPicked.clear();
    for (var bag in bags) {
      if (bag.routeLandmarks.isNotEmpty) {
        routesPicked.add(bag.route!);
      }
    }
    _printRoutes();
    pp('$mm ... routes filtered: ${routesPicked.length}');
    _buildAssociationMap();
  }

  var routesPicked = <lib.Route>[];

  @override
  void dispose() {
    super.dispose();
  }

  Color newColor = Colors.black;
  String? stringColor;

  Future<void> _zoomToBeginningOfRoute(lib.Route route) async {
    if (route.routeStartEnd != null) {
      final latLng = LatLng(
          route.routeStartEnd!.startCityPosition!.coordinates.last,
          route.routeStartEnd!.startCityPosition!.coordinates.first);
      var cameraPos = CameraPosition(target: latLng, zoom: 12.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  int index = 0;
  final numberMarkers = <BitmapDescriptor>[];

  Future<void> _addLandmarks(
      {required List<RouteLandmark> routeLandmarks,
      required List<BitmapDescriptor> icons,
      required String color}) async {
    // pp('$mm .......... _addLandmarks ....... .');
    routeLandmarks.sort((a, b) => a.index!.compareTo(b.index!));

    int landmarkIndex = 0;
    for (var routeLandmark in routeLandmarks) {
      _markers.add(Marker(
          markerId: MarkerId(routeLandmark.landmarkId!),
          icon: icons.elementAt(landmarkIndex),
          position: LatLng(routeLandmark.position!.coordinates[1],
              routeLandmark.position!.coordinates[0]),
          infoWindow: InfoWindow(
              title: routeLandmark.landmarkName,
              snippet: '🍎Part of ${routeLandmark.routeName}')));
      landmarkIndex++;
    }
  }

  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  var widthIndex = 0;

  void _addPolyLine(List<RoutePoint> points, Color color) {
    // pp('$mm .......... _addPolyLine ....... points: ${points.length}.');
    var mPoints = <LatLng>[];
    points.sort((a, b) => a.index!.compareTo(b.index!));
    for (var rp in points) {
      mPoints.add(LatLng(
          rp.position!.coordinates.last, rp.position!.coordinates.first));
    }
    int width = (widthIndex + 1) * 6;
    if (width > 12) {
      width = 10;
    }
    var polyLine = Polyline(
        color: color,
        width: 6,
        points: mPoints,
        onTap: () {
          pp('$mm ... polyLine tapped; route: ${points.first.routeName}');
          if (mounted) {
            showToast(message: '${points.first.routeName}', context: context);
          }
        },
        consumeTapEvents: true,
        polylineId: PolylineId(DateTime.now().toIso8601String()));

    _polyLines.add(polyLine);
    widthIndex++;
  }

  Route? routeSelected;
  final hashMap = HashMap<String, MapBag>();

  List<RouteLandmark> getLandmarks(String routeId) {
    for (var bag in bags) {
      if (bag.route!.routeId! == routeId) {
        return bag.routeLandmarks;
      }
    }
    return [];
  }

  List<RoutePoint> getRoutePoints(String routeId) {
    for (var bag in bags) {
      if (bag.route!.routeId! == routeId) {
        return bag.routePoints;
      }
    }
    return [];
  }

  void _buildAssociationMap() async {
    pp('\n\n\n$mm ... _buildAssociationMap: routes: ${routesPicked.length}');
    _markers.clear();
    _polyLines.clear();
    var count = 0;
    for (var route in routesPicked) {
      final points = getRoutePoints(route.routeId!);
      final marks = getLandmarks(route.routeId!);
      final icons = <BitmapDescriptor>[];
      await _getIcons(marks, route, icons);
      _addPolyLine(points, getColor(route.color!));
      _addLandmarks(routeLandmarks: marks, icons: icons, color: route.color!);
      count++;
      pp('$mm ...route has been added: ${E.blueDot} #$count ${E.blueDot} route: ${route.name} ');
    }

    if (routesPicked.isNotEmpty) {
      _zoomToBeginningOfRoute(routesPicked.first);
    }
  }

  Future<void> _getIcons(List<RouteLandmark> marks, lib.Route route,
      List<BitmapDescriptor> icons) async {
    for (var i = 0; i < marks.length; i++) {
      final icon = await getMarkerBitmap(80,
          text: '${i + 1}',
          color: route.color!,
          fontSize: 14,
          fontWeight: FontWeight.w900);
      icons.add(icon);
    }
  }

  int distanceInKM = 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Association Route Map ',
                style: myTextStyleLarge(context),
              ),
              gapW32,
              ControlWidget(minutes: minutes, onMinutesPicked: (min) {
                setState(() {
                  minutes = min;
                });
                _startTimer();
              }),
            ],
          ),
        ),
        key: _key,
        body: Stack(children: [
          GoogleMap(
            mapType: isHybrid ? MapType.hybrid : MapType.normal,
            myLocationEnabled: true,
            markers: _markers,
            circles: _circles,
            polylines: _polyLines,
            initialCameraPosition: _myCurrentCameraPosition,
            onTap: (latLng) {
              pp('$mm .......... on map tapped : $latLng .');
            },
            onMapCreated: (GoogleMapController controller) {
              pp('$mm .......... on onMapCreated .....');
              _mapController.complete(controller);
              _getRouteBags();
            },
          ),
          Positioned(
              right: 12,
              top: 120,
              child: Container(
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IconButton(
                      onPressed: () {
                        setState(() {
                          isHybrid = !isHybrid;
                        });
                      },
                      icon: Icon(
                        Icons.album_outlined,
                        color: isHybrid ? Colors.yellow : Colors.white,
                      )),
                ),
              )),
          showSignIn
              ? Positioned(
                  left: 400,
                  right: 400,
                  bottom: 200,
                  top: 200,
                  child: Center(
                    child: EmailAuthSignin(onGoodSignIn: (mUser) {
                      pp('$mm ......... sign in COOL, will get route data ${E.leaf}');
                      setState(() {
                        showSignIn = false;
                        user = mUser;
                      });
                      _getRouteBags();
                      _control();
                    }, onSignInError: () {
                      pp('$mm sign in error ${E.redDot}');
                      if (mounted) {
                        showSnackBar(
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(color: Colors.white),
                            message: 'Sign In failed: $e',
                            context: context);
                      }
                    }),
                  ))
              : gapW4,
          busy
              ? Positioned(
                  left: 400,
                  right: 400,
                  bottom: 200,
                  top: 200,
                  child: Center(
                    child: Card(
                      shape: getDefaultRoundedBorder(),
                      elevation: 16,
                      child: const TimerWidget(
                        title: 'Loading Taxi Route data',
                        subTitle: 'This may take a minute or two',
                      ),
                    ),
                  ))
              : gapW4,
        ]));
  }
}

class ControlWidget extends StatelessWidget {
  const ControlWidget(
      {super.key, required this.minutes, required this.onMinutesPicked});

  final int minutes;
  final Function(int) onMinutesPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Number of Minutes'),
        gapW32,
        Text(
          '$minutes',
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 20),
        ),
        gapW32,
        NumberDropDown(
          onNumberPicked: (number) {
            var m = number;
            if (m == 0) {
              m = 30;
            } else {
              m = number;
            }
            onMinutesPicked(m);
          },
          color: Theme.of(context).primaryColorLight,
          count: 12,
          fontSize: 16,
          multiplier: 30,
        ),
      ],
    );
  }
}

class MapBag {
  late lib.Route route;
  List<RoutePoint> routePoints = [];
  List<RouteLandmark> routeLandmarks = [];
  List<BitmapDescriptor> landmarkIcons = [];

  MapBag(this.route, this.routePoints, this.routeLandmarks, this.landmarkIcons);
}
