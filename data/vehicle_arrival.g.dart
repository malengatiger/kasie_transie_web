// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_arrival.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleArrival _$VehicleArrivalFromJson(Map<String, dynamic> json) =>
    VehicleArrival(
      vehicleArrivalId: json['vehicleArrivalId'] as String?,
      landmarkId: json['landmarkId'] as String?,
      landmarkName: json['landmarkName'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      created: json['created'] as String?,
      vehicleId: json['vehicleId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      dispatched: json['dispatched'] as bool?,
    );

Map<String, dynamic> _$VehicleArrivalToJson(VehicleArrival instance) =>
    <String, dynamic>{
      'vehicleArrivalId': instance.vehicleArrivalId,
      'landmarkId': instance.landmarkId,
      'landmarkName': instance.landmarkName,
      'position': instance.position,
      'geoHash': instance.geoHash,
      'created': instance.created,
      'vehicleId': instance.vehicleId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'dispatched': instance.dispatched,
    };
