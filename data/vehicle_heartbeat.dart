import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_heartbeat.g.dart';

@JsonSerializable()

class VehicleHeartbeat {
  String? vehicleHeartbeatId;

  Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  int? longDate;
  bool? appToBackground = false;

  VehicleHeartbeat({
      required this.vehicleHeartbeatId,
      required this.position,
      required this.geoHash,
      required this.created,
      required this.vehicleId,
      required this.associationId,
      required this.vehicleReg,
      required this.make,
      required this.model,
      required this.ownerId,
      required this.ownerName,
      required this.longDate,
      required this.appToBackground});
  
  factory VehicleHeartbeat.fromJson(Map<String, dynamic> json) => _$VehicleHeartbeatFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleHeartbeatToJson(this);

}
