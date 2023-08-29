import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kasie_transie_web/blocs/fcm_bloc.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/dispatch_record.dart';
import 'package:kasie_transie_web/data/location_request.dart';
import 'package:kasie_transie_web/data/vehicle_arrival.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/email_auth_signin.dart';
import 'package:kasie_transie_web/l10n/strings_helper.dart';
import 'package:kasie_transie_web/maps/association_route_maps.dart';
import 'package:kasie_transie_web/maps/cluster_maps/cluster_covers.dart';
import 'package:kasie_transie_web/maps/cluster_maps/commuter_cluster_map.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/navigator_utils.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/association_bag_widget.dart';
import 'package:kasie_transie_web/widgets/color_grid.dart';
import 'package:kasie_transie_web/widgets/drop_down_widgets.dart';
import 'package:kasie_transie_web/widgets/live_activities.dart';

import '../blocs/theme_bloc.dart';
import '../data/association_bag.dart';
import '../data/location_response.dart';
import '../data/route.dart' as lib;
import '../data/route_bag.dart';
import '../data/route_landmark.dart';
import '../data/route_point.dart';
import '../data/user.dart' as lib;
import '../utils/color_and_locale.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import '../widgets/demo_driver.dart';
import '../widgets/language_list.dart';
import '../widgets/timer_widget.dart';
import 'cluster_maps/dispatch_cluster_map.dart';

class GetToken {
  static Future<String> getToken() async {
    String associationId =
        '2f3faebd-6159-4b03-9857-9dad6d9a82ac'; // Replace with actual associationId
    // Call the JavaScript function to send associationId and get token
    pp('GetToken: calling Javascript: 🔴 🔴 🔴 🔴 ..... sending associationId: 💪 $associationId 💪');
    final user = await prefs.getUser();
    if (user != null) {
      js.context.callMethod('fetchTokenAndSend', [associationId, user.userId]);
    }

    return "We good, Boss!";
  }

  static void _handleTokenFromJs(String token) {
    // Handle the FCM token obtained from JavaScript
    pp('GetToken:  🔵 🔵 🔵 🔵 FCM Token from JavaScript: $token');
  }
}

class AssociationRouteOperations extends StatefulWidget {
  const AssociationRouteOperations({
    Key? key,
    this.latitude,
    this.longitude,
    this.radiusInMetres,
  }) : super(key: key);

  final double? latitude, longitude, radiusInMetres;

  @override
  AssociationRouteOperationsState createState() => AssociationRouteOperationsState();
}

class AssociationRouteOperationsState extends State<AssociationRouteOperations> {
  static const defaultZoom = 14.0;
  final Completer<GoogleMapController> _mapController = Completer();

  final CameraPosition _myCurrentCameraPosition = const CameraPosition(
    target: LatLng(-25.8656, 27.7564),
    zoom: defaultZoom,
  );
  static const mm = '😡😡😡😡😡😡😡 AssociationRouteOperations: 💪 ';
  final _key = GlobalKey<ScaffoldState>();
  bool busy = false;
  bool isHybrid = false;
  final Set<Marker> _markers = HashSet();
  final Set<Marker> _heartbeatMarkers = HashSet();

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
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  late StreamSubscription<VehicleArrival> arrivalStreamSubscription;
  late StreamSubscription<VehicleDeparture> departureStreamSubscription;
  late StreamSubscription<DispatchRecord> dispatchStreamSubscription;
  late StreamSubscription<AmbassadorPassengerCount> passengerStreamSubscription;
  late StreamSubscription<CommuterRequest> commuterStreamSubscription;
  late StreamSubscription<LocationRequest> locationRequestStreamSubscription;
  late StreamSubscription<LocationResponse> locationResponseStreamSubscription;

  String? webToken;

  String assRouteOperations = 'assRouteOperations';
  String changeColor = 'changeColor';
  String changeLanguage = 'changeLanguage';
  String commutersText = 'commuters';
  String arrivalsText = 'arrivals';
  String departuresText = 'departures';
  String dispatchesText = 'dispatches';
  String timeLastUpdate = 'timeLastUpdate';
  String emailAddress = 'emailAddress';
  String password = 'password';
  String kasieSignIn = 'kasieSignIn';
  String sendSignIn = 'sendSignIn';

