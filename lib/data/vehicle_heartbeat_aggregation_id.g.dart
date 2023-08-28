// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_heartbeat_aggregation_id.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleHeartbeatAggregationId _$VehicleHeartbeatAggregationIdFromJson(
        Map<String, dynamic> json) =>
    VehicleHeartbeatAggregationId(
      json['year'] as int?,
      json['month'] as int?,
      json['day'] as int?,
      json['hour'] as int?,
      json['vehicleId'] as String?,
    );

Map<String, dynamic> _$VehicleHeartbeatAggregationIdToJson(
        VehicleHeartbeatAggregationId instance) =>
    <String, dynamic>{
      'year': instance.year,
      'month': instance.month,
      'day': instance.day,
      'hour': instance.hour,
      'vehicleId': instance.vehicleId,
    };
