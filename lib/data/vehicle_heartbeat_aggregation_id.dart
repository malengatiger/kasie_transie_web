import 'package:json_annotation/json_annotation.dart';

part 'vehicle_heartbeat_aggregation_id.g.dart';

@JsonSerializable(explicitToJson: true)
class VehicleHeartbeatAggregationId {
  int? year, month, day, hour;
  String? vehicleId;

  VehicleHeartbeatAggregationId(
      this.year, this.month, this.day, this.hour, this.vehicleId);

  factory VehicleHeartbeatAggregationId.fromJson(Map<String, dynamic> json) => _$VehicleHeartbeatAggregationIdFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleHeartbeatAggregationIdToJson(this);


}

