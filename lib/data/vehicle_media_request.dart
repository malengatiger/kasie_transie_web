import 'package:json_annotation/json_annotation.dart';

part 'vehicle_media_request.g.dart';

@JsonSerializable()

class VehicleMediaRequest {
  String? userId;
  String? vehicleId;
  String? vehicleReg;
  String? requesterId;
  String? created;
  String? associationId;
  String? requesterName;

  VehicleMediaRequest(
      {required this.userId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.requesterId,
      required this.created,
      required this.associationId,
      required this.requesterName});

  factory VehicleMediaRequest.fromJson(Map<String, dynamic> json) => _$VehicleMediaRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleMediaRequestToJson(this);

}
