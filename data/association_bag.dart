import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/vehicle_arrival.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'ambassador_passenger_count.dart';
import 'commuter_request.dart';
import 'dispatch_record.dart';

part 'association_bag.g.dart';

@JsonSerializable()
class AssociationBag {
  List<CommuterRequest> commuterRequests = [];
  List<AmbassadorPassengerCount> passengerCounts = [];
  List<VehicleHeartbeat> heartbeats = [];
  List<VehicleArrival> arrivals = [];
  List<VehicleDeparture> departures = [];
  List<DispatchRecord> dispatchRecords = [];

  AssociationBag(
      {required this.commuterRequests,
      required this.passengerCounts,
      required this.heartbeats,
      required this.arrivals,
      required this.departures,
      required this.dispatchRecords});

  factory AssociationBag.fromJson(Map<String, dynamic> json) =>
      _$AssociationBagFromJson(json);

  Map<String, dynamic> toJson() => _$AssociationBagToJson(this);
}
