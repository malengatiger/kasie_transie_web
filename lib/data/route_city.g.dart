// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteCity _$RouteCityFromJson(Map<String, dynamic> json) => RouteCity(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      cityId: json['cityId'] as String?,
      cityName: json['cityName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteCityToJson(RouteCity instance) => <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'cityId': instance.cityId,
      'cityName': instance.cityName,
      'created': instance.created,
      'associationId': instance.associationId,
      'position': instance.position?.toJson(),
    };
