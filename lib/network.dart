import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_web/data/association_counts.dart';
import 'package:kasie_transie_web/data/generation_request.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';

import 'data/association_bag.dart';
import 'data/association_heartbeat_aggregation_result.dart';
import 'data/route_bag.dart';
import 'data/route_bag_list.dart';
import 'environment.dart';
import 'kasie_exception.dart';
import 'local_storage/storage_manager.dart';

final NetworkHandler networkHandler = NetworkHandler();

class NetworkHandler {
  static const xyz = '🍎🍎🍎🍎 NetworkHandler 🍎🍎';
  final http.Client client = http.Client();

  Future<String?> getAuthToken() async {
    var token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      pp('$xyz Token not found, will sign in!');
      final userCred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: 'admin@kasietransie.com', password: 'pass123_kasie');
      pp('$xyz Are we signed in? $userCred');
      if (userCred.user != null) {
        token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
      }
    } else {
      pp('$xyz Firebase token fucked');
    }
    return token;
  }

  Future<User?> getUserById(String userId) async {
    final cmd = '${KasieEnvironment.getUrl()}getUserById?userId=$userId';
    pp('$xyz getUserById .........userId: $userId  ${E.blueDot} $cmd');
    String? token = await getAuthToken();
    if (token != null) {
      final mJson = await httpGet(cmd, token);
      final User user = User.fromJson(mJson);
      return user;
    } else {
      pp('$xyz getUserById ......... no token! ${E.redDot}${E.redDot}${E.redDot} ');
    }
    return null;
  }

  Future httpPost(String mUrl, Map? bag, String token) async {
    String? mBag;
    if (bag != null) {
      mBag = json.encode(bag);
    }
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    };
    final start = DateTime.now();
    headers['Authorization'] = 'Bearer $token';
    try {
      final resp = await client
          .post(
            Uri.parse(mUrl),
            body: mBag,
            headers: headers,
          )
          .timeout(const Duration(seconds: 120));
      if (resp.statusCode == 200) {
        pp('$xyz  _httpPost RESPONSE: 💙💙 statusCode: 👌👌👌 '
            '${resp.statusCode} 👌👌👌 💙 for $mUrl');
      } else {
        pp('$xyz  👿👿👿_httpPost: 🔆 statusCode: 👿👿👿 '
            '${resp.statusCode} 🔆🔆🔆 for $mUrl');
        pp(resp.body);
        throw KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
      }
      var end = DateTime.now();
      pp('$xyz  _httpPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
      try {
        var mJson = json.decode(resp.body);
        return mJson;
      } catch (e) {
        pp("$xyz 👿👿👿👿👿👿👿 json.decode failed, returning response body");
        return resp.body;
      }
    } catch (e) {
      pp(e.toString());
    }
  }

  Future<Uint8List> _httpGetZippedData(String mUrl, String token) async {
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Accept-Encoding': 'gzip, deflate',
      // 'Access-Control-Allow-Origin': '*'
    };
    var start = DateTime.now();
    headers['Authorization'] = 'Bearer $token';
    try {
      final resp = await client
          .get(
            Uri.parse(mUrl),
            headers: headers,
          )
          .timeout(const Duration(seconds: 120));
      if (resp.statusCode == 200) {
        pp('$xyz  httpGet RESPONSE: 💙💙 statusCode: 👌👌👌 '
            '${resp.statusCode} 👌👌👌 💙 for $mUrl');
        return resp.bodyBytes;
      } else {
        pp('$xyz  👿👿👿httpGet: 🔆 statusCode: 👿👿👿 '
            '${resp.statusCode} 🔆🔆🔆 for $mUrl');
        throw KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
      }
    } catch (e) {
      pp(e.toString());
      throw Exception('http is fucked! $e');
    }
  }

  late Timer timer;

  final StreamController<AssociationBag> _bagStreamController =
      StreamController.broadcast();

  Stream<AssociationBag> get associationBagStream =>
      _bagStreamController.stream;

  void startTimer(
      {required String associationId,
      required String startDate,
      required int intervalSeconds}) async {
    pp('\n\n$xyz startTimer for getting association bag ....');
    _handleBag(associationId, startDate, true);
    timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) async {
      pp('\n\n$xyz ................. timer tick ${E.heartBlue} #${timer.tick} at ${DateTime.now().toIso8601String()}');
      await _handleBag(associationId, startDate, true);
    });
  }

  Future addAssociationToken(String associationId, String userId) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken == null) {
      pp('$xyz fcmToken is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return null;
    } else {
      pp('$xyz fcmToken is just fine! ${E.heartRed}'
          '\n$fcmToken ${E.heartRed}');
    }
    final authToken = await getAuthToken();
    if (authToken == null) {
      pp('$xyz authToken is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return null;
    } else {
      pp('$xyz authToken is just fine! ${E.heartRed}');
    }
    final url =
        '${KasieEnvironment.getUrl()}addAssociationToken?associationId=$associationId'
        '&userId=$userId&token=$fcmToken';
    final res = await httpGet(url, authToken);
    pp('$xyz AssociationToken added: $res ${E.heartRed}');
  }

  Future<void> _handleBag(
      String associationId, String startDate, bool refresh) async {
    pp('$xyz _handleBag ... ${E.heartRed}');

    final bag = await getAssociationBag(associationId, startDate, refresh);
    if (bag != null) {
      pp('$xyz put bag to _bagStreamController ... ${E.heartRed}');
      _bagStreamController.sink.add(bag);
      _filter(bag);
    }
  }

  void _filter(AssociationBag bag) {
    final map = HashMap<String, VehicleHeartbeat>();
    bag.heartbeats.sort((a, b) => a.created!.compareTo(b.created!));
    for (var value in bag.heartbeats) {
      map[value.vehicleId!] = value;
    }
    final list = map.values.toList();
    pp('$xyz distinct vehicle last heartbeats: ${list.length} ... ${E.heartRed}');
  }

  void stopTimer() {
    pp('$xyz stop timer ...');
    timer.cancel();
  }

  int count = 0;

  Future<String?> _getToken() async {
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      throw Exception('Token not found');
    } else {
      pp('$xyz token is just fine! ${E.heartRed}');
    }
    return token;
  }

  Future<AssociationCounts?> getAssociationCounts(
      String associationId, String startDate) async {
    final token = await _getToken();
    AssociationCounts? assBag;
    var start = DateTime.now();
    final url =
        '${KasieEnvironment.getUrl()}getAssociationCounts?associationId=$associationId&startDate=$startDate';
    final json = await httpGet(url, token!);
    assBag = AssociationCounts.fromJson(json);
    pp('$xyz getAssociationCounts: 🔆🔆🔆  ...'
        '\n${E.broc} arrivals ${assBag.arrivals}'
        '\n${E.broc} departures ${assBag.departures}'
        '\n${E.broc} dispatchRecords ${assBag.dispatchRecords}'
        '\n${E.broc} heartbeats ${assBag.heartbeats}'
        '\n${E.broc} commuterRequests: ${assBag.commuterRequests}'
        '\n${E.broc} passengerCounts: ${assBag.passengerCounts}');
    var end = DateTime.now();
    pp('$xyz getAssociationCounts elapsed seconds: 🔆🔆🔆 '
        '${end.difference(start).inSeconds}');
    return assBag;
  }

  Future<AssociationBag?> getAssociationBag(
      String associationId, String startDate, bool refresh) async {
    pp('$xyz ... getAssociationBag ...  ${E.heartRed}');

    //todo - build associationBag from cache
    if (refresh) {
      return await _getBag(associationId, startDate);
    } else {
      final arrivals = await storageManager.getArrivals(startDate);
      final departures = await storageManager.getDepartures(startDate);
      final heartbeats = await storageManager.getHeartbeats(startDate);
      final requests = await storageManager.getCommuterRequests(startDate);
      final passengers = await storageManager.getPassengerCounts(startDate);
      final dispatches = await storageManager.getDispatches(startDate);

      final bag = AssociationBag(
        arrivals: arrivals,
        departures: departures,
        heartbeats: heartbeats,
        commuterRequests: requests,
        passengerCounts: passengers,
        dispatchRecords: dispatches,
      );
      pp('$xyz ... getAssociationBag return bag from cache ...  ${E.heartRed}');
      if (bag.isEmpty()) {
        if (count == 0) {
          count++;
          getAssociationBag(associationId, startDate, true);
        }
      } else {
        _printBag(bag);
        return bag;
      }
    }
    return null;
  }

  Future<AssociationBag?> _getBag(
    String associationId,
    String startDate,
  ) async {
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return null;
    } else {
      pp('$xyz token is just fine! ${E.heartRed}');
    }
    AssociationBag? assBag;
    var start = DateTime.now();
    final url =
        '${KasieEnvironment.getUrl()}getAssociationBagZipped?associationId=$associationId&startDate=$startDate';
    final bodyBytes = await _httpGetZippedData(url, token);
    pp('$xyz getAssociationBag: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    // pp('$xyz ... do we have a file? ${archive.files.length} files in archive');
    // pp('$xyz getAssociationBag: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        // pp('$xyz getAssociationBag: file from inside archive ... ${file.size} '
        //     'bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        final content = file.content;
        final x = utf8.decode(content);
        final mJson = jsonDecode(x);
        // pp(mJson);
        assBag = AssociationBag.fromJson(mJson);
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;

        pp('$xyz getAssociationBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎assBag done: \n\n');
        pp('$xyz AssociationBag returned from server; ${E.blueDot} will cache data in sembast');
        storageManager.addDepartures(assBag.departures);
        storageManager.addArrivals(assBag.arrivals);
        storageManager.addPassengerCounts(assBag.passengerCounts);
        storageManager.addDispatches(assBag.dispatchRecords);
        storageManager.addHeartbeats(assBag.heartbeats);
        storageManager.addCommuterRequest(assBag.commuterRequests);
        _printBag(assBag);
      }
    }
    return assBag;
  }

  void _printBag(AssociationBag bag) {
    pp('$xyz .................................. AssociationBag contains: '
        '\n ${E.appleGreen} arrivals: ${bag.arrivals.length}'
        '\n ${E.appleGreen} departures: ${bag.departures.length}'
        '\n ${E.appleGreen} commuterRequests: ${bag.commuterRequests.length}'
        '\n ${E.appleGreen} passengerCounts: ${bag.passengerCounts.length}'
        '\n ${E.appleGreen} heartbeats: ${bag.heartbeats.length}'
        '\n ${E.appleGreen} dispatchRecords: ${bag.dispatchRecords.length}');
  }

  Future<List<AssociationHeartbeatAggregationResult>>
      getAssociationHeartbeatTimeSeries(
          String associationId, String startDate) async {
    pp('$xyz ... getAssociationHeartbeatTimeSeries ...  ${E.heartRed}');
    var start = DateTime.now();

    List<AssociationHeartbeatAggregationResult> list = [];
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    } else {
      pp('$xyz token is just fine! ${E.heartRed}');
    }
    final url =
        '${KasieEnvironment.getUrl()}getAssociationHeartbeatTimeSeries?associationId=$associationId&startDate=$startDate';
    final bodyBytes = await _httpGetZippedData(url, token);
    pp('$xyz getAssociationHeartbeatTimeSeries: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    // pp('$xyz ... do we have a file? ${archive.files.length} files in archive');
    // pp('$xyz getAssociationHeartbeatTimeSeries: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        // pp('$xyz getAssociationHeartbeatTimeSeries: file from inside archive ... ${file.size} '
        //     'bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        final content = file.content;
        final x = utf8.decode(content);
        List mJson = jsonDecode(x);
        for (var value in mJson) {
          list.add(AssociationHeartbeatAggregationResult.fromJson(value));
        }
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;
        pp('$xyz getAssociationHeartbeatTimeSeries 🍎🍎🍎🍎 work is done!, elapsed seconds: '
            '🍎$ms 🍎time series done, found: ${list.length} \n\n');
        storageManager.addHeartbeatTimeSeries(list);
      }
    }

    pp('$xyz ...  found: ${list.length}');
    return list;
  }

  Future getAssociationAmbassadorPassengerCounts(
      String associationId, String startDate) async {}

  Future getAssociationVehicleHeartbeats(
      String associationId, String startDate) async {}

  Future getAssociationCommuterRequests(
      String associationId, String startDate) async {}

  Future generateRouteCommuterRequests(String routeId) async {
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    }
    final cmd =
        '${KasieEnvironment.getUrl()}generateRouteCommuterRequests?routeId=$routeId';
    final res = await httpGet(cmd, token);
    pp('$xyz CommuterRequests: $res ${E.leaf}${E.leaf}');
    return res;
  }

  Future generateRouteDispatchRecords(GenerationRequest request) async {
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    }

    final cmd = '${KasieEnvironment.getUrl()}generateRouteDispatchRecords';
    final res = await httpPost(cmd, request.toJson(), token);

    pp('\n\n$xyz generateRouteDispatchRecords: Demo Vehicles: ${request.vehicleIds.length}  $res ${E.leaf}${E.leaf}');

    return res;
  }

  // Future<List<Vehicle>> getAssociationVehicles(String associationId) async {
  //   List<Vehicle> cars = [];
  //   final token = await getAuthToken();
  //   if (token == null) {
  //     pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
  //     return [];
  //   }
  //
  //   int pageNumber = 0;
  //   bool stop = false;
  //   while(!stop) {
  //     final mUrl = '${KasieEnvironment.getUrl()}'
  //         'getAssociationVehicles?associationId=$associationId&page=$pageNumber';
  //     List list = await httpGet(mUrl, token);
  //     for (var value in list) {
  //       cars.add(Vehicle.fromJson(value));
  //     }
  //     pageNumber++;
  //     if (list.isEmpty) {
  //       stop = true;
  //     }
  //   }
  //
  //   pp('$xyz getAssociationVehicles: 🔆🔆🔆 ${cars.length} cars found ...');
  //   return cars;
  // }
  //
  Future<List<RouteBag>> getRouteBags({required String associationId}) async {
    pp('$xyz _getRouteBag: 🔆🔆🔆 get zipped data ...');

    var start = DateTime.now();
    List<RouteBag> bags = [];
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    }
    final mUrl = '${KasieEnvironment.getUrl()}'
        'getAssociationRouteZippedFile?associationId=$associationId';

    final bodyBytes = await _httpGetZippedData(mUrl, token);
    pp('$xyz _getRouteBag: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    // pp('$xyz ... do we have a file? ${archive.files.length} files in archive');
    // pp('$xyz _getRouteBag: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        // pp('$xyz getRouteBags: file from inside archive ... ${file.size} '
        //     'bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        final content = file.content;
        final x = utf8.decode(content);
        final mJson = jsonDecode(x);
        final bagList = RouteBagList.fromJson(mJson);
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;
        pp('$xyz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎bags done: ${bags.length}\n\n');
        storageManager.addRoutes(bagList.routeBags);
        return bagList.routeBags;
      }
    }
    throw Exception('Something went wrong');
  }

