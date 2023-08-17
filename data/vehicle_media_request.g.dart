// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_media_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VehicleMediaRequest _$VehicleMediaRequestFromJson(Map<String, dynamic> json) =>
    VehicleMediaRequest(
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      requesterId: json['requesterId'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      requesterName: json['requesterName'] as String?,
    );

Map<String, dynamic> _$VehicleMediaRequestToJson(
        VehicleMediaRequest instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'requesterId': instance.requesterId,
      'created': instance.created,
      'associationId': instance.associationId,
      'requesterName': instance.requesterName,
    };
