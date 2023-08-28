import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable(explicitToJson: true)

class SettingsModel {
  String? associationId;
  String? locale, created;
  int? refreshRateInSeconds, themeIndex;
  int? geofenceRadius, commuterGeofenceRadius;
  int? vehicleSearchMinutes,
      heartbeatIntervalSeconds,
      loiteringDelay,
      commuterSearchMinutes,
      commuterGeoQueryRadius,
      vehicleGeoQueryRadius,
      numberOfLandmarksToScan;
  int? distanceFilter;

  SettingsModel({
      required this.associationId,
      required this.locale,
      required this.created,
      required this.refreshRateInSeconds,
      required this.themeIndex,
      required this.geofenceRadius,
      required this.commuterGeofenceRadius,
      required this.vehicleSearchMinutes,
      required this.heartbeatIntervalSeconds,
      required this.loiteringDelay,
      required this.commuterSearchMinutes,
      required this.commuterGeoQueryRadius,
      required this.vehicleGeoQueryRadius,
      required this.numberOfLandmarksToScan,
      required this.distanceFilter});

  factory SettingsModel.fromJson(Map<String, dynamic> json) => _$SettingsModelFromJson(json);
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}
