// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) => City(
      cityId: json['cityId'] as String?,
      countryId: json['countryId'] as String?,
      name: json['name'] as String?,
      distance: json['distance'] as String?,
      stateName: json['stateName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      countryName: json['countryName'] as String?,
      stateId: json['stateId'] as String?,
      position: json['position'] == null
          ? null
          : Position.fromJson(json['position'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
      'cityId': instance.cityId,
      'countryId': instance.countryId,
      'name': instance.name,
      'distance': instance.distance,
      'stateName': instance.stateName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'countryName': instance.countryName,
      'stateId': instance.stateId,
      'position': instance.position,
    };
