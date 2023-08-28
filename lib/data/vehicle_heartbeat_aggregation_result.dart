import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat_aggregation_id.dart';

part 'vehicle_heartbeat_aggregation_result.g.dart';

@JsonSerializable(explicitToJson: true)
class VehicleHeartbeatAggregationResult {

  VehicleHeartbeatAggregationId? id;
   int? total;


  VehicleHeartbeatAggregationResult({required this.id, required this.total});

  factory VehicleHeartbeatAggregationResult.fromJson(Map<String, dynamic> json) => _$VehicleHeartbeatAggregationResultFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleHeartbeatAggregationResultToJson(this);

  String get key => '${id!.year}${id!.month}${id!.day}${id!.hour}';
}

