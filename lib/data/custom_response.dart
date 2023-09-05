import 'package:json_annotation/json_annotation.dart';

part 'custom_response.g.dart';

@JsonSerializable(explicitToJson: true)
class CustomResponse {
  int? statusCode;
  String? message;
  String? date;

  CustomResponse(this.statusCode, this.message, this.date);

  factory CustomResponse.fromJson(Map<String, dynamic> json) => _$CustomResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CustomResponseToJson(this);

}
