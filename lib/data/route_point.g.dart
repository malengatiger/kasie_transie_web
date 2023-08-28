// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) => RoutePoint(
      routePointId: json['routePointId'] as String?,
      associationId: json['associationId'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      index: json['index'] as int?,
      created: json['created'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RoutePointToJson(RoutePoint instance) =>
    <String, dynamic>{
      'routePointId': instance.routePointId,
      'associationId': instance.associationId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'heading': instance.heading,
      'index': instance.index,
      'created': instance.created,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'position': instance.position?.toJson(),
    };
