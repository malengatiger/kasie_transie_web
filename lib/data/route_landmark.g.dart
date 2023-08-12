// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_landmark.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteLandmark _$RouteLandmarkFromJson(Map<String, dynamic> json) =>
    RouteLandmark(
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      routePointId: json['routePointId'] as String?,
      routePointIndex: json['routePointIndex'] as int?,
      index: json['index'] as int?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteLandmarkToJson(RouteLandmark instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'created': instance.created,
      'associationId': instance.associationId,
      'routePointId': instance.routePointId,
      'routePointIndex': instance.routePointIndex,
      'index': instance.index,
      'position': instance.position,
    };
