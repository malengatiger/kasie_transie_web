import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasie_transie_web/blocs/stream_bloc.dart';
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

class LiveDisplay extends StatefulWidget {
  const LiveDisplay(
      {super.key,
      required this.width,
      required this.cutoffDate,
      required this.height});

  final double width, height;
  final DateTime cutoffDate;

  @override
  State<LiveDisplay> createState() => _LiveDisplayState();
}

class _LiveDisplayState extends State<LiveDisplay> {
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  late StreamSubscription<VehicleArrival> arrivalStreamSubscription;
  late StreamSubscription<VehicleDeparture> departureStreamSubscription;
  late StreamSubscription<DispatchRecord> dispatchStreamSubscription;
  late StreamSubscription<AmbassadorPassengerCount> passengerStreamSubscription;
  late StreamSubscription<LocationRequest> locationRequestStreamSubscription;
  late StreamSubscription<LocationResponse> locationResponseStreamSubscription;
  late StreamSubscription<CommuterRequest> commuterReqStreamSubscription;
  @override
  void dispose() {
    heartbeatStreamSubscription.cancel();
    arrivalStreamSubscription.cancel();
    departureStreamSubscription.cancel();
    dispatchStreamSubscription.cancel();
    passengerStreamSubscription.cancel();
    commuterReqStreamSubscription.cancel();
    locationRequestStreamSubscription.cancel();
    locationResponseStreamSubscription.cancel();
    super.dispose();
  }

  List<VehicleHeartbeat> heartbeats = [];
  List<VehicleArrival> arrivals = [];
  List<VehicleDeparture> departures = [];
  List<DispatchRecord> dispatches = [];
  List<AmbassadorPassengerCount> passengerCounts = [];
  List<CommuterRequest> commuterRequests = [];

  late StreamSubscription<bool> subscription;

  int totalPassengers = 0;
  static const mm = '🔷🔷🔷🔷 🔴LiveDisplay 🔷🔷🔷🔷';

  @override
  void initState() {
    super.initState();
    _listen();
    _setText();
  }

  StringsHelper? stringsHelper;

  Future _setText() async {
    stringsHelper = await StringsHelper.getTranslatedTexts();
    setState(() {});
  }

  void _listen() {
    pp('$mm ........... will listen to fcm messages from the JavaScript side ... '
        '${E.heartBlue} ${E.heartBlue} ${E.heartBlue} ...');

    subscription = translator.translationStream.listen((event) {
      pp('$mm ... translationStream ');
      if (mounted) {
        _setText();
      }
    });
    commuterReqStreamSubscription =
        streamBloc.commuterRequestStreamStream.listen((event) {
      pp('$mm commuterRequestStreamStream delivered.  ${E.heartBlue}${E.heartBlue}  ${event.dateRequested} - ${event.commuterRequestId}');
      commuterRequests.add(event);
      _setTheState();
    });
    heartbeatStreamSubscription =
        streamBloc.heartbeatStreamStream.listen((event) {
          heartbeats.add(event);
          pp('$mm heartbeatStreamStream delivered event ... 😡😡😡  '
          '${event.created} - vehicleHeartbeatId: ${event.vehicleHeartbeatId} '
              '-  ${event.vehicleReg} heartbeats: ${heartbeats.length}');
      _setTheState();
    });

    arrivalStreamSubscription = streamBloc.vehicleArrivalStream.listen((event) {
      pp('$mm vehicleArrivalStream delivered.  🔵🔵 ${event.created} - ${event.vehicleArrivalId}  - ${event.vehicleReg}');
      arrivals.add(event);
      _setTheState();
    });
    departureStreamSubscription =
        streamBloc.vehicleDepartureStream.listen((event) {
      pp('$mm vehicleDepartureStream delivered.  🔵🔵 ${event.created} - ${event.vehicleDepartureId} - ${event.vehicleReg}');
      departures.add(event);
      _setTheState();
    });
    dispatchStreamSubscription = streamBloc.dispatchStream.listen((event) {
      pp('$mm dispatchStream delivered. ✅✅✅ ${event.created} - ${event.dispatchRecordId}');
      dispatches.add(event);
      _setTheState();
    });
    passengerStreamSubscription =
        streamBloc.passengerCountStream.listen((event) {
      pp('$mm passengerCountStream delivered.  🍎🍎 ${event.created} - ${event.passengerCountId}');
      passengerCounts.add(event);
      _updateCounts();
    });
    locationResponseStreamSubscription =
        streamBloc.locationResponseStream.listen((event) {
      pp('$mm ... locationResponseStream delivered. ');
      _setTheState();
    });

    locationRequestStreamSubscription =
        streamBloc.locationRequestStream.listen((event) {
      pp('$mm ... locationRequestStream delivered. ');
      _setTheState();
        });
  }

