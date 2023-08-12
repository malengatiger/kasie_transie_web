import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_landmark.g.dart';

@JsonSerializable()
class RouteLandmark {
  String? routeId;
  String? routeName;
  String? landmarkId;
  String? landmarkName;
  String? created;
  String? associationId;
  String? routePointId;
  int? routePointIndex;
  int? index;
  Position? position;

  RouteLandmark({
      required this.routeId,
      required this.routeName,
      required this.landmarkId,
      required this.landmarkName,
      required this.created,
      required this.associationId,
      required this.routePointId,
      required this.routePointIndex,
      required this.index,
      required this.position});

  factory RouteLandmark.fromJson(Map<String, dynamic> json) => _$RouteLandmarkFromJson(json);
  Map<String, dynamic> toJson() => _$RouteLandmarkToJson(this);

}
