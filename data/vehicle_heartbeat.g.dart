// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_heartbeat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleHeartbeat _$VehicleHeartbeatFromJson(Map<String, dynamic> json) =>
    VehicleHeartbeat(
      vehicleHeartbeatId: json['vehicleHeartbeatId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      longDate: json['longDate'] as int?,
      appToBackground: json['appToBackground'] as bool?,
    );

Map<String, dynamic> _$VehicleHeartbeatToJson(VehicleHeartbeat instance) =>
    <String, dynamic>{
      'vehicleHeartbeatId': instance.vehicleHeartbeatId,
      'position': instance.position,
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'longDate': instance.longDate,
      'appToBackground': instance.appToBackground,
    };
