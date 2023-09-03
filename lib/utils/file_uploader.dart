import 'dart:convert';
import 'dart:typed_data';

import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:http/http.dart' as http;
import 'package:kasie_transie_web/local_storage/storage_manager.dart';

import '../environment.dart';
import 'emojis.dart';
import 'functions.dart';

final FileUploader fileUploader = FileUploader();

class FileUploader {
  static const mm = '🔵🔵🔵🔵🔵 FileUploader 🔵🔵';

  Future<List<User>> uploadUserFile(
      {required String associationId, required Uint8List bytes, required String fileName}) async {
    var decoded = utf8.decode(bytes);
    pp('$mm contents of user file:${E.leaf}\n$decoded');
    List res = await _sendFile(
      fileName: fileName,
        associationId: associationId, bytes: bytes, query: 'uploadUserFile');
    pp('$mm ... uploadUserFile result: $res');
    final list = <User>[];
    for (var value in res) {
      list.add(User.fromJson(value));
    }
    await storageManager.addUsers(list);
    return list;
  }

  Future<List<Vehicle>> uploadVehicleFile( {required String associationId,
    required Uint8List bytes, required String fileName}) async {
    var decoded = utf8.decode(bytes);
    pp('$mm contents of car file:${E.leaf}\n$decoded');

    final res = await _sendFile(fileName: fileName,
        associationId: associationId, bytes: bytes, query: 'uploadVehicleFile');
    pp('$mm ... uploadVehicleFile result: $res');
    final list = <Vehicle>[];
    for (var value in res) {
      list.add(Vehicle.fromJson(value));
    }
    await storageManager.addVehicles(list);
    return list;
  }

  Future _sendFile(
      {required String associationId,
      required Uint8List bytes,
      required String query, required String fileName}) async {
    pp('$mm ... _sendFile ...........: $query bytes: ${bytes.length}');

    final url = KasieEnvironment.getUrl();
    final uri = Uri.parse('$url$query');
    var request = http.MultipartRequest('POST', uri);
    final multiPartFile = http.MultipartFile.fromBytes('document', bytes, filename: fileName);
    request.fields['associationId'] = associationId;
    request.files.add(multiPartFile);

    pp('$mm request fields: ${request.fields}');
    pp('$mm multiPartFile field: ${multiPartFile.field}');
    pp('$mm multiPartFile fileNme: ${multiPartFile.filename}');

    final response = await request.send();
    // Check if the request was successful (status code 200)
    if (response.statusCode == 200) {
      pp('$mm ... Request returned successfully: statusCode: ${response.statusCode}');
      final res = await response.stream.bytesToString();
      pp('$mm response body, OK! ${E.leaf}: $res');
      final map = jsonDecode(res);
      return map;
    } else {
      pp('$mm ... Request failed with status code: ${response.statusCode} ${response.reasonPhrase}');
      final res = await response.stream.bytesToString();
      pp('$mm response body containing error: ${E.redDot}$res');
      final map = jsonDecode(res);
      return map;
    }
    return response;
  }
}
