import 'dart:convert';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:universal_io/io.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:universal_io/io.dart';
import 'data/route_bag.dart';
import 'environment.dart';
import 'kasie_exception.dart';

final Network network = Network();

class Network {
  static const xyz = '🍎🍎🍎🍎 Network';
  final http.Client client = http.Client();

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
        debugPrint('$xyz  _httpPost RESPONSE: 💙💙 statusCode: 👌👌👌 '
            '${resp.statusCode} 👌👌👌 💙 for $mUrl');
      } else {
        debugPrint('$xyz  👿👿👿_httpPost: 🔆 statusCode: 👿👿👿 '
            '${resp.statusCode} 🔆🔆🔆 for $mUrl');
        debugPrint(resp.body);
        throw KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
      }
      var end = DateTime.now();
      debugPrint(
          '$xyz  _httpPost: 🔆 elapsed time: ${end.difference(start).inSeconds} seconds 🔆');
      try {
        var mJson = json.decode(resp.body);
        return mJson;
      } catch (e) {
        debugPrint(
            "$xyz 👿👿👿👿👿👿👿 json.decode failed, returning response body");
        return resp.body;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<Uint8List> httpGet(String mUrl, String token) async {
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
        debugPrint('$xyz  httpGet RESPONSE: 💙💙 statusCode: 👌👌👌 '
            '${resp.statusCode} 👌👌👌 💙 for $mUrl');
        return resp.bodyBytes;
      } else {
        debugPrint('$xyz  👿👿👿httpGet: 🔆 statusCode: 👿👿👿 '
            '${resp.statusCode} 🔆🔆🔆 for $mUrl');
        throw KasieException(
            message: 'Bad status code: ${resp.statusCode} - ${resp.body}',
            url: mUrl,
            translationKey: 'serverProblem',
            errorType: KasieException.socketException);
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('http is fucked! $e');

    }
  }

  Future<List<RouteBag>> getRouteBags({required String associationId}) async {
    debugPrint('$xyz _getRouteBag: 🔆🔆🔆 get zipped data ...');

    var start = DateTime.now();
    List<RouteBag> bags = [];
    var token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      debugPrint('$xyz Token not found, will sign in!');
      final userCred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: 'admin@kasietransie.com', password: 'pass123_kasie');
      debugPrint('$xyz Are we signed in? $userCred');
      if (userCred.user != null) {
        token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
      }
    }
    if (token == null) {
      throw Exception('Token not available. We are fucked!');
    }
    final mUrl = '${KasieEnvironment.getUrl()}'
        'getAssociationRouteZippedFile?associationId=2f3faebd-6159-4b03-9857-9dad6d9a82ac';

    final bodyBytes = await httpGet(mUrl, token);
    debugPrint(
        '$xyz _getRouteBag: 🔆🔆🔆 get zipped data, bodyBytes: ${bodyBytes.length} bytes ...');

    final Archive archive = ZipDecoder().decodeBytes(bodyBytes);
    debugPrint('$xyz ... do we have a file? ${archive.files.length} files in archive');
    debugPrint(
        '$xyz _getRouteBag: 🔆🔆🔆 handle file inside zip: ${archive.length} bytes');

    for (var file in archive.files) {
      if (file.isFile) {
        debugPrint(
            '$xyz getRouteBags: file from inside archive ... ${file.size} '
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
        debugPrint(
            '$xyz _getRouteBag 🍎🍎🍎🍎 work is done!, elapsed seconds: 🍎$ms 🍎bags done: ${bags.length}\n\n');

        return bags;
      }
    }
    throw Exception('Something went wrong');
  }
  File createFileFromBytes(Uint8List bytes) => File.fromRawPath(bytes);

}