  @override
  void initState() {
    super.initState();
    _control();
  }

  StringsHelper? stringsHelper;

  Future _setTexts() async {
    stringsHelper = await StringsHelper.getTranslatedTexts();
    setState(() {});
  }

  @override
  void dispose() {
    assocBagStreamSubscription.cancel();
    heartbeatStreamSubscription.cancel();
    arrivalStreamSubscription.cancel();
    departureStreamSubscription.cancel();
    dispatchStreamSubscription.cancel();
    passengerStreamSubscription.cancel();
    commuterStreamSubscription.cancel();
    locationRequestStreamSubscription.cancel();
    locationResponseStreamSubscription.cancel();

    super.dispose();
  }

  lib.User? user;
  AssociationBag? bag;

  void _control() async {
    user = await prefs.getUser();
    _getColors();
    await _setTexts();
    if (user == null) {
      setState(() {
        showSignIn = true;
      });
      return;
    } else {
      GetToken.getToken();
      fcmBloc.initialize();
      _setupMessagingListeners();
    }
    _listen();
    _startTimer();
  }

  Future _setupMessagingListeners() async {
    pp('$mm ... _setting up FCM Messaging Listeners to get messages via Javascript ...');
    // Set up the service worker to listen for FCM messages
    if (window.navigator.serviceWorker != null) {
      final sw = await window.navigator.serviceWorker!
          .register('firebase-messaging-sw.js');
      pp('$mm Service Worker registered with scope: ${sw.scope} - '
          '${E.heartBlue} activated: ${sw.active?.state}');
      // Listen for messages from the service worker
      sw.addEventListener('message', (event) {
        final dynamic message = jsonDecode(event as String);
        pp('$mm Received message from service worker: ${E.leaf} $message ${E.leaf}');
        // Handle the FCM message here
      });
      //

      // Notify the service worker that the Dart app is ready
      // window.navigator.serviceWorker!.ready.then((registration) {
      //   registration.active!.postMessage('Dart app is ready');
      // });
      window.navigator.serviceWorker!.ready.then((registration) {
        pp(' ... registration.active!.state: ${registration.active!.state}');
        registration.active!.postMessage('register');
      });

      //listen for fcm messages
      window.onMessage.listen((event) {
        final dynamic message = event.data;
        pp('$mm .......................................${E.redDot}'
            ' message received, will be shipped to FCMBloc');
        final m = message['mData']['data'];
        fcmBloc.processFCMessage(convertDynamicMap(m));
      });
    } else {
      pp('$mm ... _setupMessagingListeners NOT set up. ${E.redDot} ${E.redDot} ');
      return;
    }
    pp('$mm Service Worker set up to receive messages ${E.leaf}${E.leaf}${E.leaf}');
  }

  Map<String, dynamic> convertDynamicMap(Map<dynamic, dynamic> dynamicMap) {
    final convertedMap = <String, dynamic>{};
    dynamicMap.forEach((key, value) {
      if (key is String) {
        convertedMap[key] = value;
      } else {
        // Handle key conversion if needed
        convertedMap[key.toString()] = value;
      }
    });
    return convertedMap;
  }

  List<VehicleHeartbeat> heartbeats = [];

