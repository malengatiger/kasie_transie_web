import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_departure.g.dart';

@JsonSerializable()

class VehicleDeparture {
  String? vehicleDepartureId;
  String? landmarkId;
  String? landmarkName;
  Position? position;
  String? geoHash;
  String? created;
  String? vehicleId;
  String? associationId;
  String? associationName;
  String? vehicleReg;
  String? make;
  String? model;
  String? ownerId, ownerName;
  bool? dispatched;

  VehicleDeparture({
      required this.vehicleDepartureId,
      required this.landmarkId,
      required this.landmarkName,
      required this.position,
      required this.geoHash,
      required this.created,
      required this.vehicleId,
      required this.associationId,
      required this.associationName,
      required this.vehicleReg,
      required this.make,
      required this.model,
      required this.ownerId,
      required this.ownerName,
      required this.dispatched});

  factory VehicleDeparture.fromJson(Map<String, dynamic> json) => _$VehicleDepartureFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleDepartureToJson(this);

}
