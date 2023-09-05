import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/onboarding/vehicle_search.dart';

class CarList extends StatefulWidget {
  const CarList({
    super.key,
    required this.onCarPicked,
  });

  final Function(Vehicle) onCarPicked;

  @override
  State<CarList> createState() => _CarListState();
}

class _CarListState extends State<CarList> {
  List<Vehicle> carsToDisplay = [];
  List<Vehicle> cars = [];
  bool busy = false;
  static const mm = '🍎🍎🍎🍎 CarList 🍎🍎';

  User? deviceUser;

  @override
  void initState() {
    super.initState();
    _getCars(false);
  }

  Future _getCars(bool refresh) async {
    try {
      pp('$mm ...................................... getting cars ....');
    } catch (e, s) {
      print(s);
    }
    setState(() {
      busy = true;
    });
    try {
      deviceUser = await prefs.getUser();
      cars = await networkHandler.getAssociationVehicles(
          associationId: deviceUser!.associationId!, refresh: refresh);

      cars.sort((a, b) => a.vehicleReg!.compareTo(b.vehicleReg!));
      pp('$mm ... _getCars: ${E.broc} association cars : ${cars.length}');
      carsToDisplay = cars;
    } catch (e) {
      pp(e);
    }
    pp('$mm ... setting state carsToDisplay : ${carsToDisplay.length}');
    setState(() {
      busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          carsToDisplay.isEmpty
              ? Text('No cars, bro!')
              : VehicleSearch(
                  cars: carsToDisplay,
                  carsFound: (carsFound) {
                    pp('$mm ... carsFound by search: ${carsFound.length}');
                    if (carsFound.isEmpty) {
                      setState(() {
                        carsToDisplay = cars;
                      });
                    } else {
                      setState(() {
                        carsToDisplay = carsFound;
                      });
                    }
                  }),
          gapH4,
          Expanded(
            child: bd.Badge(
              badgeContent: Text(
                '${carsToDisplay.length}',
                style: myTextStyleSmall(context),
              ),
              badgeStyle: bd.BadgeStyle(
                padding: EdgeInsets.all(12.0),
                badgeColor: Colors.pink,
              ),
              child: Card(
                shape: getDefaultRoundedBorder(),
                elevation: 12,

                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                      itemCount: carsToDisplay.length,
                      itemBuilder: (ctx, index) {
                        final car = carsToDisplay.elementAt(index);
                        return GestureDetector(
                          onTap: () {
                            widget.onCarPicked(car);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              shape: getDefaultRoundedBorder(),
                              elevation: 16,
                              child: ListTile(
                                leading: Icon(
                                  Icons.airport_shuttle,
                                  color: Theme.of(context).primaryColor,
                                ),
                                title: Row(
                                  children: [
                                    Text(
                                      '${car.vehicleReg}',
                                      style: myTextStyleMediumLarge(context, 20),
                                    ),
                                    gapW32,
                                    Text(
                                      '${car.make} ${car.model} - ${car.year}',
                                      style: myTextStyleSmall(context),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
