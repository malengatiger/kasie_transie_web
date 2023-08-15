import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../data/ambassador_passenger_count.dart';
import '../data/commuter_request.dart';
import '../data/dispatch_record.dart';
import '../data/location_request.dart';
import '../data/location_response.dart';
import '../data/route_update_request.dart';
import '../data/vehicle_arrival.dart';
import '../data/vehicle_departure.dart';
import '../data/vehicle_heartbeat.dart';
import '../data/vehicle_media_request.dart';
import '../utils/constants.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';

final FcmBloc fcmBloc = FcmBloc();

class FcmBloc {
  final mm = '${E.broc}${E.broc}${E.broc}${E.broc} FcmBloc: ${E.broc}${E.broc}';

  initialize() async {
    pp('\n\n$mm ... initialize FCM .......: ${E.blueDot}${E.blueDot}');

    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      pp('$mm ... onTokenRefresh: will add association token to backend; '
          '${E.blueDot} \ntoken: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      pp('$mm ... ${E.blueDot} onMessage: data: ${message.data}');
      pp('$mm ... ${E.blueDot} onMessage: senderId: ${message.senderId}');

    });

    pp('$mm ... initialize FCM COMPLETE! will listen to all FCM messages ${E.blueDot} ');
  }


  void processFCMessage(Map<String, dynamic> data) {
    final type = getMessageType(data);
    pp('$mm ... processFCMessage: message type: ${E.blueDot} $type');

    switch (type) {
      case Constants.heartbeat:
        final m = VehicleHeartbeat.fromJson(data);
        _heartbeatStreamController.sink.add(m);
        break;
      case Constants.locationResponse:
        
        final m = LocationResponse.fromJson(data);
        _locationResponseStreamController.sink.add(m);
        break;
      case Constants.dispatchRecord:
        
        final m = DispatchRecord.fromJson(data);
        _dispatchStreamController.sink.add(m);
        break;
      case Constants.vehicleArrival:
        
        final m = VehicleArrival.fromJson(data);
        _vehicleArrivalStreamController.sink.add(m);
        break;
      case Constants.vehicleChanges:
        //todo - implement vehicle changes message
        break;
      case Constants.vehicleDeparture:
        
        final m = VehicleDeparture.fromJson(data);
        _vehicleDepartureStreamController.sink.add(m);
        break;
      case Constants.vehicleMediaRequest:
        
        final m = VehicleMediaRequest.fromJson(data);
        _vehicleMediaRequestStreamController.sink.add(m);
        break;
      case Constants.passengerCount:
        
        final m = AmbassadorPassengerCount.fromJson(data);
        _passengerCountStreamController.sink.add(m);
        break;
      case Constants.commuterRequest:
        
        final m = CommuterRequest.fromJson(data);
        _commuterRequestStreamController.sink.add(m);
        break;
      case Constants.locationRequest:
        
        final m = LocationRequest.fromJson(data);
        _locationRequestStreamController.sink.add(m);
        break;
      case Constants.routeUpdateRequest:
        
        final m = RouteUpdateRequest.fromJson(data);
        _routeUpdateRequestStreamController.sink.add(m);
        //todo - go ahead and refresh the route
        break;
      case Constants.userGeofenceEvent:
        //todo - implement userGeofenceEvent messaging - HOT, may not do it!
        break;
    }
  }

  String getMessageType(Map<dynamic, dynamic> message) {
    var type = '';
    if (message[Constants.routeUpdateRequest] != null) {
      //pp("$mm onMessage: $red routeChanges message has arrived!  ... $red ");
      type = Constants.routeUpdateRequest;
    } else if (message[Constants.vehicleChanges] != null) {
      //pp("$mm onMessage: $red vehicleChanges message has arrived!  ... $red ");
      type = Constants.vehicleChanges;
    } else if (message[Constants.locationRequest] != null) {
      //pp("$mm onMessage: $red locationRequest message has arrived!  ... $red ");
      type = Constants.locationRequest;
    } else if (message[Constants.locationResponse] != null) {
      //pp("$mm onMessage: $red locationResponse message has arrived!  ... $red ");
      type = Constants.locationResponse;
    } else if (message[Constants.vehicleArrival] != null) {
      //pp("$mm onMessage: $red vehicleArrival message has arrived!  ... $red\n ");
      type = Constants.vehicleArrival;
    } else if (message[Constants.vehicleDeparture] != null) {
      //pp("$mm onMessage: $red vehicleDeparture message has arrived!  ... $red ");
      type = Constants.vehicleDeparture;
    } else if (message[Constants.dispatchRecord] != null) {
      //pp("$mm onMessage: $red dispatchRecord message has arrived!  ... $red ");
      type = Constants.dispatchRecord;
    } else if (message[Constants.userGeofenceEvent] != null) {
      //pp("$mm onMessage: $red userGeofenceEvent message has arrived!  ... $red ");
      type = Constants.userGeofenceEvent;
    } else if (message[Constants.vehicleMediaRequest] != null) {
      //pp("$mm onMessage: $red vehicleMediaRequest message has arrived!  ... $red ");
      type = Constants.vehicleMediaRequest;
    } else if (message[Constants.passengerCount] != null) {
      //pp("$mm onMessage: $red passengerCount message has arrived!  ... $red ");
      type = Constants.passengerCount;
    } else if (message[Constants.heartbeat] != null) {
      //pp("$mm onMessage: $red heartbeat message has arrived!  ... $red ");
      type = Constants.heartbeat;
    } else if (message[Constants.commuterRequest] != null) {
      //pp("$mm onMessage: $red commuterRequest message has arrived!  ... $red ");
      type = Constants.commuterRequest;
    } else if (message[Constants.routeUpdateRequest] != null) {
      //pp("$mm onMessage: $red routeUpdateRequest message has arrived!  ... $red ");
      type = Constants.routeUpdateRequest;
    } else {
      pp("$mm onMessage: unknown message has arrived!  ...");
      myPrettyJsonPrint(message);
      return 'unknown';
    }
    return type;
  }

  final StreamController<String> _routeChangesStreamController =
      StreamController.broadcast();

  Stream<String> get routeChangesStream => _routeChangesStreamController.stream;

  final StreamController<String> _vehicleChangesStreamController =
      StreamController.broadcast();

  Stream<String> get vehicleChangesStream =>
      _vehicleChangesStreamController.stream;

  final StreamController<VehicleDeparture> _vehicleDepartureStreamController =
      StreamController.broadcast();

  Stream<VehicleDeparture> get vehicleDepartureStream =>
      _vehicleDepartureStreamController.stream;

  final StreamController<VehicleArrival> _vehicleArrivalStreamController =
      StreamController.broadcast();

  Stream<VehicleArrival> get vehicleArrivalStream =>
      _vehicleArrivalStreamController.stream;

  final StreamController<DispatchRecord> _dispatchStreamController =
      StreamController.broadcast();

  Stream<DispatchRecord> get dispatchStream => _dispatchStreamController.stream;

  // final StreamController<UserGeofenceEvent> _userGeofenceStreamController =
  // StreamController.broadcast();
  //
  // Stream<UserGeofenceEvent> get userGeofenceStream =>
  //     _userGeofenceStreamController.stream;

  final StreamController<VehicleMediaRequest>
      _vehicleMediaRequestStreamController = StreamController.broadcast();
  final StreamController<RouteUpdateRequest>
      _routeUpdateRequestStreamController = StreamController.broadcast();

  final StreamController<CommuterRequest> _commuterRequestStreamController =
      StreamController.broadcast();

  Stream<CommuterRequest> get commuterRequestStreamStream =>
      _commuterRequestStreamController.stream;

  final StreamController<VehicleHeartbeat> _heartbeatStreamController =
      StreamController.broadcast();

  Stream<VehicleHeartbeat> get heartbeatStreamStream =>
      _heartbeatStreamController.stream;

  Stream<RouteUpdateRequest> get routeUpdateRequestStream =>
      _routeUpdateRequestStreamController.stream;

  Stream<VehicleMediaRequest> get vehicleMediaRequestStream =>
      _vehicleMediaRequestStreamController.stream;

  final StreamController<LocationRequest> _locationRequestStreamController =
      StreamController.broadcast();

  Stream<LocationRequest> get locationRequestStream =>
      _locationRequestStreamController.stream;

  final StreamController<LocationResponse> _locationResponseStreamController =
      StreamController.broadcast();

  Stream<LocationResponse> get locationResponseStream =>
      _locationResponseStreamController.stream;

  final StreamController<AmbassadorPassengerCount>
      _passengerCountStreamController = StreamController.broadcast();

  Stream<AmbassadorPassengerCount> get passengerCountStream =>
      _passengerCountStreamController.stream;
}
