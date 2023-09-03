// import 'package:isar/isar.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/route_landmark.dart';
import 'package:kasie_transie_web/data/route_point.dart';
import 'package:kasie_transie_web/data/user.dart';
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

  final routeStore = stringMapStoreFactory.store('routeStore');
  final routeLandmarkStore = stringMapStoreFactory.store('routeLandmarkStore');
  final routePointStore = stringMapStoreFactory.store('routePointStore');
  final routeCityStore = stringMapStoreFactory.store('routeCityStore');
  final arrivalStore = stringMapStoreFactory.store('arrivalStore');
  final departureStore = stringMapStoreFactory.store('departureStore');
  final commuterRequestStore = stringMapStoreFactory.store('commuterRequestStore');
  final heartbeatStore = stringMapStoreFactory.store('heartbeatStore');
  final dispatchStore = stringMapStoreFactory.store('dispatchStore');
  final passengerStore = stringMapStoreFactory.store('passengerStore');
  final timeSeriesStore = stringMapStoreFactory.store('timeSeriesStore');
  final carStore = stringMapStoreFactory.store('carStore');
  final userStore = stringMapStoreFactory.store('userStore');


  final factory = databaseFactoryWeb;

  Future initialize() async {
    pp('\n\n$mm ... initialize StorageManager ... open sembast database ...');
    // Open the database
    db = await factory.openDatabase('kasiedb');
    pp('$mm ... initialize ... open sembast database ... ${E.heartBlue}'
        'path: ${db.path} version: ${db.version}');
  }

  Future addVehicles(List<Vehicle> cars) async {
    int cnt = 0;
    cars.forEach((car) async {
      final m = Map<String, Map<String, dynamic>>();
      m[car.vehicleId!] = car.toJson();
      final res =
          await carStore.record(car.vehicleId!).update(db, car.toJson());

      if (res == null) {
        final res = await carStore.record(car.vehicleId!).add(db, car.toJson());
        if (res != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    });
    final tot3 = await carStore.count(db);
    pp('$mm ... addVehicles ${E.appleRed} ${E.appleRed} '
        'cached  $cnt  cars: ${E.blueDot} $cnt total in store : $tot3');
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

  Future<List<Vehicle>> getCars() async {
    var list = <Vehicle>[];
    final snapshots = await carStore.find(db);
    for (var snap in snapshots.toList()) {
      list.add(Vehicle.fromJson(snap.value));
    }
    pp('$mm ... Vehicles found in cache: ${list.length} ...');
    return list;
  }
  Future<List<User>> getUsers() async {
    var list = <User>[];
    final snapshots = await userStore.find(db);
    for (var snap in snapshots.toList()) {
      list.add(User.fromJson(snap.value));
    }
    pp('$mm ... Users found in cache: ${list.length} ...');
    return list;
  }
  Future<List<VehicleArrival>> getArrivals(String startDate) async {
    var list = <VehicleArrival>[];
    final snapshots =  await arrivalStore.find(db,
        finder:
            Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleArrival.fromJson(snap.value));
    }
    pp('$mm ... VehicleArrivals found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<VehicleDeparture>> getDepartures(String startDate) async {
    var list = <VehicleDeparture>[];
    final snapshots = await departureStore.find(db,
        finder:
            Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleDeparture.fromJson(snap.value));
    }
    pp('$mm ... VehicleDepartures found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<DispatchRecord>> getDispatches(String startDate) async {
    var list = <DispatchRecord>[];
    final snapshots = await dispatchStore.find(db,
        finder:
            Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(DispatchRecord.fromJson(snap.value));
    }
    pp('$mm ... DispatchRecords found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<VehicleHeartbeat>> getHeartbeats(String startDate) async {
    var list = <VehicleHeartbeat>[];
    final snapshots = await heartbeatStore.find(db,
        finder:
            Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(VehicleHeartbeat.fromJson(snap.value));
    }
    pp('$mm ... VehicleHeartbeat found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<AmbassadorPassengerCount>> getPassengerCounts(
      String startDate) async {
    var list = <AmbassadorPassengerCount>[];
    final snapshots = await passengerStore.find(db,
        finder:
            Finder(filter: Filter.greaterThanOrEquals('created', startDate)));

    for (var snap in snapshots) {
      list.add(AmbassadorPassengerCount.fromJson(snap.value));
    }
    pp('$mm ... AmbassadorPassengerCounts found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<CommuterRequest>> getCommuterRequests(String startDate) async {
    var list = <CommuterRequest>[];
    final snapshots = await commuterRequestStore.find(db,
        finder: Finder(
            filter: Filter.greaterThanOrEquals('dateRequested', startDate)));

    for (var snap in snapshots) {
      list.add(CommuterRequest.fromJson(snap.value));
    }
    pp('$mm ... CommuterRequest found in cache: ${list.length} ... startDate: $startDate');
    return list;
  }

  Future<List<RouteLandmark>> getRouteLandmarks(String routeId) async {
    var list = <RouteLandmark>[];
    final snapshots = await routeLandmarkStore.find(db,
        finder: Finder(filter: Filter.equals('routeId', routeId)));

    for (var snap in snapshots) {
      list.add(RouteLandmark.fromJson(snap.value));
    }
    pp('$mm ... getRouteLandmarks found: ${list.length} ... for routeId: $routeId');
    return list;
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    var list = <RoutePoint>[];
    final snapshots = await routePointStore.find(db,
        finder: Finder(filter: Filter.equals('routeId', routeId)));

    for (var snap in snapshots) {
      list.add(RoutePoint.fromJson(snap.value));
    }
    pp('$mm ... getRoutePoints found: ${list.length} ... for routeId: $routeId');
    return list;
  }

  Future addRoutes(List<RouteBag> bags) async {
    pp('$mm ... ${bags.length} routes to cache ..... : ${E.blueDot}${E.blueDot}${E.blueDot}');

    for (var bag in bags) {
      final res = await routeStore
          .record(bag.route!.routeId!)
          .update(db, bag.route!.toJson());
      int cnt = 0;
      if (res == null) {
        final res = await carStore
            .record(bag.route!.routeId!)
            .add(db, bag.route!.toJson());
        if (res != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
      final tot = await getRoutes();
      pp('$mm ... route: ${bag.route!.name} ${E.appleRed} ${E.appleRed} '
          'cached  $cnt total in store : ${tot.length} ');

      //add landmarks ...
      cnt = 0;
      bag.routeLandmarks.forEach((landmark) async {
        final res = await routeLandmarkStore
            .record(landmark.landmarkId!)
            .update(db, landmark.toJson());
        if (res == null) {
          final res2 = await routeLandmarkStore
              .record(landmark.landmarkId!)
              .add(db, landmark.toJson());
          if (res2 != null) {
            cnt++;
          }
        } else {
          cnt++;
        }
      });

      try {
        final tot1 = await getRouteLandmarks(bag.routeLandmarks.first.routeId!);
        pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached $cnt route landmarks: '
                  '${E.blueDot} $cnt total in store : ${tot1.length}');
      } catch (e) {
        pp(e);
      }

      //add points ...

      cnt = 0;
      bag.routePoints.forEach((routePoint) async {
        final res = await routePointStore
            .record(routePoint.routePointId!)
            .update(db, routePoint.toJson());
        if (res == null) {
          final res2 = await routePointStore
              .record(routePoint.routePointId!)
              .add(db, routePoint.toJson());
          if (res2 != null) {
            cnt++;
          }
        } else {
          cnt++;
        }
      });
      try {
        final tot2 = await getRoutePoints(bag.routePoints.first.routeId!);
        pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} cached route points: '
                  '${E.blueDot} $cnt total in store : ${tot2.length}');
      } catch (e) {
        pp(e);
      }

      //add cities ...

      cnt = 0;
      bag.routeCities.forEach((city) async {
        final res = await routeCityStore
            .record('${city.routeId!}_${city.cityId!}')
            .update(db, city.toJson());
        if (res == null) {
          final res2 = await routeCityStore
              .record('${city.routeId!}_${city.cityId!}')
              .add(db, city.toJson());
          if (res2 != null) {
            cnt++;
          }
        } else {
          cnt++;
        }
      });

      final tot3 = await routeCityStore.count(db);
      pp('$mm ... ${bag.route!.name} ${E.appleRed} ${E.appleRed} '
          'cached  $cnt  route cities: ${E.blueDot} $cnt total in store from count(db) : $tot3');
    }
  }

  Future addPassengerCounts(
      List<AmbassadorPassengerCount> passengerCounts) async {
    pp('$mm ... addPassengerCounts : ${passengerCounts.length}');
    int cnt = 0;
    for (var value in passengerCounts) {
      try {
        final key = await passengerStore
            .record(value.passengerCountId!)
            .update(db, value.toJson());
        if (key == null) {
          final key2 = await passengerStore
              .record(value.passengerCountId!)
              .add(db, value.toJson());
          if (key2 != null) {
            cnt++;
          }
        } else {
          cnt++;
        }
      } catch (e) {
        pp('$mm ... do we fall down here, Joe?');
        pp(e);
      }
    }
    try {
      pp('$mm ... addPassengerCounts: do we get here, Michelle? ${E.heartBlue}');
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot4 = await getPassengerCounts(startDate);

      pp('$mm ... AmbassadorPassengerCount ${E.appleRed} ${E.appleRed} ${E.appleRed} cached'
              ' $cnt total in store : ${tot4.length}');
    } catch (e) {
      print(e);
    }
  }

  Future addHeartbeats(List<VehicleHeartbeat> heartbeats) async {
    pp('$mm ... addHeartbeats : ${heartbeats.length}');
    var cnt = 0;
    for (var value in heartbeats) {
      final key = await heartbeatStore
          .record(value.vehicleHeartbeatId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await heartbeatStore
            .record(value.vehicleHeartbeatId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      }
    }
    try {
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot5 = await getHeartbeats(startDate);
      pp('$mm ... VehicleHeartbeats ${E.appleRed} ${E.appleRed} '
          'cached $cnt total in store : ${tot5.length}');
    } catch (e) {
      pp(e);
    }
  }

  Future addHeartbeatTimeSeries(
      List<AssociationHeartbeatAggregationResult> results) async {
    pp('$mm ... addHeartbeatTimeSeries : ${results.length}');
    var cnt = 0;
    for (var value in results) {
      final key =
          await timeSeriesStore.record(value.key).update(db, value.toJson());
      if (key == null) {
        final key2 =
            await timeSeriesStore.record(value.key).add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    final tot6 = await timeSeriesStore.count(db);
    pp('$mm ... AssociationHeartbeatAggregationResults ${E.appleRed} ${E.appleRed} '
        'cached $cnt total in store (used count(db) : $tot6');
  }

  Future addCommuterRequest(List<CommuterRequest> requests) async {
    pp('$mm ... addCommuterRequest : ${requests.length}');
    var cnt = 0;

    for (var value in requests) {
      final key = await commuterRequestStore
          .record(value.commuterRequestId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await commuterRequestStore
            .record(value.commuterRequestId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    try {
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot = await getCommuterRequests(startDate);
      pp('$mm ... CommuterRequests ${E.appleRed} ${E.appleRed} cached '
          '$cnt total in store : ${tot.length}');
    } catch (e) {
      pp(e);
    }
  }

  Future addDispatches(List<DispatchRecord> dispatches) async {
    pp('$mm ... addDispatches : ${dispatches.length}');
    var cnt = 0;

    for (var value in dispatches) {
      final key = await dispatchStore
          .record(value.dispatchRecordId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await dispatchStore
            .record(value.dispatchRecordId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    try {
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot = await getDispatches(startDate);
      pp('$mm ... Dispatches ${E.appleRed} ${E.appleRed} cached  $cnt total in store : ${tot.length}');
    } catch (e) {
      pp(e);
    }
  }

  Future addArrivals(List<VehicleArrival> arrivals) async {
    pp('$mm ... addArrivals : ${arrivals.length}');
    var cnt = 0;

    for (var value in arrivals) {
      final key = await arrivalStore
          .record(value.vehicleArrivalId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await arrivalStore
            .record(value.vehicleArrivalId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    try {
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot = await getArrivals(startDate);
      pp('$mm ... Arrivals ${E.appleRed} ${E.appleRed} cached$cnt total in store : ${tot.length}');
    } catch (e) {
      pp(e);
    }
  }

  Future addDepartures(List<VehicleDeparture> departures) async {
    pp('$mm ... addVehicleDepartures : ${departures.length}');
    var cnt = 0;
    for (var value in departures) {
      final key = await departureStore
          .record(value.vehicleDepartureId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await departureStore
            .record(value.vehicleDepartureId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    try {
      final startDate = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();
      final tot = await getDepartures(startDate);
      pp('$mm ... VehicleDepartures ${E.appleRed} ${E.appleRed} cached  $cnt total in store : ${tot.length}');
    } catch (e) {
      pp(e);
    }
  }

  Future addUsers(List<User> users) async {
    pp('$mm ... addUsers : ${users.length}');
    var cnt = 0;
    for (var value in users) {
      final key = await userStore
          .record(value.userId!)
          .update(db, value.toJson());
      if (key == null) {
        final key2 = await userStore
            .record(value.userId!)
            .add(db, value.toJson());
        if (key2 != null) {
          cnt++;
        }
      } else {
        cnt++;
      }
    }
    try {
      final tot = await getUsers();
      pp('$mm ... Users ${E.appleRed} ${E.appleRed} cached  $cnt total in store : ${tot.length}');
    } catch (e) {
      pp(e);
    }
  }

  StorageManager() {
    pp('$mm ... StorageManager constructor ... ${E.appleRed}');
    initialize();
  }
}