  void _listen() {
    pp('$mm will listen to fcm messaging ... '
        '${E.heartBlue} ${E.heartBlue} ${E.heartBlue} ...');

    assocBagStreamSubscription =
        networkHandler.associationBagStream.listen((event) async {
      pp('$mm associationBagStream delivered event ... ${E.heartBlue} ');
      bag = event;
      _showBag = true;
      final d = DateTime.now().toLocal().toIso8601String();
      final cl = await prefs.getColorAndLocale();
      date = await getFmtDate(d, cl.locale, context);
      if (mounted) {
        setState(() {});
      }
    });

    heartbeatStreamSubscription = fcmBloc.heartbeatStreamStream.listen((event) {
      pp('$mm heartbeatStreamStream delivered event ... ${E.heartBlue} ');
      heartbeats.add(event);
      _addHeartbeatToHash(event);
    });

    arrivalStreamSubscription = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    departureStreamSubscription =
        fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm ... vehicleDepartureStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    dispatchStreamSubscription = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    passengerStreamSubscription = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    locationResponseStreamSubscription =
        fcmBloc.locationResponseStream.listen((event) {
      pp('$mm ... locationResponseStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });

    locationRequestStreamSubscription =
        fcmBloc.locationRequestStream.listen((event) {
      pp('$mm ... locationRequestStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<VehicleHeartbeat> heartbeatsToDisplay = [];

  void _addHeartbeatToHash(VehicleHeartbeat heartbeat) {
    var hash = HashMap<String, VehicleHeartbeat>();
    for (var value in heartbeats) {
      hash[value.vehicleId!] = value;
    }
    heartbeatsToDisplay.clear();
    heartbeatsToDisplay = hash.values.toList();
    _putHeartbeatsOnMap(heartbeat);
  }

  void _putHeartbeatsOnMap(VehicleHeartbeat latestHeartbeat) async {
    pp('$mm ... _putHeartbeatsOnMap ... ${heartbeatsToDisplay.length}');
    _heartbeatMarkers.clear();
    for (var hb in heartbeatsToDisplay) {
      pp('$mm ... putting ${hb.vehicleReg} on map ... ${hb.position!.coordinates}');
      final icon = await getTaxiMapIcon(
          iconSize: 108,
          text: ' ${hb.vehicleReg}',
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
          path: 'assets/car2.png');

      _heartbeatMarkers.add(Marker(
          markerId: MarkerId('${hb.vehicleId}'),
          position: LatLng(
              hb.position!.coordinates.last, hb.position!.coordinates.first),
          icon: icon,
          zIndex: 4,
          infoWindow: InfoWindow(
              title: '${hb.vehicleReg}',
              snippet: getFormattedDateLong(hb.created!))));

      _zoomToHeartbeat(latestHeartbeat);
      setState(() {});
    }
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
      for (var value in bags) {
        pp('$mm route: ${value.route!.name} 🔵🔵'
            '\n🔵 routeLandmarks: ${value.routeLandmarks.length}'
            '\n🔵 routePoints: ${value.routePoints.length}'
            '\n🔵 routeCities: ${value.routeCities.length}');
      }
      final cl = await prefs.getColorAndLocale();
      date = await getFmtDate(
          DateTime.now().toIso8601String(), cl.locale, context);
      _filter();

    } catch (e) {
      pp(e.toString());
      showToast(
          backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          padding: 24,
          duration: Duration(seconds: 5),
          message: stringsHelper!.serverUnreachable, context: context);
    }
    setState(() {
      busy = false;
    });
  }

  int intervalSeconds = 60;
  int minutes = 30;
  bool _showBag = false;

  void _startTimer() async {
    final startDate = DateTime.now()
        .toUtc()
        .subtract(Duration(minutes: minutes))
        .toIso8601String();

    networkHandler.startTimer(
        associationId: user!.associationId!,
        startDate: startDate,
        intervalSeconds: intervalSeconds);
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

  Color newColor = Colors.black;
  String? stringColor;

  Future<void> _zoomToBeginningOfRoute(lib.Route route) async {
    if (route.routeStartEnd != null) {
      final latLng = LatLng(
          route.routeStartEnd!.startCityPosition!.coordinates!.last,
          route.routeStartEnd!.startCityPosition!.coordinates!.first);
      var cameraPos = CameraPosition(target: latLng, zoom: 12.0);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
      setState(() {});
    }
  }

  Future<void> _zoomToHeartbeat(VehicleHeartbeat hb) async {
    final latLng =
        LatLng(hb.position!.coordinates!.last, hb.position!.coordinates!.first);
    var cameraPos = CameraPosition(target: latLng, zoom: 16.0);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
    setState(() {});
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
          position: LatLng(routeLandmark.position!.coordinates![1],
              routeLandmark.position!.coordinates![0]),
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
          rp.position!.coordinates!.last, rp.position!.coordinates!.first));
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

  void onColorChosen(ColorFromTheme colorFromTheme) async {
    pp('$mm onColorChosen, index: ${colorFromTheme.themeIndex}');
    colorAndLocale.themeIndex = colorFromTheme.themeIndex;
    prefs.saveColorAndLocale(colorAndLocale);
    themeBloc.changeColorAndLocale(colorAndLocale);
    setState(() {
      this.colorFromTheme = colorFromTheme;
    });
  }

  void onLanguageChosen(LangBag langBag) async {
    pp('$mm onLanguageChosen, index: ${langBag.language}');
    colorAndLocale.locale = langBag.locale;
    prefs.saveColorAndLocale(colorAndLocale);
    themeBloc.changeColorAndLocale(colorAndLocale);
    await _setTexts();
    setState(() {
      _refresh = !_refresh;
    });
  }

  int distanceInKM = 100;
  String date = 'just now';
  bool _showColorSheet = false;
  bool _showLanguage = false;
  bool _refresh = false;
  bool _showDemoDriver = false;
  var commuterRequestCovers = <CommuterRequestCover>[];
  var dispatchCovers = <DispatchRecordCover>[];

  void _navigateToCommuterMap() {
    if (bag != null) {
      for (var value in bag!.commuterRequests) {
        commuterRequestCovers.add(CommuterRequestCover(
            latLng: LatLng(value.currentPosition!.coordinates.last,
                value.currentPosition!.coordinates.first),
            request: value));
      }

      pp('$mm ... navigating with ${commuterRequestCovers.length} commuter requests');
      navigateWithScale(
          CommuterClusterMap(
              commuterRequestCovers: commuterRequestCovers,
              date: date,
              routes: routes),
          context);
    }
  }
  
  void _navigateToDemoDriver() async {
    navigateWithScale(DemoDriver(routes: routesPicked, associationId: user!.associationId!,), context);
  }

  void _navigateToRouteMaps() async {
    navigateWithScale(AssociationRouteMaps(), context);
  }

  void _navigateToDispatchAndCommuterRequestClusterMap() {
    dispatchCovers.clear();
    if (bag != null) {
      for (var value in bag!.dispatchRecords) {
        dispatchCovers.add(DispatchRecordCover(
            latLng: LatLng(value.position!.coordinates.last,
                value.position!.coordinates.first),
            dispatchRecord: value));
      }

      pp('$mm ... navigating with ${commuterRequestCovers.length} commuter requests');
      navigateWithScale(DispatchAndCommuterRequestClusterMap(
        routeBags: bags,
        date: date,
      ), context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              stringsHelper == null
                  ? gapW32
                  : Text(
                      stringsHelper!.assRouteOperations,
                      style: myTextStyleMediumLargeWithColor(
                          context, Theme.of(context).primaryColor, 32),
                    ),
              gapW32,
              ControlWidget(
                minutes: minutes,
                onMinutesPicked: (min) {
                  setState(() {
                    minutes = min;
                  });
                  _startTimer();
                },
                numberInMinutes:
                    stringsHelper == null ? '' : stringsHelper!.numberMinutes,
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  _navigateToDispatchAndCommuterRequestClusterMap();
                },
                icon: Icon(
                  Icons.back_hand_sharp,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _navigateToRouteMaps();
                },
                icon: Icon(
                  Icons.map,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  _navigateToCommuterMap();
                },
                icon: Icon(
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _showColorSheet = true;
                  });
                },
                icon: Icon(
                  Icons.color_lens_outlined,
                  color: Theme.of(context).primaryColor,
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _showLanguage = true;
                  });
                },
                icon: Icon(
                  Icons.language,
                  color: Theme.of(context).primaryColor,
                )),
          ],
        ),
        key: _key,
        drawer: Drawer(
          elevation: 12,
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                ),
                child: SizedBox(
                  height: 340,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/gio.png',
                        height: 80,
                        width: 80,
                      ),
                      SizedBox(
                          child: Text(
                        'Kasie Transie',
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme.of(context).primaryColorLight, 28),
                      )),
                    ],
                  ),
                ),
              ),
              gapH32,
              gapH32,
              const ListTile(
                leading: Icon(Icons.airport_shuttle),
                title: Text('Dispatch Records'),
              ),
              gapH32,
              const ListTile(
                leading: Icon(Icons.airport_shuttle),
                title: Text('Vehicle Arrivals'),
              ),
              gapH32,
              const ListTile(
                leading: Icon(Icons.airport_shuttle),
                title: Text('Passengers'),
              ),
              gapH32,
              const ListTile(
                leading: Icon(Icons.airport_shuttle),
                title: Text('Vehicle Departures'),
              ),
              gapH32,
              const ListTile(
                leading: Icon(Icons.airport_shuttle),
                title: Text('Vehicle Heartbeats'),
              ),
            ],
          ),
        ),
        body: Stack(children: [
          GoogleMap(
            mapType: isHybrid ? MapType.hybrid : MapType.normal,
            myLocationEnabled: true,
            markers: _markers..addAll(_heartbeatMarkers),
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
              child: LiveDisplay(
                  width: 800, height: 100,
            cutoffDate:
                DateTime.now().toUtc().subtract(Duration(minutes: minutes)),
          )),
          Positioned(
              right: 0,
              top: 0,
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
          Positioned(
              right: 0,
              top: 60,
              child: Container(
                color: Colors.black45,
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: IconButton(
                      onPressed: () {
                        _navigateToDemoDriver();
                      },
                      icon: Icon(
                        Icons.add_alert_sharp,
                        color: isHybrid ? Colors.white : Colors.amber,
                      )),
                ),
              )),

          showSignIn
              ? Positioned(
                  child: Center(
                  child: SizedBox(
                    height: 400,
                    child: EmailAuthSignin(
                        refresh: _refresh,
                        onGoodSignIn: (mUser) {
                          pp('$mm ......... sign in COOL, will get route data ${E.leaf}');
                          setState(() {
                            showSignIn = false;
                            user = mUser;
                          });
                          _getRouteBags();
                          _control();
                        },
                        onSignInError: () {
                          pp('$mm sign in error ${E.redDot}');
                          if (mounted) {
                            showSnackBar(
                                backgroundColor: Colors.red,
                                textStyle: const TextStyle(color: Colors.white),
                                message: 'Sign In failed: $e',
                                context: context);
                          }
                        }),
                  ),
                ))
              : gapW4,
          _showBag
              ? Positioned(
                  right: 8,
                  top: 32,
                  child: stringsHelper == null
                      ? gapW32
                      : AssociationBagWidget(
                          bag: bag!,
                          width: 360,
                          date: date,
                          operationsSummary: stringsHelper!.operationsSummary,
                          dispatches: stringsHelper!.dispatchesText,
                          passengers: stringsHelper!.passengers,
                          arrivals: stringsHelper!.arrivalsText,
                          departures: stringsHelper!.departuresText,
                          heartbeats: stringsHelper!.heartbeats,
                          lastUpdated: stringsHelper!.timeLastUpdate))
              : gapW32,
          _showColorSheet
              ? Positioned(
                  right: 12,
                  top: 12,
                  child: ColorGrid(
                    colors: colors,
                    onColorChosen: (clr) {
                      onColorChosen(clr);
                    },
                    onClose: () {
                      setState(() {
                        _showColorSheet = false;
                      });
                    },
                    changeColor: stringsHelper!.changeColor,
                  ))
              : gapW8,
          _showLanguage
              ? Positioned(
                  right: 12,
                  top: 12,
                  child: LanguageList(onClose: () {
                    setState(() {
                      _showLanguage = false;
                    });
                  }, onLanguageChosen: (lang) {
                    pp('$mm language chosen: $lang');
                    onLanguageChosen(lang);
                  }))
              : gapW32,
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
                      child: stringsHelper == null
                          ? gapW32
                          : TimerWidget(
                              title: stringsHelper!.dataLoader,
                              subTitle: stringsHelper!.thisMayTakeMinutes,
                            ),
                    ),
                  ))
              : gapW4,
        ]));
  }

  List<ColorFromTheme> colors = [];
  List<LangBag> languageBags = [];
  late ColorAndLocale colorAndLocale;
  ColorFromTheme? colorFromTheme;

  void _getColors() async {
    //todo - switch dark & light
    setState(() {
      busy = true;
    });
    try {
      colors = SchemeUtil.getDarkThemeColors();
      colorAndLocale = await prefs.getColorAndLocale();
      colorFromTheme = SchemeUtil.getColorFromTheme(colorAndLocale);
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }
}

class ControlWidget extends StatelessWidget {
  const ControlWidget(
      {super.key,
      required this.minutes,
      required this.onMinutesPicked,
      required this.numberInMinutes});

  final int minutes;
  final String numberInMinutes;
  final Function(int) onMinutesPicked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(numberInMinutes,
            style: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 12)),
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
