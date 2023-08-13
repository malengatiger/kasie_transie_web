// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commuter_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommuterRequest _$CommuterRequestFromJson(Map<String, dynamic> json) =>
    CommuterRequest(
      commuterId: json['commuterId'] as String?,
      commuterRequestId: json['commuterRequestId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      dateRequested: json['dateRequested'] as String?,
      routeLandmarkId: json['routeLandmarkId'] as String?,
      routeLandmarkName: json['routeLandmarkName'] as String?,
      associationId: json['associationId'] as String?,
      dateNeeded: json['dateNeeded'] as String?,
      scanned: json['scanned'] as bool?,
      currentPosition: json['currentPosition'] == null
          ? null
          : Position.fromJson(json['currentPosition'] as Map<String, dynamic>),
      routePointIndex: json['routePointIndex'] as int?,
      numberOfPassengers: json['numberOfPassengers'] as int?,
      distanceToRouteLandmarkInMetres:
          (json['distanceToRouteLandmarkInMetres'] as num?)?.toDouble(),
      distanceToRoutePointInMetres:
          (json['distanceToRoutePointInMetres'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CommuterRequestToJson(CommuterRequest instance) =>
    <String, dynamic>{
      'commuterId': instance.commuterId,
      'commuterRequestId': instance.commuterRequestId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'dateRequested': instance.dateRequested,
      'routeLandmarkId': instance.routeLandmarkId,
      'routeLandmarkName': instance.routeLandmarkName,
      'associationId': instance.associationId,
      'dateNeeded': instance.dateNeeded,
      'scanned': instance.scanned,
      'currentPosition': instance.currentPosition,
      'routePointIndex': instance.routePointIndex,
      'numberOfPassengers': instance.numberOfPassengers,
      'distanceToRouteLandmarkInMetres':
          instance.distanceToRouteLandmarkInMetres,
      'distanceToRoutePointInMetres': instance.distanceToRoutePointInMetres,
    };
