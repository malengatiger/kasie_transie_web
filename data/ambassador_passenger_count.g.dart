// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambassador_passenger_count.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AmbassadorPassengerCount _$AmbassadorPassengerCountFromJson(
        Map<String, dynamic> json) =>
    AmbassadorPassengerCount(
      vehicleId: json['vehicleId'] as String?,
      vehicleReg: json['vehicleReg'] as String?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      created: json['created'] as String?,
      associationId: json['associationId'] as String?,
      routeId: json['routeId'] as String?,
      routeName: json['routeName'] as String?,
      ownerId: json['ownerId'] as String?,
      ownerName: json['ownerName'] as String?,
      passengersIn: json['passengersIn'] as int?,
      passengersOut: json['passengersOut'] as int?,
      currentPassengers: json['currentPassengers'] as int?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AmbassadorPassengerCountToJson(
        AmbassadorPassengerCount instance) =>
    <String, dynamic>{
      'vehicleId': instance.vehicleId,
      'vehicleReg': instance.vehicleReg,
      'userId': instance.userId,
      'userName': instance.userName,
      'created': instance.created,
      'associationId': instance.associationId,
      'routeId': instance.routeId,
      'routeName': instance.routeName,
      'ownerId': instance.ownerId,
      'ownerName': instance.ownerName,
      'passengersIn': instance.passengersIn,
      'passengersOut': instance.passengersOut,
      'currentPassengers': instance.currentPassengers,
      'position': instance.position,
    };
