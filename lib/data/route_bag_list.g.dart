// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'route_bag_list.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RouteBagList _$RouteBagListFromJson(Map<String, dynamic> json) => RouteBagList(
      (json['routeBags'] as List<dynamic>)
          .map((e) => RouteBag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RouteBagListToJson(RouteBagList instance) =>
    <String, dynamic>{
      'routeBags': instance.routeBags,
    };
