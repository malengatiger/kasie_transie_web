import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  String? userId;
  String? firstName, lastName, gender;
  String? countryId;
  String? associationId;
  String? associationName;
  String? fcmToken;
  String? password;
  String? email;
  String? cellphone, thumbnailUrl, imageUrl;

  User({
      required this.userId,
      required this.firstName,
      required this.lastName,
      required this.gender,
      required this.countryId,
      required this.associationId,
      required this.associationName,
      required this.fcmToken,
      required this.password,
      required this.email,
      required this.cellphone,
      required this.thumbnailUrl,
      required this.imageUrl});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

}
