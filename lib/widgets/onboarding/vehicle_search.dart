
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as bd;
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/local_storage/storage_manager.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import '../../l10n/translation_handler.dart';
import '../../utils/emojis.dart';

class VehicleSearch extends StatefulWidget {
  const VehicleSearch({super.key, required this.cars, required this.carsFound,});
  final List<Vehicle> cars;
  final Function(List<Vehicle>) carsFound;

  @override
  State<VehicleSearch> createState() => _VehicleSearchState();
}

class _VehicleSearchState extends State<VehicleSearch> {
  static const mm = '🍎🍎🍎🍎🍎 VehicleSearch';
  final TextEditingController _textEditingController = TextEditingController();
  String search = 'Search';
  String searchVehicles = 'Search Vehicles';
  List<Vehicle> carsPicked = [];
  bool busy = false;

  @override
  void initState() {
    super.initState();
    pp('$mm .....initState; cars to process: ${widget.cars.length}');
    _setCarPlates();
  }
  final _carPlates = <String>[];
  var carsToDisplay = <Vehicle>[];

  void _setCarPlates() {
    _carPlates.clear();
    for (var element in widget.cars) {
      _carPlates.add(element.vehicleReg!);
      carsToDisplay.add(element);
    }

    pp('$mm ....._setCarPlates: carsToDisplay: ${carsToDisplay.length} '
        'carPlates; ${_carPlates.length}');
  }

  Future<void> _runFilter(String text) async {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      carsToDisplay.clear();
      for (var project in widget.cars) {
        carsToDisplay.add(project);
      }
      setState(() {});
      return;
    }
    carsToDisplay.clear();

    pp('$mm ...  filtering cars that contain: $text from ${_carPlates.length} car plates');
    for (var carPlate in _carPlates) {
      if (carPlate.toLowerCase().contains(text.toLowerCase())) {
        var car = await storageManager.getCarByRegistration(carPlate);
        if (car != null) {
          carsToDisplay.add(car);
        }
      }
    }
    pp('$mm .... _runFilter:  carsToDisplay: ${carsToDisplay.length} .....'
        ' calling widget.carsFound() ...');
    widget.carsFound(carsToDisplay);
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 300,
          child: TextField(
            controller: _textEditingController,
            onChanged: (text) {
              pp(' ........... text to filter cars: $text');
              _runFilter(text);
            },
            decoration: InputDecoration(
                label: Text(search,
                  style: myTextStyleSmall(
                    context,
                  ),
                ),
                icon: Icon(
                  Icons.search,
                  color:
                  Theme.of(context).primaryColor,
                ),
                border: const OutlineInputBorder(
                  gapPadding: 2.0
                ),
                hintText: searchVehicles,
                hintStyle: myTextStyleSmallWithColor(
                    context,
                    Theme.of(context).primaryColor)),
          ),
        ),
      ],
    );
  }
}
