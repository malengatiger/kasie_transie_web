import 'dart:async';
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:kasie_transie_web/data/route_bag.dart';
import 'package:kasie_transie_web/maps/cluster_maps/toggle.dart';
import 'package:kasie_transie_web/network.dart';
import '../../blocs/stream_bloc.dart';
import '../../data/ambassador_passenger_count.dart';
import '../../data/association_bag.dart';
import '../../data/commuter_request.dart';
import '../../data/route.dart' as lib;

import '../../data/dispatch_record.dart';
import '../../data/vehicle_arrival.dart';
import '../../data/vehicle_departure.dart';
import '../../data/vehicle_heartbeat.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';
import '../../utils/prefs.dart';
import 'cluster_covers.dart';

class DispatchAndCommuterRequestClusterMap extends StatefulWidget {
  const DispatchAndCommuterRequestClusterMap(
      {Key? key,
      required this.date,
      required this.routeBags})
      : super(key: key);


  final List<RouteBag> routeBags;
  final String date;
  // final List<Route> routes;

  @override
  DispatchAndCommuterRequestClusterMapState createState() => DispatchAndCommuterRequestClusterMapState();
}

class DispatchAndCommuterRequestClusterMapState extends State<DispatchAndCommuterRequestClusterMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();
  final mm = '🌀🌀🌀🌀🌀🌀DispatchAndCommuterRequestClusterMap 🌀🌀';

  var dispatches = <DispatchRecord>[];
  var requests = <CommuterRequest>[];
  var heartbeats = <VehicleHeartbeat>[];
  var arrivals = <VehicleArrival>[];
  var departures = <VehicleDeparture>[];
  var passengerCounts = <AmbassadorPassengerCount>[];
  //
  late StreamSubscription<AmbassadorPassengerCount> passengerSub;
  late StreamSubscription<DispatchRecord> dispatchSub;
  late StreamSubscription<CommuterRequest> requestSub;
  late StreamSubscription<VehicleHeartbeat> heartbeatSub;
  late StreamSubscription<VehicleArrival> arrivalsSub;
  late StreamSubscription<VehicleDeparture> departureSub;

  List<DispatchRecordCover> dispatchRecordCovers = [];
  List<CommuterRequestCover> commuterRequestCovers = [];

  Set<Marker> markers = {};
  Set<Marker> markers2 = {};

  late ClusterManager clusterManager;
  late ClusterManager clusterManager2;

  final CameraPosition _parisCameraPosition =
      const CameraPosition(target: LatLng(-27.856613, 25.352222), zoom: 14.0);

  bool busy = false;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    clusterManager = _initClusterManager();
    clusterManager2 = _initClusterManager2();

    super.initState();
    _listen();
    _getAssociationBag();
    _startTimer();
  }
  AssociationBag? bag;
  void _getAssociationBag() async {
    pp('$mm ... _getAssociationBag ....');
    setState(() {
      busy = true;
    });
    try {
      var ass = await prefs.getUser();
      bag = await networkHandler.getAssociationBag(ass!.associationId!, widget.date, true);
      _buildCovers();
    } catch (e) {
      pp(e);
      showSnackBar(message: 'Error: $e', context: context);
    }

    setState(() {
      busy = false;
    });
  }

  late Timer timer;
  void _startTimer() {
    pp('$mm ... _startTimer ....');

    timer = Timer.periodic(Duration(minutes: 600), (timer) {
      pp('$mm ... timer tick: ${timer.tick}  .... after 600 minutes');
      _getAssociationBag();
    });
  }
  void _buildCovers() {

    for (var dr in bag!.dispatchRecords) {
        dispatchRecordCovers.add(DispatchRecordCover(
            latLng: LatLng(dr.position!.coordinates.last, dr.position!.coordinates.first),
            dispatchRecord: dr));
      }
    pp('$mm _buildCovers: ......................... dispatchRecordCovers .... ${E.redDot} ${dispatchRecordCovers.length}');

    for (var cr in bag!.commuterRequests) {
      commuterRequestCovers.add(CommuterRequestCover(
          latLng: LatLng(cr.currentPosition!.coordinates.last, cr.currentPosition!.coordinates.first),
          request: cr));
    }
    pp('$mm _buildCovers: ......................... commuterRequestCovers .... ${E.redDot} ${commuterRequestCovers.length}');

  }
  void _listen() async {
    pp('\n\n$mm ... listening to FCM topics .......................... ');

    dispatchSub = streamBloc.dispatchStream.listen((event) async {
      pp('$mm ... dispatchStream delivered a dispatch record \t '
          '${E.appleGreen} ${event.vehicleReg} ${event.landmarkName} ${E.blueDot} date:  ${event.created}');
      dispatchRecordCovers.add(DispatchRecordCover(
          latLng: LatLng(event.position!.coordinates.last,
              event.position!.coordinates.first),
          dispatchRecord: event));
      if (mounted) {
        await _zoomToStart(LatLng(event.position!.coordinates.last, event.position!.coordinates.first));
        setState(() {});
      }
    });
    requestSub = streamBloc.commuterRequestStreamStream.listen((event) async {
      pp('$mm ... commuterRequestStreamStream delivered a request \t ${E.appleRed} '
          '${event.routeLandmarkName} ${E.blueDot} date:  ${event.dateRequested}');

      requests.add(event);
      commuterRequestCovers.add(CommuterRequestCover(
          latLng: LatLng(event.currentPosition!.coordinates.last,
              event.currentPosition!.coordinates.first),
          request: event));
      if (mounted) {
        await _zoomToStart(LatLng(event.currentPosition!.coordinates.last, event.currentPosition!.coordinates.first));
        setState(() {});
      }
    });
    // heartbeatSub = fcmBloc.heartbeatStreamStream.listen((event) {
    //   pp('$mm ... heartbeatStreamStream delivered a heartbeat \t '
    //       '${E.appleRed} ${event.vehicleReg} ${E.blueDot} date:  ${event.created}');
    //
    //   heartbeats.add(event);
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  @override
  void dispose() {
    dispatchSub.cancel();
    requestSub.cancel();
    _controller.dispose();
    super.dispose();
  }

  ClusterManager<ClusterItem> _initClusterManager() {
    pp('$mm ......... _initClusterManager, ${E.appleRed} items: ${dispatchRecordCovers.length}');
    clusterManager = ClusterManager<DispatchRecordCover>(
        dispatchRecordCovers, _updateMarkers,
        markerBuilder: _markerBuilder);

    return clusterManager;
  }

  ClusterManager<ClusterItem> _initClusterManager2() {
    pp('$mm ......... _initClusterManager2, ${E.appleRed} items: ${commuterRequestCovers.length}');
    clusterManager2 = ClusterManager<CommuterRequestCover>(
        commuterRequestCovers, _updateMarkers2,
        markerBuilder: _markerBuilder2);

    return clusterManager2;
  }

  Future<void> _updateMarkers(Set<Marker> p1) async {
    // pp('$mm ... updateMarkers ... ${p1.length} markers');
    markers = p1;
    markers.addAll(await _buildRouteLandmarks());

    setState(() {});
  }

  Future<void> _updateMarkers2(Set<Marker> p1) async {
    // pp('$mm ... updateMarkers ... ${p1.length} markers');
    markers2 = p1;
    markers2.addAll(await _buildRouteLandmarks());

    setState(() {});
  }

  Future<Marker> Function(Cluster<DispatchRecordCover>) get _markerBuilder =>
      (cluster) async {

        var mSize = 128;
        mSize = _getRequestSize(cluster, mSize);
        var text = cluster.isMultiple ? cluster.count.toString() : "1";
        final ic = await getMarkerBitmap(
          mSize.toInt(),
          text: text,
          color: 'teal',
          borderColor: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 20,
        );
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            pp('$mm ---- cluster? ${E.redDot} $cluster');
            final list = <DispatchRecord>[];
            for (var p in cluster.items) {
              list.add(p.dispatchRecord);
            }
            list.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
            for (var p in list) {
              pp('$mm ... DispatchRecordCover - cluster item: ${E.appleRed} '
                  '${p.vehicleReg} ${p.landmarkName}'
                  '${E.leaf} route: ${p.routeName} date: ${getFormattedDateLong(p.created!)}');
            }
          },
          icon: ic,
        );
      };

  Future<Marker> Function(Cluster<CommuterRequestCover>) get _markerBuilder2 =>
      (cluster) async {
        var mSize = 100;
        mSize = _getSize(cluster, mSize);
        // var size = cluster.isMultiple ? 125.0 : 75.0;
        var text = cluster.isMultiple ? cluster.count.toString() : "1";
        final ic = await getMarkerBitmap(
          mSize.toInt(),
          text: text,
          color: 'pink',
          borderColor: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 20,
        );
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            pp('$mm ---- cluster? ${E.redDot} $cluster');
            final list = <CommuterRequest>[];
            for (var p in cluster.items) {
              list.add(p.request);
            }
            for (var p in list) {
              pp('$mm ... CommuterRequest - cluster item: ${E.appleRed} '
                  '${getFormattedDateLong(p.dateRequested!)} roue: ${p.routeName}'
                  '${E.leaf} ');
            }
          },
          icon: ic,
        );
      };

  int _getSize(Cluster<CommuterRequestCover> cluster, int mSize) {
    if (cluster.items.length > 100) {
      mSize = 128;
    } else if (cluster.items.length > 50) {
      mSize = 80;
    } else if (cluster.items.length > 30) {
      mSize = 72;
    }
    return mSize;
  }
  int _getRequestSize(Cluster<DispatchRecordCover> cluster, int mSize) {
    if (cluster.items.length > 100) {
      mSize = 128;
    } else if (cluster.items.length > 50) {
      mSize = 80;
    } else if (cluster.items.length > 30) {
      mSize = 72;
    }
    return mSize;
  }

  bool hybrid = true;
  final Set<Polyline> _polyLines = {};

  Future _zoomToStart(LatLng latLng) async {

    var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
    final GoogleMapController controller = await _googleMapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
  }

  Future<void> _buildRoutes() async {
    for (var bag in widget.routeBags) {
      final latLngs = <LatLng>[];
      final rps = bag.routePoints;
      for (var rp in rps) {
        latLngs.add(LatLng(
            rp.position!.coordinates.last, rp.position!.coordinates.first));
      }
      _polyLines.add(Polyline(
          polylineId: PolylineId('${bag.route!.routeId}'),
          color: getColor(bag.route!.color!),
          consumeTapEvents: true,
          points: latLngs,
          onTap: () {
            pp('$mm ... route tapped: ${bag.route!.name}');
            showToast(
                duration: const Duration(seconds: 3),
                backgroundColor: Theme.of(context).primaryColorLight,
                padding: 20.0,
                textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900),
                message: '${bag.route!.name}',
                context: context);
          }));
    }
    await _buildRouteLandmarks();

    if (widget.routeBags.isNotEmpty) {
      final rt = widget.routeBags.first.routeLandmarks.first;

       _zoomToStart(LatLng(rt.position!.coordinates.last, rt.position!.coordinates.first));
    }

    setState(() {});
  }

  Future<Set<Marker>> _buildRouteLandmarks() async {
    Set<Marker> mMarkers = {};
    for (var r in widget.routeBags) {
      final rps = r.routeLandmarks;
      int index = 0;
      for (var mark in rps) {
        final latLng = LatLng(
            mark.position!.coordinates.last, mark.position!.coordinates.first);
        final icon = await getMarkerBitmap(80,
            color: r.route!.color!,
            text: '${mark.index! + 1}',
            borderColor: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w900);
        mMarkers.add(Marker(
            markerId: MarkerId(mark.landmarkId!),
            position: latLng,
            icon: icon,
            infoWindow: InfoWindow(
              title: '${mark.landmarkName}',
              snippet: '${mark.routeName}',
            )));
        index++;
      }
      pp('$mm $index landmarks added for route: ${r.route!.name}');
    }
    return mMarkers;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.airport_shuttle,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              'Dispatches and Commuter Requests',
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 20),
            ),
          ],
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Start Time: ',
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.date,
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            )),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _parisCameraPosition,
            buildingsEnabled: true,
            mapType: hybrid ? MapType.hybrid : MapType.normal,
            markers: markers..addAll(markers2),
            polylines: _polyLines,
            onCameraMove: (pos) {
              clusterManager.onCameraMove(pos);
              clusterManager2.onCameraMove(pos);
            },
            onCameraIdle: (){
              clusterManager.updateMap();
              clusterManager2.updateMap();
            },
            onMapCreated: (GoogleMapController cont) async {
              pp('$mm .......... onMapCreated ...........');
              _googleMapController.complete(cont);
              clusterManager.setMapId(cont.mapId);
              clusterManager.setItems(dispatchRecordCovers);

              clusterManager2.setMapId(cont.mapId);
              clusterManager2.setItems(commuterRequestCovers);
              await _buildRoutes();
            },
          ),
          Positioned(
            right: 12,
            top: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: HybridToggle(
                  onHybrid: () {
                    setState(() {
                      hybrid = true;
                    });
                  },
                  onNormal: () {
                    setState(() {
                      hybrid = false;
                    });
                  },
                  hybrid: hybrid),
            ),
          ),
        ],
      ),
    ));
  }
}
