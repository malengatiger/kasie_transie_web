// import 'dart:async';
// import 'dart:collection';
// import 'dart:ui';
//
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
// import 'package:kasie_transie_library/bloc/list_api_dog.dart';
// import 'package:kasie_transie_library/isolates/routes_isolate.dart';
// import 'package:kasie_transie_library/maps/cluster_maps/toggle.dart';
// import 'package:kasie_transie_library/utils/emojis.dart';
// import 'package:kasie_transie_library/utils/functions.dart';
// import 'package:kasie_transie_library/data/schemas.dart' as lib;
//
// import '../../messaging/fcm_bloc.dart';
// import 'cluster_covers.dart';
//
// class DispatchClusterMap extends StatefulWidget {
//   const DispatchClusterMap(
//       {Key? key,
//       required this.dispatchRecordCovers,
//       required this.date,
//       required this.commuterRequestCovers})
//       : super(key: key);
//
//   final List<DispatchRecordCover> dispatchRecordCovers;
//   final List<CommuterRequestCover> commuterRequestCovers;
//
//   final String date;
//   // final List<lib.Route> routes;
//
//   @override
//   DispatchClusterMapState createState() => DispatchClusterMapState();
// }
//
// class DispatchClusterMapState extends State<DispatchClusterMap>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   final Completer<GoogleMapController> _googleMapController = Completer();
//   final mm = '🍐🍐🍐🍐DispatchClusterMap 🍐🍐';
//
//   var dispatches = <lib.DispatchRecord>[];
//   var requests = <lib.CommuterRequest>[];
//   var heartbeats = <lib.VehicleHeartbeat>[];
//   var arrivals = <lib.VehicleArrival>[];
//   var departures = <lib.VehicleDeparture>[];
//   var passengerCounts = <lib.AmbassadorPassengerCount>[];
//   //
//   late StreamSubscription<lib.AmbassadorPassengerCount> passengerSub;
//   late StreamSubscription<lib.DispatchRecord> dispatchSub;
//   late StreamSubscription<lib.CommuterRequest> requestSub;
//   late StreamSubscription<lib.VehicleHeartbeat> heartbeatSub;
//   late StreamSubscription<lib.VehicleArrival> arrivalsSub;
//   late StreamSubscription<lib.VehicleDeparture> departureSub;
//
//   var routes = <lib.Route>[];
//   Set<Marker> markers = {};
//   Set<Marker> markers2 = {};
//
//   late ClusterManager clusterManager;
//   late ClusterManager clusterManager2;
//
//   final CameraPosition _parisCameraPosition =
//       const CameraPosition(target: LatLng(-27.856613, 25.352222), zoom: 14.0);
//
//   @override
//   void initState() {
//     _controller = AnimationController(vsync: this);
//     clusterManager = _initClusterManager();
//     clusterManager2 = _initClusterManager2();
//
//     super.initState();
//     _listen();
//     _getRoutes();
//   }
//
//   void _listen() async {
//     pp('\n\n$mm ... listening to FCM topics .......................... ');
//
//     // arrivalsSub = fcmBloc.vehicleArrivalStream.listen((event) {
//     //   pp('$mm ... vehicleArrivalStream delivered an arrival \t${E.appleRed} '
//     //       '${event.vehicleReg} at ${event.landmarkName} ${E.blueDot} date: ${event.created}');
//     //
//     //   arrivals.add(event);
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     // departureSub = fcmBloc.vehicleDepartureStream.listen((event) {
//     //   pp('$mm ... vehicleDepartureStream delivered an arrival \t${E.appleRed} '
//     //       '${event.vehicleReg} at ${event.landmarkName} ${E.blueDot} date: ${event.created}');
//     //
//     //   departures.add(event);
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     // passengerSub = fcmBloc.passengerCountStream.listen((event) {
//     //   pp('$mm ... passengerCountStream delivered a count \t ${E.pear} ${event.vehicleReg} '
//     //       '${E.blueDot} date:  ${event.created}');
//     //
//     //   pp('$mm ... PassengerCountCover - cluster item: ${E.appleRed} ${event.vehicleReg}'
//     //       '\n${E.leaf} passengersIn: ${event.passengersIn} '
//     //       '\n${E.leaf} passengersOut: ${event.passengersOut} '
//     //       '\n${E.leaf} currentPassengers: ${event.currentPassengers}');
//     //   passengerCounts.add(event);
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     dispatchSub = fcmBloc.dispatchStream.listen((event) {
//       pp('$mm ... dispatchStream delivered a dispatch record \t '
//           '${E.appleGreen} ${event.vehicleReg} ${event.landmarkName} ${E.blueDot} date:  ${event.created}');
//       widget.dispatchRecordCovers.add(DispatchRecordCover(
//           latLng: LatLng(event.position!.coordinates.last,
//               event.position!.coordinates.first),
//           dispatchRecord: event));
//       if (mounted) {
//         setState(() {});
//       }
//     });
//     // requestSub = fcmBloc.commuterRequestStreamStream.listen((event) {
//     //   pp('$mm ... commuterRequestStreamStream delivered a request \t ${E.appleRed} '
//     //       '${event.routeLandmarkName} ${E.blueDot} date:  ${event.dateRequested}');
//     //
//     //   requests.add(event);
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//     // heartbeatSub = fcmBloc.heartbeatStreamStream.listen((event) {
//     //   pp('$mm ... heartbeatStreamStream delivered a heartbeat \t '
//     //       '${E.appleRed} ${event.vehicleReg} ${E.blueDot} date:  ${event.created}');
//     //
//     //   heartbeats.add(event);
//     //   if (mounted) {
//     //     setState(() {});
//     //   }
//     // });
//   }
//
//   @override
//   void dispose() {
//     // passengerSub.cancel();
//     dispatchSub.cancel();
//     // requestSub.cancel();
//     // heartbeatSub.cancel();
//     // arrivalsSub.cancel();
//     // departureSub.cancel();
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future _getRoutes() async {
//     final m = HashMap<String, String>();
//     for (var value in widget.dispatchRecordCovers) {
//       m[value.dispatchRecord.routeId!] = value.dispatchRecord.routeName!;
//     }
//     for (var value1 in m.keys.toList()) {
//       final route = await listApiDog.getRoute(value1);
//       routes.add(route!);
//     }
//     pp('${routes.length} routes filtered');
//     setState(() {});
//   }
//
//   ClusterManager<ClusterItem> _initClusterManager() {
//     pp('$mm ......... _initClusterManager, ${E.appleRed} items: ${widget.dispatchRecordCovers.length}');
//     clusterManager = ClusterManager<DispatchRecordCover>(
//         widget.dispatchRecordCovers, _updateMarkers,
//         markerBuilder: _markerBuilder);
//
//     return clusterManager;
//   }
//
//   ClusterManager<ClusterItem> _initClusterManager2() {
//     pp('$mm ......... _initClusterManager2, ${E.appleRed} items: ${widget.commuterRequestCovers.length}');
//     clusterManager2 = ClusterManager<CommuterRequestCover>(
//         widget.commuterRequestCovers, _updateMarkers2,
//         markerBuilder: _markerBuilder2);
//
//     return clusterManager2;
//   }
//
//   Future<void> _updateMarkers(Set<Marker> p1) async {
//     // pp('$mm ... updateMarkers ... ${p1.length} markers');
//     markers = p1;
//     markers.addAll(await _buildRouteLandmarks());
//
//     setState(() {});
//   }
//
//   Future<void> _updateMarkers2(Set<Marker> p1) async {
//     // pp('$mm ... updateMarkers ... ${p1.length} markers');
//     markers2 = p1;
//     markers2.addAll(await _buildRouteLandmarks());
//
//     setState(() {});
//   }
//
//   Future<Marker> Function(Cluster<DispatchRecordCover>) get _markerBuilder =>
//       (cluster) async {
//
//         var mSize = 100;
//         mSize = _getRequestSize(cluster, mSize);
//         var size = cluster.isMultiple ? 125.0 : 75.0;
//         var text = cluster.isMultiple ? cluster.count.toString() : "1";
//         final ic = await getMarkerBitmap(
//           mSize.toInt(),
//           text: text,
//           color: 'teal',
//           borderColor: Colors.white,
//           fontWeight: FontWeight.normal,
//           fontSize: mSize / 3,
//         );
//         return Marker(
//           markerId: MarkerId(cluster.getId()),
//           position: cluster.location,
//           onTap: () {
//             pp('$mm ---- cluster? ${E.redDot} $cluster');
//             final list = <lib.DispatchRecord>[];
//             for (var p in cluster.items) {
//               list.add(p.dispatchRecord);
//             }
//             list.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
//             for (var p in list) {
//               pp('$mm ... DispatchRecordCover - cluster item: ${E.appleRed} '
//                   '${p.vehicleReg} ${p.landmarkName}'
//                   '${E.leaf} route: ${p.routeName} date: ${getFormattedDateLong(p.created!)}');
//             }
//           },
//           icon: ic,
//         );
//       };
//
//   Future<Marker> Function(Cluster<CommuterRequestCover>) get _markerBuilder2 =>
//       (cluster) async {
//         var mSize = 100;
//         mSize = _getSize(cluster, mSize);
//         // var size = cluster.isMultiple ? 125.0 : 75.0;
//         var text = cluster.isMultiple ? cluster.count.toString() : "1";
//         final ic = await getMarkerBitmap(
//           mSize.toInt(),
//           text: text,
//           color: 'pink',
//           borderColor: Colors.white,
//           fontWeight: FontWeight.normal,
//           fontSize: mSize / 3,
//         );
//         return Marker(
//           markerId: MarkerId(cluster.getId()),
//           position: cluster.location,
//           onTap: () {
//             pp('$mm ---- cluster? ${E.redDot} $cluster');
//             final list = <lib.CommuterRequest>[];
//             for (var p in cluster.items) {
//               list.add(p.request);
//             }
//             for (var p in list) {
//               pp('$mm ... CommuterRequest - cluster item: ${E.appleRed} '
//                   '${getFormattedDateLong(p.dateRequested!)} roue: ${p.routeName}'
//                   '${E.leaf} ');
//             }
//           },
//           icon: ic,
//         );
//       };
//
//   int _getSize(Cluster<CommuterRequestCover> cluster, int mSize) {
//     if (cluster.items.length > 100) {
//       mSize = 128;
//     } else if (cluster.items.length > 50) {
//       mSize = 80;
//     } else if (cluster.items.length > 30) {
//       mSize = 72;
//     }
//     return mSize;
//   }
//   int _getRequestSize(Cluster<DispatchRecordCover> cluster, int mSize) {
//     if (cluster.items.length > 100) {
//       mSize = 128;
//     } else if (cluster.items.length > 50) {
//       mSize = 80;
//     } else if (cluster.items.length > 30) {
//       mSize = 72;
//     }
//     return mSize;
//   }
//
//   bool hybrid = true;
//   final Set<Polyline> _polyLines = {};
//
//   void _zoomToStart() async {
//     final pc = widget.dispatchRecordCovers.first;
//     final latLng = pc.latLng;
//     var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
//     final GoogleMapController controller = await _googleMapController.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
//   }
//
//   Future<void> _buildRoutes() async {
//     for (var r in routes) {
//       final latLngs = <LatLng>[];
//       final rps = await routesIsolate.getRoutePoints(r.routeId!, false);
//       for (var rp in rps) {
//         latLngs.add(LatLng(
//             rp.position!.coordinates.last, rp.position!.coordinates.first));
//       }
//       _polyLines.add(Polyline(
//           polylineId: PolylineId('${r.routeId}'),
//           color: getColor(r.color!),
//           consumeTapEvents: true,
//           points: latLngs,
//           onTap: () {
//             pp('$mm ... route tapped: ${r.name}');
//             showToast(
//                 duration: const Duration(seconds: 3),
//                 backgroundColor: Theme.of(context).primaryColorLight,
//                 padding: 20.0,
//                 textStyle: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.w900),
//                 message: '${r.name}',
//                 context: context);
//           }));
//     }
//     await _buildRouteLandmarks();
//     setState(() {});
//   }
//
//   Future<Set<Marker>> _buildRouteLandmarks() async {
//     Set<Marker> mMarkers = {};
//     for (var r in routes) {
//       final rps = await routesIsolate.getRouteLandmarksCached(r.routeId!);
//       int index = 0;
//       for (var mark in rps) {
//         final latLng = LatLng(
//             mark.position!.coordinates.last, mark.position!.coordinates.first);
//         final icon = await getMarkerBitmap(72,
//             color: r.color!,
//             text: '${mark.index! + 1}',
//             borderColor: Colors.black,
//             fontSize: 32,
//             fontWeight: FontWeight.w900);
//         mMarkers.add(Marker(
//             markerId: MarkerId(mark.landmarkId!),
//             position: latLng,
//             icon: icon,
//             infoWindow: InfoWindow(
//               title: '${mark.landmarkName}',
//               snippet: '${mark.routeName}',
//             )));
//         index++;
//       }
//       pp('$mm $index landmarks added for route: ${r.name}');
//     }
//     return mMarkers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Scaffold(
//       appBar: AppBar(
//         title: Row(
//           children: [
//             Icon(
//               Icons.airport_shuttle,
//               color: Theme.of(context).primaryColor,
//             ),
//             const SizedBox(
//               width: 16,
//             ),
//             Text(
//               'Dispatch Records Map',
//               style: myTextStyleMediumLargeWithColor(
//                   context, Theme.of(context).primaryColor, 20),
//             ),
//           ],
//         ),
//         bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(32),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Start Time: ',
//                       style: myTextStyleTiny(context),
//                     ),
//                     const SizedBox(width: 12),
//                     Text(
//                       widget.date,
//                       style: myTextStyleSmall(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 16,
//                 )
//               ],
//             )),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: _parisCameraPosition,
//             buildingsEnabled: true,
//             mapType: hybrid ? MapType.hybrid : MapType.normal,
//             markers: markers..addAll(markers2),
//             polylines: _polyLines,
//             onCameraMove: (pos) {
//               clusterManager.onCameraMove(pos);
//               clusterManager2.onCameraMove(pos);
//             },
//             onCameraIdle: (){
//               clusterManager.updateMap();
//               clusterManager2.updateMap();
//             },
//             onMapCreated: (GoogleMapController cont) async {
//               pp('$mm .......... onMapCreated ...........');
//               _googleMapController.complete(cont);
//               clusterManager.setMapId(cont.mapId);
//               clusterManager.setItems(widget.dispatchRecordCovers);
//
//               clusterManager2.setMapId(cont.mapId);
//               clusterManager2.setItems(widget.commuterRequestCovers);
//               await _buildRoutes();
//               _zoomToStart();
//             },
//           ),
//           Positioned(
//             right: 12,
//             top: 0,
//             child: SizedBox(
//               width: 48,
//               height: 48,
//               child: HybridToggle(
//                   onHybrid: () {
//                     setState(() {
//                       hybrid = true;
//                     });
//                   },
//                   onNormal: () {
//                     setState(() {
//                       hybrid = false;
//                     });
//                   },
//                   hybrid: hybrid),
//             ),
//           ),
//         ],
//       ),
//     ));
//   }
// }
