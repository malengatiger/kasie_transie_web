import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route_start_end.g.dart';

@JsonSerializable(explicitToJson: true)
class RouteStartEnd {
  String? startCityId, startCityName;
  String? endCityId, endCityName;

  Position? startCityPosition;
  Position? endCityPosition;

  RouteStartEnd(
      {required this.startCityId,
      required this.startCityName,
      required this.endCityId,
      required this.endCityName,
      required this.startCityPosition,
      required this.endCityPosition});

  factory RouteStartEnd.fromJson(Map<String, dynamic> json) => _$RouteStartEndFromJson(json);
  Map<String, dynamic> toJson() => _$RouteStartEndToJson(this);

}
