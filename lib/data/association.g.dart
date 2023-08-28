// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Association _$AssociationFromJson(Map<String, dynamic> json) => Association(
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
      cityName: json['cityName'] as String?,
      associationName: json['associationName'] as String?,
      associationId: json['associationId'] as String?,
      active: json['active'] as int?,
      countryName: json['countryName'] as String?,
      dateRegistered: json['dateRegistered'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
      geoHash: json['geoHash'] as String?,
      adminUserFirstName: json['adminUserFirstName'] as String?,
      adminUserLastName: json['adminUserLastName'] as String?,
      userId: json['userId'] as String?,
      adminCellphone: json['adminCellphone'] as String?,
      adminEmail: json['adminEmail'] as String?,
    );

Map<String, dynamic> _$AssociationToJson(Association instance) =>
    <String, dynamic>{
      'cityId': instance.cityId,
      'countryId': instance.countryId,
      'cityName': instance.cityName,
      'associationName': instance.associationName,
      'associationId': instance.associationId,
      'active': instance.active,
      'countryName': instance.countryName,
      'dateRegistered': instance.dateRegistered,
      'position': instance.position?.toJson(),
      'geoHash': instance.geoHash,
      'adminUserFirstName': instance.adminUserFirstName,
      'adminUserLastName': instance.adminUserLastName,
      'userId': instance.userId,
      'adminCellphone': instance.adminCellphone,
      'adminEmail': instance.adminEmail,
    };
