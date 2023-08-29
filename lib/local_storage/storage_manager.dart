// import 'package:isar/isar.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/route_landmark.dart';
import 'package:kasie_transie_web/data/route_point.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

import '../data/association_heartbeat_aggregation_result.dart';
import '../data/dispatch_record.dart';
import '../data/route.dart';
import '../data/route_bag.dart';
import '../data/vehicle_arrival.dart';

final StorageManager storageManager = StorageManager();
late Database db;

class StorageManager {
  static const mm = '🔵🔵🔵🔵🔵 StorageManager 🔵🔵';

  final routeStore = stringMapStoreFactory.store();
  final routeLandmarkStore = stringMapStoreFactory.store();
  final routePointStore = stringMapStoreFactory.store();
  final routeCityStore = stringMapStoreFactory.store();
  final arrivalStore = stringMapStoreFactory.store();
  final departureStore = stringMapStoreFactory.store();
  final commuterRequestStore = stringMapStoreFactory.store();
  final heartbeatStore = stringMapStoreFactory.store();
  final dispatchStore = stringMapStoreFactory.store();
  final passengerStore = stringMapStoreFactory.store();
  final timeSeriesStore = stringMapStoreFactory.store();
  final carStore = stringMapStoreFactory.store();


  final factory = databaseFactoryWeb;

  Future initialize() async {
    pp('\n\n$mm ... initialize StorageManager ... open sembast database ...\n\n');
    // Open the database
    db = await factory.openDatabase('kasiedb');
    pp('$mm ... initialize ... open sembast database ... '
        'path: ${db.path} version: ${db.version}');

  }

  Future addVehicles(List<Vehicle> cars) async {
    cars.forEach((car) async {
      final m = Map<String, Map<String,dynamic>>();
      m[car.vehicleId!] = car.toJson();
      await carStore.add(db, m);
    });
  }

  Future<Route?> getRoute(String routeId) async {
    var value = await routeStore.record(routeId).get(db);
    if (value != null) {
      if (value.isNotEmpty) {
        final x = value.values.first;
        var r = Route.fromJson(x as Map<String, dynamic>);
        return r;
      }
    }
    return null;
  }

  Future<List<Route>> getRoutes() async {
    var list = <Route>[];
    final snapshots = await routeStore.find(db);
    for (var snap in snapshots) {
      list.add(Route.fromJson(snap.value));
    }
    pp('$mm ... getRoutes found: ${list.length} ...');
    return list;
  }

