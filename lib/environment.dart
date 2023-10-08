import 'package:flutter/foundation.dart';

class KasieEnvironment {
  static const _currentStatus = 'prod';
  // static const _currentStatus = 'dev';
  //
  static const _devUrl = 'http://192.168.86.242:5050/api/v1/';
  // static const _devUrl = 'http://172.20.10.10:8080/';

  static String getUrl() {
    if (kDebugMode) {
      return _devUrl;
    } else {
      return 'https://kasie-nest-3-umrjnxdnuq-ew.a.run.app/';

    }
  }
}
