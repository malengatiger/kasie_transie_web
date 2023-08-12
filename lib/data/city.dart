import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'city.g.dart';

@JsonSerializable()

class City {
  String? cityId;
  String? countryId;
  String? name, distance;
  String? stateName;
  double? latitude;
  double? longitude;
  String? countryName;
  String? stateId;
  Position? position;

  City({
      required this.cityId,
      required this.countryId,
      required this.name,
      required this.distance,
      required this.stateName,
      required this.latitude,
      required this.longitude,
      required this.countryName,
      required this.stateId,
      required this.position});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);

}