//
  Future<List<Vehicle>> getAssociationVehicles(
      {required String associationId, required bool refresh}) async {
    pp('$xyz getAssociationVehicles: 🔆🔆🔆 get zipped data ...');

    if (refresh) {
      return _getCarsFromBackend(associationId);
    }
    final mList = await storageManager.getCars();
    return mList;
  }

  Future<List<Vehicle>> _getCarsFromBackend(String associationId) async {
    var start = DateTime.now();
    List<Vehicle> cars = [];
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    }
    final mUrl = '${KasieEnvironment.getUrl()}'
        'getVehiclesZippedFile?associationId=$associationId';

    final bodyBytes = await _httpGetZippedData(mUrl, token);
    pp('$xyz getAssociationVehicles: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    // pp('$xyz ... do we have a file? ${archive.files.length} files in archive');
    // pp('$xyz getAssociationVehicles: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        // pp('$xyz getAssociationVehicles: file from inside archive ... ${file.size} '
        //     'bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        final content = file.content;
        final x = utf8.decode(content);
        List mJson = jsonDecode(x);
        for (var value in mJson) {
          cars.add(Vehicle.fromJson(value));
        }
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;
        pp('$xyz getAssociationVehicles 🍎🍎🍎🍎 work is done!, elapsed seconds: '
            '🍎$ms 🍎vehicles done: ${cars.length}\n\n');

        storageManager.addVehicles(cars);
      }
    }
    return cars;
  }

  Future<List<User>> getAssociationUsers(
      {required String associationId, required bool refresh}) async {
    pp('$xyz getAssociationUsers: 🔆🔆🔆  ...');

    var cList = await storageManager.getUsers();

    if (refresh) {
      return _getUsersFromBackend(associationId);
    }
    if (cList.isEmpty) {
      cList = await _getUsersFromBackend(associationId);
    }
    return cList;
  }

  Future<List<User>> _getUsersFromBackend(String associationId) async {
    var start = DateTime.now();
    List<User> users = [];
    final token = await getAuthToken();
    if (token == null) {
      pp('$xyz token is null, quit! ${E.redDot}${E.redDot}${E.redDot}');
      return [];
    }
    final mUrl = '${KasieEnvironment.getUrl()}'
        'getAssociationUsers?associationId=$associationId';

    List res = await httpGet(mUrl, token);
    res.forEach((element) {
      users.add(User.fromJson(element));
    });
    pp('$xyz getAssociationUsers: 🔆🔆🔆 found: ${users.length} bytes ...');

    return users;

  }
  Future httpGet(String mUrl, String token) async {
    pp('$xyz httpGet: 🔆 🔆 🔆 calling :\n 💙 $mUrl  💙');
    var start = DateTime.now();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      // 'Accept': 'application/json',
    };
    headers['Authorization'] = 'Bearer $token';
    try {
      final http.Client client = http.Client();
      var resp = await client
          .get(
            Uri.parse(mUrl),
            headers: headers,
          )
          .timeout(const Duration(seconds: 120));
      pp('$xyz _httpGet call RESPONSE: .... : 💙 statusCode: 👌👌👌 ${resp.statusCode} 👌👌👌 💙 for $mUrl');
      var end = DateTime.now();
      pp('$xyz _httpGet call: 🔆 elapsed time for http: ${end.difference(start).inSeconds} seconds 🔆 \n\n');

      if (resp.statusCode == 200) {
        var mJson = json.decode(resp.body);
        return mJson;
      }

      if (resp.statusCode == 403) {
        var msg =
            '😡 😡 status code: ${resp.statusCode}, Request Forbidden 🥪 🥙 🌮  😡 ${resp.body}';
        pp(msg);
        final gex = KasieException(
            message: 'Forbidden request: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'authProblem',
            errorType: KasieException.socketException);
        throw gex;
      } else {
        var msg =
            '$xyz 😡😡😡😡😡😡 Bad Moon Rising: status: ${resp.statusCode}, '
            'NOT GOOD, throwing up !! 🥪 🥙 🌮 😡 body: ${E.redDot} ${resp.body}';
        pp(msg);
        final gex = KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
        throw gex;
      }
    } catch (e) {
      pp(e);
      rethrow;
    }
  }
}
