// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_start_end.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteStartEnd _$RouteStartEndFromJson(Map<String, dynamic> json) =>
    RouteStartEnd(
      startCityId: json['startCityId'] as String?,
      startCityName: json['startCityName'] as String?,
      endCityId: json['endCityId'] as String?,
      endCityName: json['endCityName'] as String?,
      startCityPosition: json['startCityPosition'] == null
          ? null
          : Position.fromJson(
              json['startCityPosition'] as Map<String, dynamic>),
      endCityPosition: json['endCityPosition'] == null
          ? null
          : Position.fromJson(json['endCityPosition'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteStartEndToJson(RouteStartEnd instance) =>
    <String, dynamic>{
      'startCityId': instance.startCityId,
      'startCityName': instance.startCityName,
      'endCityId': instance.endCityId,
      'endCityName': instance.endCityName,
      'startCityPosition': instance.startCityPosition,
      'endCityPosition': instance.endCityPosition,
    };
