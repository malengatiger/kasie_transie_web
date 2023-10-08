import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/association_heartbeat_aggregation_id.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat_aggregation_id.dart';
import 'package:kasie_transie_web/utils/functions.dart';

part 'association_heartbeat_aggregation_result.g.dart';

@JsonSerializable(explicitToJson: true)
class AssociationHeartbeatAggregationResult {

  AssociationHeartbeatAggregationId? id;
   int? total;

/*
 const config = {
      apiKey: "AIzaSyAdOBFxPS1TacnK5OZTU6VxOQ20Bq8Cyrg",
      authDomain: "thermal-effort-366015.firebaseapp.com",
      projectId: "thermal-effort-366015",
      storageBucket: "thermal-effort-366015.appspot.com",
      messagingSenderId: "79998394043",
      appId: "1:79998394043:web:af0eba9987ec6676d6139e",
      measurementId: "G-0668RQE3NY",
    }
 */
  AssociationHeartbeatAggregationResult(this.id, this.total);

  factory AssociationHeartbeatAggregationResult.fromJson(Map<String, dynamic> json) => _$AssociationHeartbeatAggregationResultFromJson(json);
  Map<String, dynamic> toJson() => _$AssociationHeartbeatAggregationResultToJson(this);

  //String get key => '${id!.year}${id!.month}${id!.day}${id!.hour}';

  String? getKey() {
    final sb = StringBuffer();
    if (id == null) {
      return null;
    }
    pp(id!.toJson());

    if (id?.associationId == null) {
      return null;
    }
    if (id?.day == null) {
      return null;
    }
    if (id?.month == null) {
      return null;
    }
    if (id?.year == null) {
      return null;
    }
    if (id?.hour == null) {
      return null;
    }
    return '${id!.year}${id!.month}${id!.day}${id!.hour}';
  }

}

