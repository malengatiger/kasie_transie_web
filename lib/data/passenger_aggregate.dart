import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'passenger_aggregate.g.dart';

@JsonSerializable(explicitToJson: true)
class PassengerAggregate {
  @JsonKey(name: '_id')
  String? id;
  int? totalPassengers;


  PassengerAggregate(this.id, this.totalPassengers);

  factory PassengerAggregate.fromJson(Map<String, dynamic> json) => _$PassengerAggregateFromJson(json);
  Map<String, dynamic> toJson() => _$PassengerAggregateToJson(this);

}
