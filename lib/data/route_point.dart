import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_point.g.dart';

@JsonSerializable()
class RoutePoint {
  String? routePointId;
  String? associationId;
  double? latitude;
  double? longitude;
  double? heading;
  int? index;
  String? created;
  String? routeId;
  String? routeName;
  Position? position;

  RoutePoint({
      required this.routePointId,
      required this.associationId,
      required this.latitude,
      required this.longitude,
      required this.heading,
      required this.index,
      required this.created,
      required this.routeId,
      required this.routeName,
      required this.position});
  factory RoutePoint.fromJson(Map<String, dynamic> json) => _$RoutePointFromJson(json);
  Map<String, dynamic> toJson() => _$RoutePointToJson(this);

}
