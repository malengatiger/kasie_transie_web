import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';

import 'data/route_bag.dart';
import 'data/user.dart' as lib;
import 'environment.dart';
import 'kasie_exception.dart';

final NetworkHandler networkHandler = NetworkHandler();

class NetworkHandler {
  static const xyz = '🍎🍎🍎🍎 Network 🍎🍎';
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

  Future<lib.User?> getUserById(String userId) async {
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

  Future<Uint8List> httpGetZippedRoutes(String mUrl, String token) async {
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

    final bodyBytes = await httpGetZippedRoutes(mUrl, token!);
    pp('$xyz _getRouteBag: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    pp('$xyz ... do we have a file? ${archive.files.length} files in archive');
    pp('$xyz _getRouteBag: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        pp('$xyz getRouteBags: file from inside archive ... ${file.size} '
            'bytes 🔵 isCompressed: ${file.isCompressed} 🔵 zipped file name: ${file.name}');
        final content = file.content;
        final x = utf8.decode(content);
        List list = jsonDecode(x);
        for (var value in list) {
          final RouteBag bag = RouteBag.fromJson(value);
          bags.add(bag);
        }
        var end = DateTime.now();
        var ms = end.difference(start).inSeconds;
        pp('$xyz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎bags done: ${bags.length}\n\n');

        return bags;
      }
    }
    throw Exception('Something went wrong');
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
