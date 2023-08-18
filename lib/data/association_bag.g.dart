// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'association_bag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssociationBag _$AssociationBagFromJson(Map<String, dynamic> json) =>
    AssociationBag(
      passengerCounts: (json['passengerCounts'] as List<dynamic>)
          .map((e) =>
              AmbassadorPassengerCount.fromJson(e as Map<String, dynamic>))
          .toList(),
      heartbeats: (json['heartbeats'] as List<dynamic>)
          .map((e) => VehicleHeartbeat.fromJson(e as Map<String, dynamic>))
          .toList(),
      arrivals: (json['arrivals'] as List<dynamic>)
          .map((e) => VehicleArrival.fromJson(e as Map<String, dynamic>))
          .toList(),
      departures: (json['departures'] as List<dynamic>)
          .map((e) => VehicleDeparture.fromJson(e as Map<String, dynamic>))
          .toList(),
      commuterRequests: (json['commuterRequests'] as List<dynamic>)
          .map((e) => CommuterRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      dispatchRecords: (json['dispatchRecords'] as List<dynamic>)
          .map((e) => DispatchRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$AssociationBagToJson(AssociationBag instance) =>
    <String, dynamic>{
      'passengerCounts': instance.passengerCounts,
      'heartbeats': instance.heartbeats,
      'arrivals': instance.arrivals,
      'departures': instance.departures,
      'dispatchRecords': instance.dispatchRecords,
      'commuterRequests': instance.commuterRequests,
    };
