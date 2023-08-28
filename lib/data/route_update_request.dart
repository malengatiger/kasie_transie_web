import 'package:json_annotation/json_annotation.dart';

part 'route_update_request.g.dart';

@JsonSerializable(explicitToJson: true)

class RouteUpdateRequest {
  String? routeId;
  String? routeName;
  String? userId;
  String? created;
  String? associationId;
  String? userName;

  RouteUpdateRequest(
      {required this.routeId,
      required this.routeName,
      required this.userId,
      required this.created,
      required this.associationId,
      required this.userName});
  factory RouteUpdateRequest.fromJson(Map<String, dynamic> json) => _$RouteUpdateRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RouteUpdateRequestToJson(this);

}
