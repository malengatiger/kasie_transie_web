import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_city.g.dart';

@JsonSerializable()
class RouteCity {
  String? routeId;
  String? routeName;
  String? cityId;
  String? cityName;
  String? created;
  String? associationId;
  Position? position;

  RouteCity({this.routeId, this.routeName, this.cityId, this.cityName,
      this.created, this.associationId, this.position});
  factory RouteCity.fromJson(Map<String, dynamic> json) => _$RouteCityFromJson(json);
  Map<String, dynamic> toJson() => _$RouteCityToJson(this);

}
