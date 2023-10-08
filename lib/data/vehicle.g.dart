// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vehicle _$VehicleFromJson(Map<String, dynamic> json) => Vehicle(
      id: json['_id'] as String?,
      vehicleId: json['vehicleId'] as String?,
      countryId: json['countryId'] as String?,
      ownerName: json['ownerName'] as String?,
      ownerId: json['ownerId'] as String?,
      created: json['created'] as String?,
      dateInstalled: json['dateInstalled'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      passengerCapacity: json['passengerCapacity'] as int?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
    );

Map<String, dynamic> _$VehicleToJson(Vehicle instance) => <String, dynamic>{
      '_id': instance.id,
      'vehicleId': instance.vehicleId,
      'countryId': instance.countryId,
      'ownerName': instance.ownerName,
      'ownerId': instance.ownerId,
      'created': instance.created,
      'dateInstalled': instance.dateInstalled,
      'vehicleReg': instance.vehicleReg,
      'make': instance.make,
      'model': instance.model,
      'year': instance.year,
      'qrCodeUrl': instance.qrCodeUrl,
      'passengerCapacity': instance.passengerCapacity,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
    };
