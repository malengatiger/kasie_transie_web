import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'commuter_request.g.dart';

@JsonSerializable()

class CommuterRequest {
  String? commuterId;
  String? commuterRequestId, routeId;
  String? routeName;
  String? dateRequested;
  String? routeLandmarkId;
  String? routeLandmarkName;
  String? associationId;
  String? dateNeeded;
  bool? scanned;

  Position? currentPosition;
  int? routePointIndex, numberOfPassengers;
  double? distanceToRouteLandmarkInMetres, distanceToRoutePointInMetres;

  CommuterRequest({
      required this.commuterId,
      required this.commuterRequestId,
      required this.routeId,
      required this.routeName,
      required this.dateRequested,
      required this.routeLandmarkId,
      required this.routeLandmarkName,
      required this.associationId,
      required this.dateNeeded,
      required this.scanned,
      required this.currentPosition,
      required this.routePointIndex,
      required this.numberOfPassengers,
      required this.distanceToRouteLandmarkInMetres,
      required this.distanceToRoutePointInMetres});
  factory CommuterRequest.fromJson(Map<String, dynamic> json) => _$CommuterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CommuterRequestToJson(this);

}
