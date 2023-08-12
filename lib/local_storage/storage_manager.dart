

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

final StorageManager storageManager = StorageManager();

class StorageManager {
  static const mm = '🔵🔵🔵 StorageManager 🔵🔵';


  Future savePoints(Map<String, String> map) async {

    final sp = await SharedPreferences.getInstance();
    debugPrint('$mm points saved ....');

  }
  Future getPoints(String routeId) async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(routeId);
    debugPrint('$mm points retrieved : $s ....');
  }

  // Directory getTmpDir() => Directory.systemTemp.createTempSync();
}
