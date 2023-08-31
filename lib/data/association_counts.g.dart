// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_counts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssociationCounts _$AssociationCountsFromJson(Map<String, dynamic> json) =>
    AssociationCounts(
      passengerCounts: json['passengerCounts'] as int?,
      heartbeats: json['heartbeats'] as int?,
      arrivals: json['arrivals'] as int?,
      departures: json['departures'] as int?,
      dispatchRecords: json['dispatchRecords'] as int?,
      commuterRequests: json['commuterRequests'] as int?,
      created: json['created'] as String?,
    );

Map<String, dynamic> _$AssociationCountsToJson(AssociationCounts instance) =>
    <String, dynamic>{
      'passengerCounts': instance.passengerCounts,
      'heartbeats': instance.heartbeats,
      'arrivals': instance.arrivals,
      'departures': instance.departures,
      'dispatchRecords': instance.dispatchRecords,
      'commuterRequests': instance.commuterRequests,
      'created': instance.created,
    };
