import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/route_point.dart';
import 'package:kasie_transie_web/data/route.dart' as lib;

import '../utils/functions.dart';

class DistanceDropDown extends StatelessWidget {
  const DistanceDropDown(
      {Key? key,
      required this.onDistancePicked,
      required this.color,
      required this.count,
      required this.fontSize, required this.multiplier})
      : super(key: key);

  final Function(int) onDistancePicked;
  final Color color;
  final double fontSize;
  final int count, multiplier;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = [];
    for (var i = 0; i < count; i++) {
      var m = i * multiplier;
      if (m ==  0) {
        m = 10;
      }
      items.add(DropdownMenuItem(
          value: i * multiplier,
          child: Text(
            '$m km',
            style: myTextStyleMediumLargeWithColor(context, color, fontSize),
          )));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (number) {
          if (number != null) {
            onDistancePicked(number);
          }
        });
  }
}

class NumberDropDown extends StatelessWidget {
  const NumberDropDown(
      {Key? key,
      required this.onNumberPicked,
      required this.color,
      required this.count,
      required this.fontSize})
      : super(key: key);

  final Function(int) onNumberPicked;
  final Color color;
  final double fontSize;
  final int count;

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> items = [];
    for (var i = 0; i < count; i++) {
      items.add(DropdownMenuItem(
          value: i,
          child: Text(
            '$i',
            style: myTextStyleMediumLargeWithColor(context, color, fontSize),
          )));
    }
    return DropdownButton<int>(
        items: items,
        onChanged: (number) {
          if (number != null) {
            onNumberPicked(number);
          }
        });
  }
}

class RouteDropDown extends StatelessWidget {
  const RouteDropDown(
      {Key? key, required this.routes, required this.onRoutePicked})
      : super(key: key);
  final List<lib.Route> routes;
  final Function(lib.Route) onRoutePicked;

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<lib.Route>>[];
    for (var r in routes) {
      items.add(DropdownMenuItem<lib.Route>(
          value: r,
          child: Text(
            r.name!,
            style: myTextStyleSmall(context),
          )));
    }
    return DropdownButton(
        hint: Text(
          'Select Route',
          style: myTextStyleSmall(context),
        ),
        items: items,
        onChanged: (r) {
          if (r != null) {
            onRoutePicked(r);
          }
        });
  }
}

