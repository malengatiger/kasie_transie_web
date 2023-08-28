// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationResponse _$LocationResponseFromJson(Map<String, dynamic> json) =>
    LocationResponse(
      userId: json['userId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      geoHash: json['geoHash'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LocationResponseToJson(LocationResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'geoHash': instance.geoHash,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
      'position': instance.position?.toJson(),
    };
