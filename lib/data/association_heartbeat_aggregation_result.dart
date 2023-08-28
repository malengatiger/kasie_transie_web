import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/association_heartbeat_aggregation_id.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat_aggregation_id.dart';

part 'association_heartbeat_aggregation_result.g.dart';

@JsonSerializable(explicitToJson: true)
class AssociationHeartbeatAggregationResult {

  AssociationHeartbeatAggregationId? id;
   int? total;


  AssociationHeartbeatAggregationResult(this.id, this.total);

  factory AssociationHeartbeatAggregationResult.fromJson(Map<String, dynamic> json) => _$AssociationHeartbeatAggregationResultFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationHeartbeatAggregationResultToJson(this);

  String get key => '${id!.year}${id!.month}${id!.day}${id!.hour}';

}

