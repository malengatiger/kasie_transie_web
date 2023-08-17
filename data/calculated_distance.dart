import 'package:json_annotation/json_annotation.dart';

part 'calculated_distance.g.dart';

@JsonSerializable()
class CalculatedDistance {
  String? routeName, routeId;
  String? fromLandmark, toLandmark, fromLandmarkId, toLandmarkId, associationId;
  double? distanceInMetres, distanceFromStart;
  int? fromRoutePointIndex, toRoutePointIndex, index;

  CalculatedDistance({
      required this.routeName,
      required this.routeId,
      required this.fromLandmark,
      required this.toLandmark,
      required this.fromLandmarkId,
      required this.toLandmarkId,
      required this.associationId,
      required this.distanceInMetres,
      required this.distanceFromStart,
      required this.fromRoutePointIndex,
      required this.toRoutePointIndex,
      required this.index});

  factory CalculatedDistance.fromJson(Map<String, dynamic> json) => _$CalculatedDistanceFromJson(json);
  Map<String, dynamic> toJson() => _$CalculatedDistanceToJson(this);

}
