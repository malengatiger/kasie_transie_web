import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationResponse {
  String? userId;
  String? vehicleId, vehicleReg;
  String? geoHash;
  String? userName;
  String? created;
  String? associationId;
  Position? position;

  LocationResponse(
      {required this.userId,
      required this.vehicleId,
      required this.vehicleReg,
      required this.geoHash,
      required this.userName,
      required this.created,
      required this.associationId,
      required this.position});

  factory LocationResponse.fromJson(Map<String, dynamic> json) => _$LocationResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LocationResponseToJson(this);

}
