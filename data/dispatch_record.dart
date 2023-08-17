import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/position.dart';

part 'dispatch_record.g.dart';

@JsonSerializable()

class DispatchRecord {
  String? dispatchRecordId;
  String? marshalId;
  int? passengers;
  String? ownerId;
  String? created;
  Position? position;
  String? geoHash;
  String? landmarkName;
  String? marshalName;
  String? routeName;
  String? routeId;
  String? vehicleId;
  String? vehicleArrivalId;
  String? vehicleReg;
  String? associationId;
  String? associationName;
  String? routeLandmarkId;
  bool? dispatched;

  DispatchRecord({
      required this.dispatchRecordId,
      required this.marshalId,
      required this.passengers,
      required this.ownerId,
      required this.created,
      required this.position,
      required this.geoHash,
      required this.landmarkName,
      required this.marshalName,
      required this.routeName,
      required this.routeId,
      required this.vehicleArrivalId,
      required this.associationId,
      required this.associationName,
      required this.dispatched});
  factory DispatchRecord.fromJson(Map<String, dynamic> json) => _$DispatchRecordFromJson(json);
  Map<String, dynamic> toJson() => _$DispatchRecordToJson(this);

}
