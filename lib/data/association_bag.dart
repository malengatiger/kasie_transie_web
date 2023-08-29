import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/vehicle_arrival.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/dispatch_record.dart';
import 'package:json_annotation/json_annotation.dart';

part 'association_bag.g.dart';


@JsonSerializable(explicitToJson: true)
class AssociationBag {
  List<AmbassadorPassengerCount> passengerCounts = [];
  List<VehicleHeartbeat> heartbeats = [];
  List<VehicleArrival> arrivals = [];
  List<VehicleDeparture> departures = [];
  List<DispatchRecord> dispatchRecords = [];
  List<CommuterRequest> commuterRequests = [];

  AssociationBag(
      {required this.passengerCounts,
      required this.heartbeats,
      required this.arrivals,
      required this.departures,
      required this.commuterRequests,
      required this.dispatchRecords});

  factory AssociationBag.fromJson(Map<String, dynamic> json) =>
      _$AssociationBagFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationBagToJson(this);

  bool isEmpty() {
    if (passengerCounts.isNotEmpty) {
      return false;
    }
    if (heartbeats.isNotEmpty) {
      return false;
    }
    if (arrivals.isNotEmpty) {
      return false;
    }
    if (departures.isNotEmpty) {
      return false;
    }
    if (commuterRequests.isNotEmpty) {
      return false;
    }
    if (dispatchRecords.isNotEmpty) {
      return false;
    }
    return true;
  }
}
