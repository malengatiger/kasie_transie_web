// import 'package:isar/isar.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/route_city.dart';
import 'package:kasie_transie_web/data/route_landmark.dart';
import 'package:kasie_transie_web/data/route_point.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
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
  final commuterRequestStore =
      stringMapStoreFactory.store('commuterRequestStore');
  final heartbeatStore = stringMapStoreFactory.store('heartbeatStore');
  final dispatchStore = stringMapStoreFactory.store('dispatchStore');
  final passengerStore = stringMapStoreFactory.store('passengerStore');
  final timeSeriesStore = stringMapStoreFactory.store('timeSeriesStore');
  final carStore = stringMapStoreFactory.store('carStore');
  final userStore = stringMapStoreFactory.store('userStore');

  final factory = databaseFactoryWeb;

  Future initialize() async {
    pp('$mm ... initialize StorageManager ... open sembast database ...');
    // Open the database
    db = await factory.openDatabase('kasiedb');
    pp('$mm ... initialize ... opened sembast database ... ${E.heartBlue}'
        'path: ${db.path} version: ${db.version}');
  }

  Future addVehicles(List<Vehicle> cars) async {
    pp('$mm ...');

    cars.forEach((car) async {
        final record = await carStore.record(car.vehicleId!);
        await record.put(db, car.toJson());
    });
    final tot3 = await carStore.count(db);
    pp('$mm ... addVehicles ${E.appleRed} ${E.appleRed} '
        'cached cars: ${E.blueDot} total in store : $tot3');
  }

  Future<Route?> getRoute(String routeId) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('routeId', routeId),
      sortOrders: [SortOrder('routeId')],
    );
    final records = await routeStore.find(db, finder: finder);
    final list = records
        .map((record) => Route.fromJson(record.value))
        .toList();
    pp('$mm ... getRoute found: ${list.length} routes');
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<Vehicle?> getCarByRegistration(String vehicleReg) async {
    pp('$mm ... getCarByRegistration find: $vehicleReg ');

    final finder = Finder(
      filter: Filter.equals('vehicleReg', vehicleReg),
      sortOrders: [SortOrder('vehicleReg')],
    );
    final records = await carStore.find(db, finder: finder);
    final list = records
        .map((record) => Vehicle.fromJson(record.value))
        .toList();
    pp('$mm ... getCarByRegistration found: ${list.length} cars');
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<User?> getUserById(String userId) async {
    pp('$mm ... getUserById find: $userId ');

    final finder = Finder(
      filter: Filter.equals('userId', userId),
      sortOrders: [SortOrder('userId')],
    );
    final records = await userStore.find(db, finder: finder);
    final list = records
        .map((record) => User.fromJson(record.value))
        .toList();
    pp('$mm ... getUserById found: ${list.length} cars');
    if (list.isNotEmpty) {
      return list.first;
    } else {
      final user = await prefs.getUser();
      if (user != null) {
        await networkHandler.getAssociationUsers(
            associationId: user.associationId!, refresh: true);
        getUserById(userId);
      }
    }
    return null;
  }

  Future<List<Route>> getRoutes() async {
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await routeStore.find(db, finder: finder);

    final list = records.map((record) => Route.fromJson(record.value)).toList();
    pp('$mm ... getRoutes found: ${list.length}');
    return list;
  }

  Future<List<Vehicle>> getCars() async {
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await carStore.find(db, finder: finder);

    final list =
        records.map((record) => Vehicle.fromJson(record.value)).toList();
    pp('$mm ... getCars found: ${list.length}');
    return list;
  }

  Future<List<User>> getUsers() async {
    final finder = Finder(sortOrders: [SortOrder('name')]);
    final records = await userStore.find(db, finder: finder);

    final list = records.map((record) => User.fromJson(record.value)).toList();
    pp('$mm ... getUsers found: ${list.length}');
    return list;
  }

  Future<List<VehicleArrival>> getArrivals(String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('created', startDate),
      sortOrders: [SortOrder('created')],
    );
    final records = await arrivalStore.find(db, finder: finder);
    final list =
        records.map((record) => VehicleArrival.fromJson(record.value)).toList();
    pp('$mm ... getArrivals found: ${list.length}');
    return list;
  }

  Future<List<VehicleDeparture>> getDepartures(String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('created', startDate),
      sortOrders: [SortOrder('created')],
    );
    final records = await arrivalStore.find(db, finder: finder);
    final list = records
        .map((record) => VehicleDeparture.fromJson(record.value))
        .toList();
    pp('$mm ... getDepartures found: ${list.length}');
    return list;
  }

  Future<List<DispatchRecord>> getDispatches(String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('created', startDate),
      sortOrders: [SortOrder('created')],
    );
    final records = await dispatchStore.find(db, finder: finder);
    final list =
        records.map((record) => DispatchRecord.fromJson(record.value)).toList();
    pp('$mm ... getDispatches found: ${list.length}');
    return list;
  }

  Future<List<VehicleHeartbeat>> getHeartbeats(String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('created', startDate),
      sortOrders: [SortOrder('created')],
    );
    final records = await heartbeatStore.find(db, finder: finder);
    final list = records
        .map((record) => VehicleHeartbeat.fromJson(record.value))
        .toList();
    pp('$mm ... getVehicleHeartbeats found: ${list.length}');
    return list;
  }

  Future<List<AmbassadorPassengerCount>> getPassengerCounts(
      String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('created', startDate),
      sortOrders: [SortOrder('created')],
    );
    final records = await passengerStore.find(db, finder: finder);
    final list = records
        .map((record) => AmbassadorPassengerCount.fromJson(record.value))
        .toList();
    pp('$mm ... getPassengerCounts found: ${list.length}');
    return list;
  }

  Future<List<CommuterRequest>> getCommuterRequests(String startDate) async {
    final finder = Finder(
      filter: Filter.greaterThanOrEquals('dateRequested', startDate),
      sortOrders: [SortOrder('dateRequested')],
    );
    final records = await commuterRequestStore.find(db, finder: finder);
    final list = records
        .map((record) => CommuterRequest.fromJson(record.value))
        .toList();
    pp('$mm ... getCommuterRequests found: ${list.length}');
    return list;
  }

  Future<List<RouteLandmark>> getRouteLandmarks(String routeId) async {
    final finder = Finder(
      filter: Filter.equals('routeId', routeId),
      sortOrders: [SortOrder('index')],
    );
    final records = await routeLandmarkStore.find(db, finder: finder);
    final list =
        records.map((record) => RouteLandmark.fromJson(record.value)).toList();
    pp('$mm ... getRouteLandmarks found: ${list.length}');
    return list;
  }

  Future<List<RouteCity>> getRouteCities(String routeId) async {
    final finder = Finder(
      filter: Filter.equals('routeId', routeId),
      sortOrders: [SortOrder('cityName')],
    );
    final records = await routeCityStore.find(db, finder: finder);
    final list =
    records.map((record) => RouteCity.fromJson(record.value)).toList();
    pp('$mm ... getRouteCities found: ${list.length}');
    return list;
  }

  Future<List<RoutePoint>> getRoutePoints(String routeId) async {
    final finder = Finder(
      filter: Filter.equals('routeId', routeId),
      sortOrders: [SortOrder('index')],
    );
    final records = await routePointStore.find(db, finder: finder);
    final list =
        records.map((record) => RoutePoint.fromJson(record.value)).toList();
    pp('$mm ... getRoutePoints found: ${list.length}');
    return list;
  }

  //

  Future addRoutes(List<RouteBag> bags) async {
    pp('$mm ... add ${bags.length} routes to cache ..... : '
        '${E.blueDot}${E.blueDot}${E.blueDot}');

    for (var bag in bags) {
      final record = await routeStore.record(bag.route!.routeId!);
      await record.put(db, bag.route!.toJson());
      //add landmarks ...
      bag.routeLandmarks.forEach((landmark) async {
        final rec = await routeLandmarkStore.record(landmark.landmarkId!);
        await rec.put(db, landmark.toJson());
      });
      //add points ...
      bag.routePoints.forEach((routePoint) async {
        final res2 = await routePointStore.record(routePoint.routePointId!);
        await res2.put(db, routePoint.toJson());
      });
      //add cities ...
      bag.routeCities.forEach((city) async {
        final res2 =
            await routeCityStore.record('${city.routeId!}_${city.cityId!}');
        await res2.put(db, city.toJson());
      });
    }
    final tot0 = await routeStore.count(db);
    pp('$mm ...  ${E.appleRed} ${E.appleRed} '
        'cached routes: ${E.blueDot} total in store from count(db) : $tot0');
    final tot1 = await routeLandmarkStore.count(db);
    pp('$mm ...  ${E.appleRed} ${E.appleRed} '
        'cached route landmarks: ${E.blueDot} total in store from count(db) : $tot1');
    final tot2 = await routePointStore.count(db);
    pp('$mm ... ${E.appleRed} ${E.appleRed} '
        'cached route points: ${E.blueDot} total in store from count(db) : $tot2');
    final tot3 = await routeCityStore.count(db);
    pp('$mm ... ${E.appleRed} ${E.appleRed} '
        'cached route cities: ${E.blueDot} total in store from count(db) : $tot3');
  }

  Future addPassengerCounts(
      List<AmbassadorPassengerCount> passengerCounts) async {
    pp('$mm ... addPassengerCounts : ${passengerCounts.length}');
    for (var value in passengerCounts) {
      final key2 = await passengerStore.record(value.passengerCountId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await passengerStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached passengerCounts: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addHeartbeats(List<VehicleHeartbeat> heartbeats) async {
    pp('$mm ... addHeartbeats : ${heartbeats.length}');
    for (var value in heartbeats) {
      final key2 = await heartbeatStore.record(value.vehicleHeartbeatId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await heartbeatStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached heartbeats: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addHeartbeatTimeSeries(
      List<AssociationHeartbeatAggregationResult> results) async {
    try {
      pp('$mm ............... addHeartbeatTimeSeries : ${results.length}');
      for (var value in results) {
            final key2 = await timeSeriesStore.record(value.getKey()!);
            await key2.put(db, value.toJson());
          }
      final tot6 = await timeSeriesStore.count(db);
      pp('$mm ... AssociationHeartbeatAggregationResults ${E.appleRed} ${E.appleRed} '
              'cached aggregates total in store (used count(db) : $tot6');
    } catch (e, s) {
      pp('$e --- $s');
    }
  }

  Future addCommuterRequest(List<CommuterRequest> requests) async {
    pp('$mm ... addCommuterRequest : ${requests.length}');

    for (var value in requests) {
      final key2 = await commuterRequestStore.record(value.commuterRequestId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await commuterRequestStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached CommuterRequests: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addDispatches(List<DispatchRecord> dispatches) async {
    pp('$mm ... addDispatches : ${dispatches.length}');

    for (var value in dispatches) {
      final key2 = await dispatchStore.record(value.dispatchRecordId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await dispatchStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached  dispatches: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addArrivals(List<VehicleArrival> arrivals) async {
    pp('$mm ... addArrivals : ${arrivals.length}');

    for (var value in arrivals) {
      final key2 = await arrivalStore.record(value.vehicleArrivalId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await arrivalStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached  arrivals: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addDepartures(List<VehicleDeparture> departures) async {
    pp('$mm ... addVehicleDepartures : ${departures.length}');
    for (var value in departures) {
      final key2 = await departureStore.record(value.vehicleDepartureId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await departureStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached  departures: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  Future addUsers(List<User> users) async {
    pp('$mm ... addUsers : ${users.length}');
    for (var value in users) {
      final key2 = await userStore.record(value.userId!);
      await key2.put(db, value.toJson());
    }
    try {
      final tot3 = await userStore.count(db);
      pp('$mm ... ${E.appleRed} ${E.appleRed} '
          'cached users: ${E.blueDot} total in store from count(db) : $tot3');
    } catch (e) {
      pp(e);
    }
  }

  StorageManager() {
    pp('$mm ... StorageManager constructor ... ${E.appleRed}');
    initialize();
  }
}
