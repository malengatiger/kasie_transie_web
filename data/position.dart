import 'package:json_annotation/json_annotation.dart';

part 'position.g.dart';

@JsonSerializable()

class Position {
  String? type = 'Point';
  List<double> coordinates = [];

  Position({required this.type, required this.coordinates});

  factory Position.fromJson(Map<String, dynamic> json) => _$PositionFromJson(json);
  Map<String, dynamic> toJson() => _$PositionToJson(this);
}