  Future<List<VehicleArrival>> getArrivals(String startDate) async {
    var list = <VehicleArrival>[];
    final snapshots = await arrivalStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleArrival.fromJson(snap.value));
    }
    pp('$mm ... VehicleArrivals found in cache: ${list.length} ...');
    return list;
  }
  Future<List<VehicleDeparture>> getDepartures(String startDate) async {
    var list = <VehicleDeparture>[];
    final snapshots = await departureStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleDeparture.fromJson(snap.value));
    }
    pp('$mm ... VehicleDepartures found in cache: ${list.length} ...');
    return list;
  }
  Future<List<DispatchRecord>> getDispatches(String startDate) async {
    var list = <DispatchRecord>[];
    final snapshots = await dispatchStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(DispatchRecord.fromJson(snap.value));
    }
    pp('$mm ... DispatchRecords found in cache: ${list.length} ...');
    return list;
  }
  Future<List<VehicleHeartbeat>> getHeartbeats(String startDate) async {
    var list = <VehicleHeartbeat>[];
    final snapshots = await heartbeatStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleHeartbeat.fromJson(snap.value));
    }
    pp('$mm ... VehicleHeartbeat found in cache: ${list.length} ...');
    return list;
  }
  Future<List<AmbassadorPassengerCount>> getPassengerCounts(String startDate) async {
    var list = <AmbassadorPassengerCount>[];
    final snapshots = await passengerStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(AmbassadorPassengerCount.fromJson(snap.value));
    }
    pp('$mm ... AmbassadorPassengerCounts found in cache: ${list.length} ...');
    return list;
  }
  Future<List<CommuterRequest>> getCommuterRequests(String startDate) async {
    var list = <CommuterRequest>[];
    final snapshots = await commuterRequestStore.find(db,
        finder: Finder(filter: Filter.greaterThanOrEquals('dateRequested', startDate)));

    for (var snap in snapshots) {
      list.add(CommuterRequest.fromJson(snap.value));
    }
    pp('$mm ... CommuterRequest found in cache: ${list.length} ...');
    return list;
  }
  Future<List<RouteLandmark>> getRouteLandmarks(String routeId) async {
    var list = <RouteLandmark>[];
    final snapshots = await routeLandmarkStore.find(db,
        finder: Finder(filter: Filter.equals('routeId', routeId)));

    for (var snap in snapshots) {
      list.add(RouteLandmark.fromJson(snap.value));
    }
    pp('$mm ... getRouteLandmarks found: ${list.length} ...');
    return list;
  }
  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    var list = <RoutePoint>[];
    final snapshots = await routePointStore.find(db,
        finder: Finder(filter: Filter.equals('routeId', routeId)));

    for (var snap in snapshots) {
      list.add(RoutePoint.fromJson(snap.value));
    }
    pp('$mm ... getRoutePoints found: ${list.length} ...');
    return list;
  }

  Future addRoutes(List<RouteBag> bags) async {
    pp('$mm ... ${bags.length} routes to cache ..... : ${E.blueDot}${E.blueDot}${E.blueDot}');

    for (var bag in bags) {
      final m = Map<String, Map<String,dynamic>>();
      m[bag.route!.routeId!] = bag.route!.toJson();
      await routeStore.add(db, m);
      pp('$mm ... route: ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached    ${E.blueDot}${E.blueDot}${E.blueDot} ');

      //add landmarks ...
      bag.routeLandmarks.forEach((landmark) async {
        final b = Map<String, Map<String,dynamic>>();
        b[landmark.landmarkId!] = landmark.toJson();
        await routeLandmarkStore.add(db, b);
      });
      pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached    route landmarks: ${E.blueDot} ${bag.routeLandmarks.length}');

      //add points ...

      bag.routePoints.forEach((routePoint) async {
        final b = Map<String, Map<String,dynamic>>();
        b[routePoint.routePointId!] = routePoint.toJson();
        await routePointStore.add(db, m);
      });
      pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached    route points: ${E.blueDot} ${bag.routePoints.length}');

      //add cities ...

      int index = 0;
      bag.routeCities.forEach((city) async {
        final b = Map<String, Map<String,dynamic>>();
        b['${city.routeId!}_$index'] = city.toJson();
        await routeCityStore.add(db, m);
        index++;
      });
      pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached    route cities: ${E.blueDot} ${bag.routeCities.length}');

    }
    final test = await getRoutes();
    pp('$mm ... found in web sembast: ${E.blueDot} ${test.length}');
  }

  Future addPassengerCounts(List<AmbassadorPassengerCount> passengerCounts) async {
    pp('$mm ... addPassengerCounts : ${passengerCounts.length}');
    int index = 0;
    for (var count in passengerCounts) {
      // myPrettyJsonPrint(count.toJson());
      final b = Map<String, Map<String,dynamic>>();
      b[count.passengerCountId!] = count.toJson();
      try {
        final key = await passengerStore.add(db, b);
        // pp('$mm ... cached OK, Anna? ${E.leaf} ${count.vehicleReg} ${E.leaf} #$index key: $key');
        index++;

      } catch (e) {
        pp('$mm ... do we fall down here, Joe?');
        pp(e);
      }
    }
    pp('$mm ... do we get here, Michelle? ${E.heartBlue}');

    pp('$mm ... AmbassadorPassengerCount ${E.appleRed} ${E.appleRed} ${E.appleRed} cached'
        ' : ${passengerCounts.length}');

  }

  Future addHeartbeats(List<VehicleHeartbeat> heartbeats) async {
    pp('$mm ... addHeartbeats : ${heartbeats.length}');
    for (var value in heartbeats) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.vehicleHeartbeatId!] = value.toJson();
      await heartbeatStore.add(db, b);
    }
    pp('$mm ... VehicleHeartbeats ${E.appleRed} ${E.appleRed} cached    : ${heartbeats.length}');
  }
  Future addHeartbeatTimeSeries(List<AssociationHeartbeatAggregationResult> results) async {
    pp('$mm ... addHeartbeatTimeSeries : ${results.length}');
    for (var value in results) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.key] = value.toJson();
      await timeSeriesStore.add(db, b);
    }
    pp('$mm ... AssociationHeartbeatAggregationResults ${E.appleRed} ${E.appleRed} cached    : ${results.length}');
  }
  Future addCommuterRequest(List<CommuterRequest> requests) async {
    pp('$mm ... addCommuterRequest : ${requests.length}');
    for (var value in requests) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.commuterRequestId!] = value.toJson();
      await commuterRequestStore.add(db, b);
    }
    pp('$mm ... CommuterRequests ${E.appleRed} ${E.appleRed} cached    : ${requests.length}');
  }
  Future addDispatches(List<DispatchRecord> dispatches) async {
    pp('$mm ... addDispatches : ${dispatches.length}');
    for (var value in dispatches) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.dispatchRecordId!] = value.toJson();
      await dispatchStore.add(db, b);
    }
    pp('$mm ... Dispatches ${E.appleRed} ${E.appleRed} cached    : ${dispatches.length}');
  }

  Future addArrivals(List<VehicleArrival> arrivals) async {
    pp('$mm ... addArrivals : ${arrivals.length}');
    for (var value in arrivals) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.vehicleArrivalId!] = value.toJson();
      await arrivalStore.add(db, b);
    }
    pp('$mm ... Arrivals ${E.appleRed} ${E.appleRed} cached    : ${arrivals.length}');

  }

  Future addDepartures(List<VehicleDeparture> departures) async {
    pp('$mm ... addVehicleDepartures : ${departures.length}');
    for (var value in departures) {
      final b = Map<String, Map<String,dynamic>>();
      b[value.vehicleDepartureId!] = value.toJson();
      await departureStore.add(db, b);
    }
    pp('$mm ... VehicleDepartures ${E.appleRed} ${E.appleRed} cached    : ${departures.length}');
  }

  StorageManager() {
    pp('$mm ... constructor ...');
    initialize();
  }
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
