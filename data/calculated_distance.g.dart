// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculated_distance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalculatedDistance _$CalculatedDistanceFromJson(Map<String, dynamic> json) =>
    CalculatedDistance(
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      fromLandmark: json['fromLandmark'] as String?,
      toLandmark: json['toLandmark'] as String?,
      fromLandmarkId: json['fromLandmarkId'] as String?,
      toLandmarkId: json['toLandmarkId'] as String?,
      associationId: json['associationId'] as String?,
      distanceInMetres: (json['distanceInMetres'] as num?)?.toDouble(),
      distanceFromStart: (json['distanceFromStart'] as num?)?.toDouble(),
      fromRoutePointIndex: json['fromRoutePointIndex'] as int?,
      toRoutePointIndex: json['toRoutePointIndex'] as int?,
      index: json['index'] as int?,
    );

Map<String, dynamic> _$CalculatedDistanceToJson(CalculatedDistance instance) =>
    <String, dynamic>{
      'routeName': instance.routeName,
      'routeId': instance.routeId,
      'fromLandmark': instance.fromLandmark,
      'toLandmark': instance.toLandmark,
      'fromLandmarkId': instance.fromLandmarkId,
      'toLandmarkId': instance.toLandmarkId,
      'associationId': instance.associationId,
      'distanceInMetres': instance.distanceInMetres,
      'distanceFromStart': instance.distanceFromStart,
      'fromRoutePointIndex': instance.fromRoutePointIndex,
      'toRoutePointIndex': instance.toRoutePointIndex,
      'index': instance.index,
    };
