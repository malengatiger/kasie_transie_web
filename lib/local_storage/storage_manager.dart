

import 'package:flutter/cupertino.dart';
// import 'package:isar/isar.dart';
import 'package:kasie_transie_web/data/route.dart' as lib;
import 'package:kasie_transie_web/data/route_landmark.dart';
import 'package:kasie_transie_web/data/route_point.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/route.dart';

final StorageManager storageManager = StorageManager();

class StorageManager {
  static const mm = '🔵🔵🔵 StorageManager 🔵🔵';
  //
  // late Isar isar;
  // initialize() async {
  //   pp('$mm initialize StorageManager ....');
  //
  //   var path = "/assets/db";
  //   isar = await Isar.open(
  //     [RouteSchema, RouteLandmarkSchema, RoutePointSchema],
  //     directory: path,
  //   );
  //   pp('$mm StorageManager initialized: ${isar.name} path: ${isar.path}');
  // }
  //
  // Future savePoints(List<RoutePoint> points) async {
  //   await isar.writeTxn(() async {
  //     await isar.routePoints.putAll(points); // insert & update
  //   });
  //   pp('$mm points saved ....');
  //
  // }
  // Future getPoints(String routeId) async {
  //   final points = await isar.routePoints
  //       .where()
  //       .routeIdEqualTo(routeId) // use index
  //       .findAll();
  //   pp('$mm points retrieved : ${points.length} ....');
  //   return points;
  // }
  //
  // Future saveLandmarks(List<RouteLandmark> landmarks) async {
  //   await isar.writeTxn(() async {
  //     await isar.routeLandmarks.putAll(landmarks); // insert & update
  //   });
  //   pp('$mm landmarks saved ....${landmarks.length} for route: ${landmarks.first.routeName}');
  //
  // }
  // Future getLandmarks(String routeId) async {
  //   final marks = await isar.routeLandmarks
  //       .where()
  //       .routeIdEqualTo(routeId) // use index
  //       .findAll();
  //   pp('$mm landmarks retrieved : ${marks.length} ....');
  //   return marks;
  // }
  // Future saveRoutes(List<lib.Route> routes) async {
  //   await isar.writeTxn(() async {
  //     await isar.routes.putAll(routes); // insert & update
  //   });
  //   pp('$mm routes saved ....${routes.length}');
  //
  // }
  // Future getRoutes(String associationId) async {
  //   final routes = await isar.routes.where().associationIdEqualTo(associationId).findAll();
  //   pp('$mm routes retrieved : ${routes.length} ....');
  //   return routes;
  // }
}
