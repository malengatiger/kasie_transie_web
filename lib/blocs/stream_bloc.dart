

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

final StreamBloc streamBloc = StreamBloc();

class StreamBloc {
  final mm = '${E.broc}${E.broc}${E.broc}${E.broc} StreamBloc: ${E.broc}${E.broc}';

  StreamBloc() {
    pp('$mm ......... StreamBloc constructor ... ${E.appleRed}');
  }

  void processFCMessage(Map<String, dynamic> data) {
    final type = getMessageType(data);
    pp('$mm ... processFCMessage: message type: ${E.blueDot}${E.blueDot}${E.blueDot} $type');

    switch (type) {
      case Constants.heartbeat:
        final json = jsonDecode(data[type]);
        final m = VehicleHeartbeat.fromJson(json);
        _heartbeatStreamController.sink.add(m);
        break;
      case Constants.locationResponse:
        final json = jsonDecode(data[type]);
        final m = LocationResponse.fromJson(json);
        _locationResponseStreamController.sink.add(m);
        break;
      case Constants.dispatchRecord:
        final json = jsonDecode(data[type]);
        final m = DispatchRecord.fromJson(json);
        _dispatchStreamController.sink.add(m);
        break;
      case Constants.vehicleArrival:
        final json = jsonDecode(data[type]);
        final m = VehicleArrival.fromJson(json);
        _vehicleArrivalStreamController.sink.add(m);
        break;
      case Constants.vehicleChanges:
        //todo - implement vehicle changes message
        break;
      case Constants.vehicleDeparture:
        final json = jsonDecode(data[type]);
        final m = VehicleDeparture.fromJson(json);
        _vehicleDepartureStreamController.sink.add(m);
        break;
      case Constants.vehicleMediaRequest:
        final json = jsonDecode(data[type]);
        final m = VehicleMediaRequest.fromJson(json);
        _vehicleMediaRequestStreamController.sink.add(m);
        break;
      case Constants.passengerCount:
        final json = jsonDecode(data[type]);
        final m = AmbassadorPassengerCount.fromJson(json);
        _passengerCountStreamController.sink.add(m);
        break;
      case Constants.commuterRequest:
        final json = jsonDecode(data[type]);
        final m = CommuterRequest.fromJson(json);
        _commuterRequestStreamController.sink.add(m);
        break;
      case Constants.locationRequest:
        final json = jsonDecode(data[type]);
        final m = LocationRequest.fromJson(json);
        _locationRequestStreamController.sink.add(m);
        break;
      case Constants.routeUpdateRequest:
        final json = jsonDecode(data[type]);
        final m = RouteUpdateRequest.fromJson(json);
        _routeUpdateRequestStreamController.sink.add(m);
        //todo - go ahead and refresh the route
        break;
      case Constants.userGeofenceEvent:
        //todo - implement userGeofenceEvent messaging - HOT, may not do it!
        break;
      default:
        pp('${E.redDot}${E.redDot}${E.redDot} Unknown type: please check: $data');
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
    } else if (message[Constants.dispatchRecord] != null) {
      //pp("$mm onMessage: $red commuterRequest message has arrived!  ... $red ");
      type = Constants.dispatchRecord;
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
