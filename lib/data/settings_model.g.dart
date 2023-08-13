// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      associationId: json['associationId'] as String?,
      locale: json['locale'] as String?,
      created: json['created'] as String?,
      refreshRateInSeconds: json['refreshRateInSeconds'] as int?,
      themeIndex: json['themeIndex'] as int?,
      geofenceRadius: json['geofenceRadius'] as int?,
      commuterGeofenceRadius: json['commuterGeofenceRadius'] as int?,
      vehicleSearchMinutes: json['vehicleSearchMinutes'] as int?,
      heartbeatIntervalSeconds: json['heartbeatIntervalSeconds'] as int?,
      loiteringDelay: json['loiteringDelay'] as int?,
      commuterSearchMinutes: json['commuterSearchMinutes'] as int?,
      commuterGeoQueryRadius: json['commuterGeoQueryRadius'] as int?,
      vehicleGeoQueryRadius: json['vehicleGeoQueryRadius'] as int?,
      numberOfLandmarksToScan: json['numberOfLandmarksToScan'] as int?,
      distanceFilter: json['distanceFilter'] as int?,
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'associationId': instance.associationId,
      'locale': instance.locale,
      'created': instance.created,
      'refreshRateInSeconds': instance.refreshRateInSeconds,
      'themeIndex': instance.themeIndex,
      'geofenceRadius': instance.geofenceRadius,
      'commuterGeofenceRadius': instance.commuterGeofenceRadius,
      'vehicleSearchMinutes': instance.vehicleSearchMinutes,
      'heartbeatIntervalSeconds': instance.heartbeatIntervalSeconds,
      'loiteringDelay': instance.loiteringDelay,
      'commuterSearchMinutes': instance.commuterSearchMinutes,
      'commuterGeoQueryRadius': instance.commuterGeoQueryRadius,
      'vehicleGeoQueryRadius': instance.vehicleGeoQueryRadius,
      'numberOfLandmarksToScan': instance.numberOfLandmarksToScan,
      'distanceFilter': instance.distanceFilter,
    };
