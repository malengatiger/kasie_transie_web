import 'package:kasie_transie_web/data/route.dart';
import 'package:kasie_transie_web/data/route_city.dart';
import 'package:kasie_transie_web/data/route_landmark.dart';
import 'package:kasie_transie_web/data/route_point.dart';

import 'package:json_annotation/json_annotation.dart';

part 'route_bag.g.dart';

@JsonSerializable()
class RouteBag {
  Route? route;
  List<RouteLandmark> routeLandmarks = [];
  List<RoutePoint> routePoints = [];
  List<RouteCity> routeCities = [];

  RouteBag({this.route, required this.routeLandmarks, required this.routePoints, required this.routeCities});

  factory RouteBag.fromJson(Map<String, dynamic> json) => _$RouteBagFromJson(json);
  Map<String, dynamic> toJson() => _$RouteBagToJson(this);

}
