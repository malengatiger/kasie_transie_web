// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_bag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteBag _$RouteBagFromJson(Map<String, dynamic> json) => RouteBag(
      route: json['route'] == null
          ? null
          : Route.fromJson(json['route'] as Map<String, dynamic>),
      routeLandmarks: (json['routeLandmarks'] as List<dynamic>)
          .map((e) => RouteLandmark.fromJson(e as Map<String, dynamic>))
          .toList(),
      routePoints: (json['routePoints'] as List<dynamic>)
          .map((e) => RoutePoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      routeCities: (json['routeCities'] as List<dynamic>)
          .map((e) => RouteCity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteBagToJson(RouteBag instance) => <String, dynamic>{
      'route': instance.route?.toJson(),
      'routeLandmarks': instance.routeLandmarks.map((e) => e.toJson()).toList(),
      'routePoints': instance.routePoints.map((e) => e.toJson()).toList(),
      'routeCities': instance.routeCities.map((e) => e.toJson()).toList(),
    };
