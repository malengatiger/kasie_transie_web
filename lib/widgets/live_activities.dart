import 'dart:async';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/blocs/fcm_bloc.dart';
import 'package:kasie_transie_web/data/ambassador_passenger_count.dart';
import 'package:kasie_transie_web/data/commuter_request.dart';
import 'package:kasie_transie_web/data/dispatch_record.dart';
import 'package:kasie_transie_web/data/location_request.dart';
import 'package:kasie_transie_web/data/vehicle_arrival.dart';
import 'package:kasie_transie_web/data/vehicle_departure.dart';
import 'package:kasie_transie_web/data/vehicle_heartbeat.dart';
import 'package:kasie_transie_web/l10n/strings_helper.dart';

import '../data/association_bag.dart';
import '../data/location_response.dart';
import '../l10n/translation_handler.dart';
import '../utils/emojis.dart';
import '../utils/functions.dart';
import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';

class LiveDisplay extends StatefulWidget {
  const LiveDisplay({super.key, required this.width});

  final double? width;
  @override
  State<LiveDisplay> createState() => _LiveDisplayState();
}

class _LiveDisplayState extends State<LiveDisplay> {
  late StreamSubscription<AssociationBag> assocBagStreamSubscription;
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  late StreamSubscription<VehicleArrival> arrivalStreamSubscription;
  late StreamSubscription<VehicleDeparture> departureStreamSubscription;
  late StreamSubscription<DispatchRecord> dispatchStreamSubscription;
  late StreamSubscription<AmbassadorPassengerCount> passengerStreamSubscription;
  late StreamSubscription<CommuterRequest> commuterStreamSubscription;
  late StreamSubscription<LocationRequest> locationRequestStreamSubscription;
  late StreamSubscription<LocationResponse> locationResponseStreamSubscription;
  late StreamSubscription<CommuterRequest> commuterReqStreamSubscription;
  List<VehicleHeartbeat> heartbeats = [];
  List<VehicleArrival> arrivals = [];
  List<VehicleDeparture> departures = [];
  List<DispatchRecord> dispatches = [];
  List<AmbassadorPassengerCount> passengerCounts = [];
  List<CommuterRequest> commuterRequests = [];

  late StreamSubscription<bool> subscription;

  int totalPassengers = 0;
  static const mm = '💚LiveDisplay 💚💚💚💚💚';

  @override
  void initState() {
    super.initState();
    _listen();
    _setText();
  }

  StringsHelper? stringsHelper;
  Future _setText() async {
    stringsHelper = await StringsHelper.getTranslatedTexts();
    setState(() {

    });
  }
  void _listen() {
    pp('$mm will listen to fcm messaging ... '
        '${E.heartBlue} ${E.heartBlue} ${E.heartBlue} ...');

    subscription = translator.translationStream.listen((event) {
      pp('$mm ... translationStream ');
      if (mounted) {
        _setText();
      }
    });
    commuterReqStreamSubscription =
        fcmBloc.commuterRequestStreamStream.listen((event) {
      pp('$mm commuterRequestStreamStream delivered event ... ${E.heartBlue} ');
      commuterRequests.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    heartbeatStreamSubscription = fcmBloc.heartbeatStreamStream.listen((event) {
      pp('$mm heartbeatStreamStream delivered event ... ${E.heartBlue} ');
      heartbeats.add(event);
      if (mounted) {
        setState(() {});
      }
    });

    arrivalStreamSubscription = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered. ');
      arrivals.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    departureStreamSubscription =
        fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm ... vehicleDepartureStream delivered. ');
      departures.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    dispatchStreamSubscription = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered. ');
      dispatches.add(event);
      if (mounted) {
        setState(() {});
      }
    });
    passengerStreamSubscription = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered. ');
      passengerCounts.add(event);
      totalPassengers = 0;
      for (var value in passengerCounts) {
        totalPassengers += value.passengersIn!;
      }
      if (mounted) {
        setState(() {});
      }
    });
    locationResponseStreamSubscription =
        fcmBloc.locationResponseStream.listen((event) {
      pp('$mm ... locationResponseStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });

    locationRequestStreamSubscription =
        fcmBloc.locationRequestStream.listen((event) {
      pp('$mm ... locationRequestStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    heartbeatStreamSubscription.cancel();
    arrivalStreamSubscription.cancel();
    departureStreamSubscription.cancel();
    dispatchStreamSubscription.cancel();
    passengerStreamSubscription.cancel();
    commuterStreamSubscription.cancel();
    locationRequestStreamSubscription.cancel();
    locationResponseStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = getFormattedDateHour(DateTime.now().toIso8601String());
    pp('$mm ... ${dispatches.length} ... dispatches, if zero,  FUCK!');
    final width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 140,
      width: (width/2),
      child: Center(
        child: stringsHelper == null? gapW32: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 4,
          color: Colors.black54,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 64,
                  child: Column(
                    children: [
                      Text(date, style: myTextStyleLarge(context),),
                      Text(stringsHelper!.timeLastUpdate, style: myTextStyleTiny(context),),
                    ],
                  ),
                ),
                gapW16,
                ActivityWidget(
                    number: dispatches.length,
                    caption: stringsHelper!.dispatchesText,
                    numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                    captionStyle: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 12),
                    color: Colors.deepOrange),
                ActivityWidget(
                    number: arrivals.length,
                    caption: stringsHelper!.arrivalsText,
                    numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                    captionStyle: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 12),
                    color: Colors.teal.shade700),
                ActivityWidget(
                    number: totalPassengers,
                    caption: stringsHelper!.passengers,
                    numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                    captionStyle: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 12),
                    color: Colors.blue),
                ActivityWidget(
                    number: departures.length,
                    caption: stringsHelper!.departuresText,
                    numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                    captionStyle: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 12),
                    color: Colors.brown),
                ActivityWidget(
                  number: heartbeats.length,
                  caption: stringsHelper!.heartbeats,
                  numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                  color: Colors.indigo.shade700,
                  captionStyle: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 12),
                ),
                ActivityWidget(
                  number: commuterRequests.length,
                  caption: stringsHelper!.commutersText,
                  numberStyle: myTextStyleSmallWithColor(context, Colors.white),
                  color: Colors.red.shade700,
                  captionStyle: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ActivityWidget extends StatelessWidget {
  const ActivityWidget(
      {super.key,
      required this.number,
      required this.caption,
      this.padding,
      this.captionStyle,
      this.numberStyle,
      required this.color,
      this.elevation});
  final int number;
  final String caption;
  final double? padding;
  final TextStyle? captionStyle, numberStyle;
  final Color color;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return Card(
      shape: getRoundedBorder(radius: 12),
      elevation: elevation == null? 12: elevation!,
      child: Center(
        child: SizedBox(
          width: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              bd.Badge(
                badgeContent: Text(
                  fmt.format(number),
                  style: numberStyle == null
                      ? myTextStyleSmall(context)
                      : numberStyle!,
                ),
                badgeStyle: bd.BadgeStyle(
                  badgeColor: color,
                  padding: EdgeInsets.all(12.0),
                  elevation: elevation == null ? 8 : elevation!,
                ),
              ),
              gapH8,
              Text(
                caption,
                style: captionStyle == null
                    ? myTextStyleSmall(context)
                    : captionStyle!,
              ),
              gapH8,
            ],
          ),
        ),
      ),
    );
  }
}
