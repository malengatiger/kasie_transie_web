// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Route _$RouteFromJson(Map<String, dynamic> json) => Route(
      routeId: json['routeId'] as String?,
      countryId: json['countryId'] as String?,
      countryName: json['countryName'] as String?,
      name: json['name'] as String?,
      routeNumber: json['routeNumber'] as String?,
      created: json['created'] as String?,
      updated: json['updated'] as String?,
      color: json['color'] as String?,
      isActive: json['isActive'] as bool?,
      activationDate: json['activationDate'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      heading: (json['heading'] as num?)?.toDouble(),
      lengthInMetres: json['lengthInMetres'] as int?,
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      userUrl: json['userUrl'] as String?,
      routeStartEnd: json['routeStartEnd'] == null
          ? null
          : RouteStartEnd.fromJson(
              json['routeStartEnd'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteToJson(Route instance) => <String, dynamic>{
      'routeId': instance.routeId,
      'countryId': instance.countryId,
      'countryName': instance.countryName,
      'name': instance.name,
      'routeNumber': instance.routeNumber,
      'created': instance.created,
      'updated': instance.updated,
      'color': instance.color,
      'isActive': instance.isActive,
      'activationDate': instance.activationDate,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'heading': instance.heading,
      'lengthInMetres': instance.lengthInMetres,
      'userId': instance.userId,
      'userName': instance.userName,
      'userUrl': instance.userUrl,
      'routeStartEnd': instance.routeStartEnd,
    };
