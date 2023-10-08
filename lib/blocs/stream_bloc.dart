import 'dart:async';
import 'dart:convert';
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
  final mm =
      '${E.broc}${E.broc}${E.broc}${E.broc} StreamBloc: ${E.broc}${E.broc}';

  StreamBloc() {
    pp('$mm ......... StreamBloc constructor ... ${E.appleRed}');
  }

  void processFCMessage(Map<String, dynamic> map) {
    //myPrettyJsonPrint(map);
    final type = map['type'];
    pp('$mm ... process FCM message: message type: ${E.blueDot}${E.blueDot}${E.blueDot} $type');

    try {
      final json = jsonDecode(map['data']);
      //myPrettyJsonPrint(json);
      switch (type) {
        case Constants.heartbeat:
          final m = VehicleHeartbeat.fromJson(json);
          _heartbeatStreamController.sink.add(m);
          return;
        case Constants.locationResponse:
          final m = LocationResponse.fromJson(json);
          _locationResponseStreamController.sink.add(m);
          return;
        case Constants.dispatchRecord:
          final m = DispatchRecord.fromJson(json);
          _dispatchStreamController.sink.add(m);
          return;
        case Constants.vehicleArrival:
          final m = VehicleArrival.fromJson(json);
          _vehicleArrivalStreamController.sink.add(m);
          return;
        case Constants.vehicleChanges:
          //todo - implement vehicle changes message
          return;
        case Constants.vehicleDeparture:
          final m = VehicleDeparture.fromJson(json);
          _vehicleDepartureStreamController.sink.add(m);
          return;
        case Constants.vehicleMediaRequest:
          final m = VehicleMediaRequest.fromJson(json);
          _vehicleMediaRequestStreamController.sink.add(m);
          return;
        case Constants.passengerCount:
          final m = AmbassadorPassengerCount.fromJson(json);
          _passengerCountStreamController.sink.add(m);
          return;
        case Constants.commuterRequest:
          final m = CommuterRequest.fromJson(json);
          _commuterRequestStreamController.sink.add(m);
          return;
        case Constants.locationRequest:
          final m = LocationRequest.fromJson(json);
          _locationRequestStreamController.sink.add(m);
          return;
        case Constants.routeUpdateRequest:
          final m = RouteUpdateRequest.fromJson(json);
          _routeUpdateRequestStreamController.sink.add(m);
          //todo - go ahead and refresh the route
          return;
        case Constants.userGeofenceEvent:
          //todo - implement userGeofenceEvent messaging - HOT, may not do it!
          return;
        default:
          pp('${E.redDot}${E.redDot}${E.redDot} Unknown type: please check: $json');
      }
    } catch (e, s) {
      pp('ERROR: ${E.redDot}${E.redDot}${E.redDot} $e - $s');
    }
  }

  String getMessageType(Map<dynamic, dynamic> message) {
    var type = message['type'];
    pp('${E.redDot}${E.redDot}${E.redDot} message type arrived:  $type');

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
