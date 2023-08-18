import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/position.dart';

part 'ambassador_passenger_count.g.dart';

@JsonSerializable()
class AmbassadorPassengerCount {
  String? vehicleId, vehicleReg;
  String? userId;
  String? userName;
  String? created;
  String? associationId;
  String? routeId;
  String? routeName;
  String? ownerId;
  String? ownerName;
  int? passengersIn;
  int? passengersOut;
  int? currentPassengers;
  String? passengerCountId;
  Position? position;

  AmbassadorPassengerCount(
      {required this.vehicleId,
      required this.vehicleReg,
      required this.userId,
      required this.userName,
      required this.created,
      required this.associationId,
      required this.routeId,
      required this.routeName,
      required this.ownerId,
      required this.ownerName,
      required this.passengersIn,
      required this.passengersOut,
      required this.passengerCountId,
      required this.currentPassengers,
      required this.position});

  factory AmbassadorPassengerCount.fromJson(Map<String, dynamic> json) =>
      _$AmbassadorPassengerCountFromJson(json);

  Map<String, dynamic> toJson() => _$AmbassadorPassengerCountToJson(this);
}
