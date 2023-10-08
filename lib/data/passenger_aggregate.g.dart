// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'passenger_aggregate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PassengerAggregate _$PassengerAggregateFromJson(Map<String, dynamic> json) =>
    PassengerAggregate(
      json['_id'] as String?,
      json['totalPassengers'] as int?,
    );

Map<String, dynamic> _$PassengerAggregateToJson(PassengerAggregate instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'totalPassengers': instance.totalPassengers,
    };
