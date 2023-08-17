// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteUpdateRequest _$RouteUpdateRequestFromJson(Map<String, dynamic> json) =>
    RouteUpdateRequest(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      userId: json['userId'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      userName: json['userName'] as String?,
    );

Map<String, dynamic> _$RouteUpdateRequestToJson(RouteUpdateRequest instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'userId': instance.userId,
      'created': instance.created,
      'associationId': instance.associationId,
      'userName': instance.userName,
    };
