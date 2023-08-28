// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_heartbeat_aggregation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleHeartbeatAggregationResult _$VehicleHeartbeatAggregationResultFromJson(
        Map<String, dynamic> json) =>
    VehicleHeartbeatAggregationResult(
      id: json['id'] == null
          ? null
          : VehicleHeartbeatAggregationId.fromJson(
              json['id'] as Map<String, dynamic>),
      total: json['total'] as int?,
    );

Map<String, dynamic> _$VehicleHeartbeatAggregationResultToJson(
        VehicleHeartbeatAggregationResult instance) =>
    <String, dynamic>{
      'id': instance.id?.toJson(),
      'total': instance.total,
    };
