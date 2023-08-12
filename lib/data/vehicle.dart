import 'package:json_annotation/json_annotation.dart';

part 'vehicle.g.dart';

@JsonSerializable()
class Vehicle {
  String? vehicleId;
  String? countryId, ownerName, ownerId;
  String? created, dateInstalled;
  String? vehicleReg;
  String? make;
  String? model;
  String? year;
  String? qrCodeUrl;
  int? passengerCapacity;
  String? associationId, associationName;

  Vehicle({
      required this.vehicleId,
      required this.countryId,
      required this.ownerName,
      required this.ownerId,
      required this.created,
      required this.dateInstalled,
      required this.vehicleReg,
      required this.make,
      required this.model,
      required this.year,
      required this.qrCodeUrl,
      required this.passengerCapacity,
      required this.associationId,
      required this.associationName});
  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);

}
