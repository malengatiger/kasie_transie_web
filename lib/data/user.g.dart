// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      gender: json['gender'] as String?,
      countryId: json['countryId'] as String?,
      associationId: json['associationId'] as String?,
      associationName: json['associationName'] as String?,
      fcmToken: json['fcmToken'] as String?,
      password: json['password'] as String?,
      email: json['email'] as String?,
      cellphone: json['cellphone'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'gender': instance.gender,
      'countryId': instance.countryId,
      'associationId': instance.associationId,
      'associationName': instance.associationName,
      'fcmToken': instance.fcmToken,
      'password': instance.password,
      'email': instance.email,
      'cellphone': instance.cellphone,
      'thumbnailUrl': instance.thumbnailUrl,
      'imageUrl': instance.imageUrl,
    };
