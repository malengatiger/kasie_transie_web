import 'package:kasie_transie_web/data/route_start_end.dart';
import 'package:json_annotation/json_annotation.dart';

part 'route.g.dart';

@JsonSerializable()
class Route {
  String? routeId;
  String? countryId, countryName, name, routeNumber;
  String? created, updated;
  String? color;
  bool? isActive;
  String? activationDate;
  String? associationId, associationName;
  double? heading;
  int? lengthInMetres;
  String? userId;
  String? userName;
  String? userUrl;
  RouteStartEnd? routeStartEnd;

  Route({
      required this.routeId,
      required this.countryId,
      required this.countryName,
      required this.name,
      required this.routeNumber,
      required this.created,
      required this.updated,
      required this.color,
      required this.isActive,
      required this.activationDate,
      required this.associationId,
      required this.associationName,
      required this.heading,
      required this.lengthInMetres,
      required this.userId,
      required this.userName,
      required this.userUrl,
      required this.routeStartEnd});

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);

}