  DispatchRecord? dispatchRecord;
  VehicleArrival? vehicleArrival;
  VehicleDeparture? vehicleDeparture;
  VehicleHeartbeat? vehicleHeartbeat;
  CommuterRequest? commuterRequest;
  AmbassadorPassengerCount? passengerCount;

  //
  void _setTheState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateCounts() {
    for (var value in passengerCounts) {
      totalPassengers += value.passengersIn!;
    }
    pp('$mm ............ _updateCounts: totalPassengers after recount: $totalPassengers '
        'from ${passengerCounts.length}');
    _setTheState();
  }

  List<ActivityWidget> _buildWidgets() {
    List<ActivityWidget> widgets = [];
    widgets.add(
      ActivityWidget(
          number: dispatches.length,
          caption: stringsHelper!.dispatchesText,
          numberStyle: myTextStyleSmallWithColor(context, Colors.white),
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
          color: Colors.deepOrange),
    );
    widgets.add(
      ActivityWidget(
          number: arrivals.length,
          caption: stringsHelper!.arrivalsText,
          numberStyle: myTextStyleSmallWithColor(context, Colors.white),
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
          color: Colors.teal.shade700),
    );
    widgets.add(
      ActivityWidget(
          number: totalPassengers,
          caption: stringsHelper!.passengers,
          numberStyle: myTextStyleSmallWithColor(context, Colors.white),
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
          color: Colors.blue),
    );
    widgets.add(
      ActivityWidget(
          number: departures.length,
          caption: stringsHelper!.departuresText,
          numberStyle: myTextStyleSmallWithColor(context, Colors.white),
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
          color: Colors.brown),
    );
    widgets.add(
      ActivityWidget(
        number: heartbeats.length,
        caption: stringsHelper!.heartbeats,
        numberStyle: myTextStyleSmallWithColor(context, Colors.white),
        color: Colors.indigo.shade700,
        captionStyle: myTextStyleMediumLargeWithColor(
            context, Theme.of(context).primaryColor, 12),
      ),
    );
    widgets.add(
      ActivityWidget(
        number: commuterRequests.length,
        caption: stringsHelper!.commutersText,
        numberStyle: myTextStyleSmallWithColor(context, Colors.white),
        color: Colors.red.shade700,
        captionStyle: myTextStyleMediumLargeWithColor(
            context, Theme.of(context).primaryColor, 12),
      ),
    );
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    var mWidgets = <ActivityWidget>[];
    if (stringsHelper != null) {
      mWidgets = _buildWidgets();
    }
    // pp('$mm ... build build build build ... mWidgets: ${mWidgets.length} heartbeats: ${heartbeats.length}');

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: Center(
        child: stringsHelper == null
            ? gapW32
            : Card(
                shape: getDefaultRoundedBorder(),
                elevation: 4,
                // color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: mWidgets.length),
                      itemCount: mWidgets.length,
                      itemBuilder: (ctx, index) {
                        final w = mWidgets.elementAt(index);
                        return w;
                      }),
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
      this.elevation,
      this.width});

  final int number;
  final String caption;
  final double? padding;
  final TextStyle? captionStyle, numberStyle;
  final Color color;
  final double? elevation, width;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.decimalPattern();
    return Card(
      shape: getRoundedBorder(radius: 12),
      elevation: elevation == null ? 12 : elevation!,
      child: Center(
        child: SizedBox(
          width: width == null ? 100 : width!,
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
