import 'dart:convert';
import 'dart:html';
import 'dart:js' as js;
import '../blocs/stream_bloc.dart';
import '../data/user.dart';
import 'emojis.dart';
import 'functions.dart';

final JavascriptMessageUtil javascriptMessageUtil = JavascriptMessageUtil();

class JavascriptMessageUtil {
  final mm = ' 😡 😡 😡 😡 JavascriptMessageUtil: 😡';

  Future setupMessagingListeners(Window window) async {
    pp('$mm ... _setting up FCM Messaging Listeners to get messages via Javascript ...');
    // Set up the service worker to listen for FCM messages
    if (window.navigator.serviceWorker != null) {
      final sw = await window.navigator.serviceWorker!
          .register('firebase-messaging-sw.js');
      pp('$mm Service Worker registered with scope: ${sw.scope} - '
          '${E.heartBlue} activated: ${sw.active?.state}');
      // Listen for messages from the service worker
      sw.addEventListener('message', (event) {
        final dynamic message = jsonDecode(event as String);
        pp('$mm Received message from service worker: ${E.leaf} $message ${E.leaf}');
        // Handle the FCM message here
      });
      //

      // Notify the service worker that the Dart app is ready
      // window.navigator.serviceWorker!.ready.then((registration) {
      //   registration.active!.postMessage('Dart app is ready');
      // });
      window.navigator.serviceWorker!.ready.then((registration) {
        pp(' ... registration.active!.state: ${registration.active!.state}');
        registration.active!.postMessage('register');
      });

      //listen for fcm messages
      window.onMessage.listen((event) {
        final dynamic message = event.data;
        pp('$mm .......................................${E.redDot}'
            ' message received, will be shipped to StreamBloc');
        final m = message['mData']['data'];
        streamBloc.processFCMessage(_convertDynamicMap(m));
      });
    } else {
      pp('$mm ... _setupMessagingListeners NOT set up. ${E.redDot} ${E.redDot} ');
      return;
    }
    pp('$mm Service Worker set up to receive messages ${E.leaf}${E.leaf}${E.leaf}');
  }

  Map<String, dynamic> _convertDynamicMap(Map<dynamic, dynamic> dynamicMap) {
    final convertedMap = <String, dynamic>{};
    dynamicMap.forEach((key, value) {
      if (key is String) {
        convertedMap[key] = value;
      } else {
        // Handle key conversion if needed
        convertedMap[key.toString()] = value;
      }
    });
    return convertedMap;
  }

  Future getTokenAndData(Window window, User user) async {
    await GetToken.getToken(user);
    setupMessagingListeners(window);
  }
}

class GetToken {
  static Future<String> getToken(User user) async {
    // Call the JavaScript function to send associationId and get token
    pp('GetToken: calling Javascript: 🔴 🔴 🔴 🔴 ..... sending associationId: '
        '💪 ${user.associationId} 💪');
    final result = await js.context.callMethod('fetchTokenAndSend', [user.associationId!, user.userId]);
    return "We good, Boss! 🔴 🔴 🔴 🔴 $result";
  }
}
