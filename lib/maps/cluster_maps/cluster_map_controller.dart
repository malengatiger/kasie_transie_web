// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import 'package:badges/badges.dart' as bd;
// import 'package:kasie_transie_web/network.dart';
//
// import '../../data/ambassador_passenger_count.dart';
// import '../../data/association.dart';
// import '../../data/commuter_request.dart';
// import '../../data/dispatch_record.dart';
// import '../../data/route.dart' as lib;
//
// import '../../data/vehicle_arrival.dart';
// import '../../utils/functions.dart';
// import '../../utils/prefs.dart';
// import '../../widgets/drop_down_widgets.dart';
// import 'cluster_covers.dart';
//
// class ClusterMapController extends StatefulWidget {
//   const ClusterMapController({super.key});
//
//   @override
//   State<ClusterMapController> createState() => ClusterMapControllerState();
// }
//
// class ClusterMapControllerState extends State<ClusterMapController> {
//   final mm = '🍐🍐🍐🍐ClusterMapController 🍐🍐';
//
//   var routes = <lib.Route>[];
//   var dispatches = <DispatchRecord>[];
//   var requests = <CommuterRequest>[];
//   var passengerCounts = <AmbassadorPassengerCount>[];
//   var arrivals = <VehicleArrival>[];
//
//   var routeDispatches = <DispatchRecord>[];
//   var routeRequests = <CommuterRequest>[];
//   var routePassengerCounts = <AmbassadorPassengerCount>[];
//   var routeArrivals = <VehicleArrival>[];
//   bool _showDispatches = false;
//   bool _showCommuterRequests = false;
//   bool _showPassengerCounts = false;
//   bool _showArrivals = false;
//
//   int groupValue = 4;
//   lib.Route? route;
//   int hours = 1;
//   bool busy = false;
//   Association? association;
//   String? date;
//
//   @override
//   void initState() {
//     super.initState();
//     _getAssociationRouteData(true);
//   }
//
//
//   void _getAssociationRouteData(bool refresh) async {
//     pp('$mm ... _getAssociationRouteData; refresh: $refresh');
//
//     association = await prefs.getAssociation();
//     date = DateTime.now()
//         .toUtc()
//         .subtract(Duration(hours: hours))
//         .toIso8601String();
//     setState(() {
//       busy = true;
//     });
//     try {
//       final bag = await networkHandler.getAssociationBag(association!.associationId!, date!);
//
//       arrivals = bag!.arrivals;
//       dispatches = bag.dispatchRecords;
//       requests = bag.commuterRequests;
//       passengerCounts = bag.passengerCounts;
//       //
//       _showDispatches = false;
//       _showArrivals = false;
//       _showPassengerCounts = false;
//       _showCommuterRequests = true;
//     } catch (e) {
//       pp(e);
//       if (mounted) {
//         showSnackBar(message: 'We have a problem: $e', context: context);
//       }
//     }
//
//     setState(() {
//       busy = false;
//     });
//   }
//
//   void _getRouteData(bool refresh) async {
//     pp('$mm ... _getRouteData; refresh: $refresh');
//     date = DateTime.now()
//         .toUtc()
//         .subtract(Duration(hours: hours))
//         .toIso8601String();
//     setState(() {
//       busy = true;
//     });
//
//     try {
//       final bag = await networkHandler.getAssociationBag(route!.associationId!, date!);
//       routeDispatches = bag!.dispatchRecords;
//       routePassengerCounts = bag.passengerCounts;
//       routeArrivals = bag.arrivals;
//
//       routeRequests = bag.commuterRequests;
//     } catch (e) {
//       pp(e);
//       if (mounted) {
//         showSnackBar(message: 'We have a problem: $e', context: context);
//       }
//       return;
//     }
//     setState(() {
//       busy = false;
//     });
//     _navigateToRouteMap();
//   }
//
//   void _navigateToRouteMap() async {
//     String mDate = getFormattedDateLong(date!);
//     if (_showPassengerCounts) {
//       final passengerCountCovers = <PassengerCountCover>[];
//       _buildPassengerCovers(passengerCountCovers);
//       if (mounted) {
//         if (passengerCountCovers.isEmpty) {
//           showSnackBar(message: "No data found for map", context: context);
//         } else {
//           // navigateWithScale(
//           //     PassengerCountClusterMap(
//           //       date: mDate,
//           //       passengerCountCovers: passengerCountCovers,
//           //     ),
//           //     context);
//         }
//       }
//     }
//     if (_showDispatches) {
//       final dispatchCovers = <DispatchRecordCover>[];
//       for (var pc in dispatches) {
//         _buildDispatchCovers(pc, dispatchCovers);
//       }
//       if (mounted) {
//         if (dispatchCovers.isEmpty) {
//           showSnackBar(message: "No data found for map", context: context);
//         } else {
//           final covers = _buildRequestCovers();
//         //   navigateWithScale(
//         //       DispatchClusterMap(
//         //         date: mDate,
//         //         dispatchRecordCovers: dispatchCovers,
//         //         commuterRequestCovers: covers,
//         //       ),
//         //       context);
//         // }
//       }
//     }
//
//     if (_showCommuterRequests) {
//       final commuterCovers = <CommuterRequestCover>[];
//       for (var pc in requests) {
//         if (pc.routeId == route!.routeId) {
//           final cover = CommuterRequestCover(
//             request: pc,
//             latLng: LatLng(pc.currentPosition!.coordinates[1],
//                 pc.currentPosition!.coordinates[0]),
//           );
//           commuterCovers.add(cover);
//         }
//       }
//       if (mounted) {
//         if (commuterCovers.isEmpty) {
//           showSnackBar(message: "No data found for map", context: context);
//         } else {
//         //   navigateWithScale(
//         //       CommuterClusterMap(date: mDate,
//         //         commuterRequestCovers: commuterCovers,
//         //       ),
//         //       context);
//         // }
//       }
//     }
//   }
//   List<CommuterRequestCover> _buildRequestCovers() {
//         final requestCovers = <CommuterRequestCover>[];
//         for (var pc in requests) {
//           final cover = CommuterRequestCover(
//             request: pc,
//             latLng: LatLng(
//                 pc.currentPosition!.coordinates[1], pc.currentPosition!.coordinates[0]),
//           );
//           requestCovers.add(cover);
//         }
//         return requestCovers;
//       }
//
//   void _buildPassengerCovers(List<PassengerCountCover> passengerCountCovers) {
//     for (var pc in passengerCounts) {
//       if (pc.routeId == route!.routeId) {
//         final cover = PassengerCountCover(
//           passengerCount: pc,
//           latLng: LatLng(
//               pc.position!.coordinates[1], pc.position!.coordinates[0]),
//         );
//         passengerCountCovers.add(cover);
//       }
//     }
//   }
//
//   void _buildDispatchCovers(DispatchRecord pc, List<DispatchRecordCover> dispatchCovers) {
//     if (pc.routeId == route!.routeId) {
//       final cover = DispatchRecordCover(
//         dispatchRecord: pc,
//         latLng: LatLng(
//             pc.position!.coordinates[1], pc.position!.coordinates[0]),
//       );
//       dispatchCovers.add(cover);
//     }
//   }
//
//   void _navigateToAssociationMap() async {
//     String mDate = getFormattedDateLong(date!);
//
//     if (mounted) {
//       if (_showCommuterRequests) {
//         final commuterCovers = <CommuterRequestCover>[];
//         if (requests.isEmpty) {
//           showSnackBar(message: 'Nothing to show on map', context: context);
//         } else {
//           for (var pc in requests) {
//             final cover = CommuterRequestCover(
//               request: pc,
//               latLng: LatLng(pc.currentPosition!.coordinates[1],
//                   pc.currentPosition!.coordinates[0]),
//             );
//             commuterCovers.add(cover);
//           }
//           if (commuterCovers.isNotEmpty) {
//             // navigateWithScale(
//             //     CommuterClusterMap(
//             //       commuterRequestCovers: commuterCovers, date: mDate,
//             //     ),
//             //     context);
//           } else {
//             showSnackBar(message: 'No data to show for map', context: context);
//           }
//         }
//       }
//       if (_showPassengerCounts) {
//         final passengerCountCovers = <PassengerCountCover>[];
//         if (passengerCounts.isEmpty) {
//           showSnackBar(message: 'Nothing to show on map', context: context);
//         } else {
//           for (var pc in passengerCounts) {
//             final cover = PassengerCountCover(
//               passengerCount: pc,
//               latLng: LatLng(
//                   pc.position!.coordinates[1], pc.position!.coordinates[0]),
//             );
//             passengerCountCovers.add(cover);
//           }
//           // navigateWithScale(
//           //     PassengerCountClusterMap(
//           //       date: mDate,
//           //       passengerCountCovers: passengerCountCovers,
//           //     ),
//           //     context);
//         }
//       }
//       if (_showDispatches) {
//         final dispatchCovers = <DispatchRecordCover>[];
//         if (dispatches.isEmpty) {
//           showSnackBar(message: 'Nothing to show on map', context: context);
//         } else {
//           for (var pc in dispatches) {
//             final cover = DispatchRecordCover(
//               dispatchRecord: pc,
//               latLng: LatLng(
//                   pc.position!.coordinates[1], pc.position!.coordinates[0]),
//             );
//             dispatchCovers.add(cover);
//           }
//           }
//           List<CommuterRequestCover> requestCovers = _buildRequestCovers();
//           // navigateWithScale(
//           //     DispatchClusterMap(
//           //       date: mDate,
//           //       dispatchRecordCovers: dispatchCovers,
//           //       commuterRequestCovers: requestCovers,
//           //     ),
//           //     context);
//         }
//       }
//       if (_showArrivals) {
//         final arrivalCovers = <VehicleArrivalCover>[];
//         if (arrivals.isEmpty) {
//           showSnackBar(message: 'Nothing to show on map', context: context);
//         } else {
//           for (var pc in arrivals) {
//             final cover = VehicleArrivalCover(
//               arrival: pc,
//               latLng: LatLng(
//                   pc.position!.coordinates[1], pc.position!.coordinates[0]),
//             );
//             arrivalCovers.add(cover);
//           }
//           // navigateWithScale(
//           //     ArrivalsClusterMap(
//           //       date: mDate,
//           //       vehicleArrivalsCovers: arrivalCovers,
//           //     ),
//           //     context);
//         }
//       }
//     }
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     var padding = 64.0;
//     final type = getThisDeviceType();
//
//     if (type == 'phone') {
//       padding = 20.0;
//     }
//
//     return SafeArea(
//         child: Scaffold(
//       appBar: AppBar(
//         title: SizedBox(
//           height: 60,
//           child: Column(
//             children: [
//               const SizedBox(
//                 height: 8,
//               ),
//               Text(
//                 'Activities on Map',
//                 style: myTextStyleMediumLargeWithColor(
//                     context, Theme.of(context).primaryColor, 20),
//               ),
//               association == null
//                   ? const SizedBox()
//                   : Text(
//                       '${association!.associationName}',
//                       style: myTextStyleTiny(context),
//                     )
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(12.0),
//             child: Card(
//               shape: getRoundedBorder(radius: 16),
//               elevation: 8,
//               child: Column(mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                    SizedBox(
//                     height: type == 'phone'? 12:48,
//                   ),
//                   busy
//                       ? const SizedBox()
//                       : SizedBox(
//                           width:  type == 'phone'?280:320,
//                           child: ElevatedButton.icon(
//                               style: const ButtonStyle(
//                                 elevation: MaterialStatePropertyAll(12.0),
//                               ),
//                               onPressed: () {
//                                 _navigateToAssociationMap();
//                               },
//                               icon: const Icon(Icons.map),
//                               label: Padding(
//                                 padding: const EdgeInsets.all(12.0),
//                                 child: Text(
//                                   'Map Across Association',
//                                   style: myTextStyleSmallBlack(context),
//                                 ),
//                               )),
//                         ),
//                    SizedBox(
//                     height: type == 'phone'? 4:48,
//                   ),
//                   Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       SizedBox(height:  type == 'phone'?240: 260, width:  type == 'phone'?320: 400, child: Column(
//                         children: [
//                           ListTile(
//                             title: Row(
//                               children: [
//                                 Text(
//                                   'Dispatch Records',
//                                   style: myTextStyleSmall(context),
//                                 ),
//                                 const SizedBox(
//                                   width: 28,
//                                 ),
//                                 bd.Badge(
//                                   badgeStyle: const bd.BadgeStyle(
//                                       elevation: 12,
//                                       badgeColor: Colors.deepOrange,
//                                       padding: EdgeInsets.all(12)),
//                                   badgeContent: Text(
//                                     '${dispatches.length}',
//                                     style: myTextStyleTiny(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             leading: Radio(
//                                 value: 1,
//                                 groupValue: groupValue,
//                                 onChanged: (int? v) {
//                                   pp('$mm ... dispatch record radio changed : $v');
//                                   if (v != null) {
//                                     groupValue = 1;
//                                   }
//                                   setState(() {
//                                     _showDispatches = true;
//                                     _showArrivals = false;
//                                     _showPassengerCounts = false;
//                                     _showCommuterRequests = false;
//                                   });
//                                 }),
//                           ),
//                           ListTile(
//                             title: Row(
//                               children: [
//                                 Text(
//                                   'Vehicle Arrivals',
//                                   style: myTextStyleSmall(context),
//                                 ),
//                                 const SizedBox(
//                                   width: 28,
//                                 ),
//                                 bd.Badge(
//                                   badgeStyle: bd.BadgeStyle(
//                                       elevation: 12,
//                                       badgeColor: Colors.green[800]!,
//                                       padding: const EdgeInsets.all(12)),
//                                   badgeContent: Text(
//                                     '${arrivals.length}',
//                                     style: myTextStyleTiny(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             leading: Radio(
//                                 value: 2,
//                                 groupValue: groupValue,
//                                 onChanged: (int? v) {
//                                   pp('$mm ...  arrivals radio changed : $v');
//                                   if (v != null) {
//                                     groupValue = 2;
//                                   }
//                                   setState(() {
//                                     _showDispatches = false;
//                                     _showArrivals = true;
//                                     _showPassengerCounts = false;
//                                     _showCommuterRequests = false;
//                                   });
//                                 }),
//                           ),
//                           ListTile(
//                             title: Row(
//                               children: [
//                                 Text(
//                                   'Passenger Counts',
//                                   style: myTextStyleSmall(context),
//                                 ),
//                                 const SizedBox(
//                                   width: 28,
//                                 ),
//                                 bd.Badge(
//                                   badgeStyle: bd.BadgeStyle(
//                                     elevation: 12,
//                                     padding: const EdgeInsets.all(12),
//                                     badgeColor: Colors.pink.shade700,
//                                   ),
//                                   badgeContent: Text(
//                                     '${passengerCounts.length}',
//                                     style: myTextStyleTiny(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             leading: Radio(
//                                 value: 3,
//                                 groupValue: groupValue,
//                                 onChanged: (int? v) {
//                                   pp('$mm ... passenger  radio changed : $v');
//
//                                   if (v != null) {
//                                     groupValue = 3;
//                                   }
//                                   setState(() {
//                                     _showDispatches = false;
//                                     _showArrivals = false;
//                                     _showPassengerCounts = true;
//                                     _showCommuterRequests = false;
//                                   });
//                                 }),
//                           ),
//                           ListTile(
//                             title: Row(
//                               children: [
//                                 Text(
//                                   'Commuter Requests',
//                                   style: myTextStyleSmall(context),
//                                 ),
//                                 const SizedBox(
//                                   width: 28,
//                                 ),
//                                 bd.Badge(
//                                   badgeStyle: bd.BadgeStyle(
//                                     elevation: 12,
//                                     padding: const EdgeInsets.all(12),
//                                     badgeColor: Colors.blue[800]!,
//                                   ),
//                                   badgeContent: Text(
//                                     '${requests.length}',
//                                     style: myTextStyleTiny(context),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             leading: Radio(
//                                 value: 4,
//                                 groupValue: groupValue,
//                                 onChanged: (int? v) {
//                                   pp('$mm ... commuter requests radio changed : $v');
//
//                                   if (v != null) {
//                                     groupValue = 4;
//                                   }
//                                   setState(() {
//                                     _showDispatches = false;
//                                     _showArrivals = false;
//                                     _showPassengerCounts = false;
//                                     _showCommuterRequests = true;
//                                   });
//                                 }),
//                           ),
//                         ],
//                       )),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 12,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Number of Hours ',
//                         style: myTextStyleMediumLargeWithColor(
//                             context, Theme.of(context).primaryColorLight, 12),
//                       ),
//                       const SizedBox(
//                         width: 20,
//                       ),
//                       Card(
//                         shape: getRoundedBorder(radius: 8),
//                         elevation: 12,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Text(
//                             '$hours',
//                             style: myTextStyleMediumLargeWithColor(
//                                 context, Theme.of(context).primaryColor, 24),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 28,
//                       ),
//                       NumberDropDown(
//                         color: Theme.of(context).primaryColor,
//                         count: 24,
//                         fontSize: 12,
//                         onNumberPicked: (n) {
//                           setState(() {
//                             hours = n;
//                           });
//                           if (route != null) {
//                             _getRouteData(true);
//                           } else {
//                             _getAssociationRouteData(true);
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                   const SizedBox(
//                     height: 2,
//                   ),
//                   Expanded(
//                       child: Padding(
//                     padding:  EdgeInsets.all(padding),
//                     child: ListView.builder(
//                         itemCount: routes.length,
//                         itemBuilder: (_, index) {
//                           final route = routes.elementAt(index);
//                           return GestureDetector(
//                             onTap: () {
//                               _getRouteData(true);
//                             },
//                             child: GestureDetector(
//                               onTap: () {
//                                 this.route = route;
//                                 setState(() {});
//                                 _navigateToRouteMap();
//                               },
//                               child: Card(
//                                 shape: getRoundedBorder(radius: 16),
//                                 elevation: 12,
//                                 child: ListTile(
//                                   leading: Icon(
//                                     Icons.back_hand,
//                                     color: Theme.of(context).primaryColor,
//                                   ),
//                                   title: Text(
//                                     '${route.name}',
//                                     style: myTextStyleSmall(context),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                   ))
//                 ],
//               ),
//             ),
//           ),
//           busy
//               ? const Positioned(
//                   child: Center(
//                   child: SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 4,
//                       backgroundColor: Colors.pink,
//                     ),
//                   ),
//                 ))
//               : const SizedBox()
//         ],
//       ),
//     ));
//   }
// }
