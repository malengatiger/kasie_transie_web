import 'package:json_annotation/json_annotation.dart';

part 'association_heartbeat_aggregation_id.g.dart';

@JsonSerializable(explicitToJson: true)
class AssociationHeartbeatAggregationId {
  int? year, month, day, hour;
  String? associationId;

  AssociationHeartbeatAggregationId(
      this.year, this.month, this.day, this.hour, this.associationId);

  factory AssociationHeartbeatAggregationId.fromJson(Map<String, dynamic> json) => _$AssociationHeartbeatAggregationIdFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationHeartbeatAggregationIdToJson(this);

}

