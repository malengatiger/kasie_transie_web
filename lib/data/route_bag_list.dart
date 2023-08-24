import 'package:json_annotation/json_annotation.dart';
import 'package:kasie_transie_web/data/route_bag.dart';
part 'route_bag_list.g.dart';

@JsonSerializable()

class RouteBagList {
  List<RouteBag> routeBags = [];

  RouteBagList(this.routeBags);
  factory RouteBagList.fromJson(Map<String, dynamic> json) => _$RouteBagListFromJson(json);
  Map<String, dynamic> toJson() => _$RouteBagListToJson(this);
}