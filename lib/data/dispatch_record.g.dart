// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dispatch_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DispatchRecord _$DispatchRecordFromJson(Map<String, dynamic> json) =>
    DispatchRecord(
      dispatchRecordId: json['dispatchRecordId'] as String?,
      marshalId: json['marshalId'] as String?,
      passengers: json['passengers'] as int?,
      ownerId: json['ownerId'] as String?,
      created: json['created'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      landmarkName: json['landmarkName'] as String?,
      marshalName: json['marshalName'] as String?,
      routeName: json['routeName'] as String?,
      routeId: json['routeId'] as String?,
      vehicleArrivalId: json['vehicleArrivalId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      dispatched: json['dispatched'] as bool?,
    )
      ..vehicleId = json['vehicleId'] as String?
      ..vehicleReg = json['vehicleReg'] as String?
      ..routeLandmarkId = json['routeLandmarkId'] as String?;

Map<String, dynamic> _$DispatchRecordToJson(DispatchRecord instance) =>
    <String, dynamic>{
      'dispatchRecordId': instance.dispatchRecordId,
      'marshalId': instance.marshalId,
      'passengers': instance.passengers,
      'ownerId': instance.ownerId,
      'created': instance.created,
      'position': instance.position,
      'geoHash': instance.geoHash,
      'landmarkName': instance.landmarkName,
      'marshalName': instance.marshalName,
      'routeName': instance.routeName,
      'routeId': instance.routeId,
      'vehicleId': instance.vehicleId,
      'vehicleArrivalId': instance.vehicleArrivalId,
      'vehicleReg': instance.vehicleReg,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'routeLandmarkId': instance.routeLandmarkId,
      'dispatched': instance.dispatched,
    };
