import 'package:json_annotation/json_annotation.dart';

part 'location_request.g.dart';

@JsonSerializable(explicitToJson: true)

class LocationRequest {
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;

  LocationRequest(
      {required this.vehicleId,
      required this.vehicleReg,
      required this.userId,
      required this.userName,
      required this.created,
      required this.associationId});

  factory LocationRequest.fromJson(Map<String, dynamic> json) => _$LocationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LocationRequestToJson(this);

}
