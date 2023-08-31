import 'package:json_annotation/json_annotation.dart';

part 'association_counts.g.dart';

@JsonSerializable(explicitToJson: true)
class AssociationCounts {
  int? passengerCounts;
  int? heartbeats;
  int? arrivals;
  int? departures;
  int? dispatchRecords;
  int? commuterRequests;
  String? created;

  AssociationCounts(
      {required this.passengerCounts,
      required this.heartbeats,
      required this.arrivals,
      required this.departures,
      required this.dispatchRecords,
      required this.commuterRequests,
      required this.created});

  factory AssociationCounts.fromJson(Map<String, dynamic> json) =>
      _$AssociationCountsFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationCountsToJson(this);
}
