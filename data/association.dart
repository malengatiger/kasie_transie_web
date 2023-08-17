import 'package:kasie_transie_web/data/position.dart';
import 'package:json_annotation/json_annotation.dart';

part 'association.g.dart';

@JsonSerializable()
class Association {
  String? cityId;
  String? countryId;
  String? cityName, associationName, associationId;
  int? active;
  String? countryName;
  String? dateRegistered;
  Position? position;
  String? geoHash;
  String? adminUserFirstName;
  String? adminUserLastName;
  String? userId;
  String? adminCellphone;
  String? adminEmail;

  Association({
      required this.cityId,
      required this.countryId,
      required this.cityName,
      required this.associationName,
      required this.associationId,
      required this.active,
      required this.countryName,
      required this.dateRegistered,
      required this.position,
      required this.geoHash,
      required this.adminUserFirstName,
      required this.adminUserLastName,
      required this.userId,
      required this.adminCellphone,
      required this.adminEmail});

  factory Association.fromJson(Map<String, dynamic> json) => _$AssociationFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationToJson(this);

}
