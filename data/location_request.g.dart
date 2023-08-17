// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationRequest _$LocationRequestFromJson(Map<String, dynamic> json) =>
    LocationRequest(
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
    );

Map<String, dynamic> _$LocationRequestToJson(LocationRequest instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
    };
