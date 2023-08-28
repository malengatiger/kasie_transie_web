// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_heartbeat_aggregation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssociationHeartbeatAggregationResult
    _$AssociationHeartbeatAggregationResultFromJson(
            Map<String, dynamic> json) =>
        AssociationHeartbeatAggregationResult(
          json['id'] == null
              ? null
              : AssociationHeartbeatAggregationId.fromJson(
                  json['id'] as Map<String, dynamic>),
          json['total'] as int?,
        );

Map<String, dynamic> _$AssociationHeartbeatAggregationResultToJson(
        AssociationHeartbeatAggregationResult instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'total': instance.total,
    };
