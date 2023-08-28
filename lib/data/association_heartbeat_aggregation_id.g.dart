// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_heartbeat_aggregation_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssociationHeartbeatAggregationId _$AssociationHeartbeatAggregationIdFromJson(
        Map<String, dynamic> json) =>
    AssociationHeartbeatAggregationId(
      json['year'] as int?,
      json['month'] as int?,
      json['day'] as int?,
      json['hour'] as int?,
      json['associationId'] as String?,
    );

Map<String, dynamic> _$AssociationHeartbeatAggregationIdToJson(
        AssociationHeartbeatAggregationId instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
      'hour': instance.hour,
      'associationId': instance.associationId,
    };
