import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
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

class LiveDisplay extends StatefulWidget {
  const LiveDisplay({super.key, required this.width, required this.cutoffDate, required this.height});

  final double width, height;
  final DateTime cutoffDate;

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
    setState(() {});
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
      pp('$mm commuterRequestStreamStream delivered event ... ${E.heartBlue}  ${event.dateRequested} - ${event.commuterRequestId}');
      if (commuterRequest != null) {
        if (commuterRequest!.commuterRequestId! == event.commuterRequestId) {
          pp('$mm ... commuterRequest ignored - is duplicate');
        } else {
          commuterRequests.add(event);
          commuterRequest = event;
          _updateCommuters();
        }
      } else {
        commuterRequests.add(event);
        commuterRequest = event;
        _updateCommuters();
      }
    });
    heartbeatStreamSubscription = fcmBloc.heartbeatStreamStream.listen((event) {
      pp('$mm heartbeatStreamStream delivered event ... ${E.heartBlue}  ${event.created} - ${event.vehicleHeartbeatId} -  ${event.vehicleReg}');
      if (vehicleHeartbeat != null) {
        if (vehicleHeartbeat!.vehicleHeartbeatId! == event.vehicleHeartbeatId) {
          pp('$mm ... heartbeat ignored - is duplicate');
        } else {
          heartbeats.add(event);
          vehicleHeartbeat = event;
          _updateHeartbeats();
        }
      } else {
        heartbeats.add(event);
        vehicleHeartbeat = event;
        _updateHeartbeats();
      }
    });

    arrivalStreamSubscription = fcmBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered.  ${event.created} - ${event.vehicleArrivalId}  - ${event.vehicleReg}');
      if (vehicleArrival != null) {
        if (vehicleArrival!.vehicleArrivalId! == event.vehicleArrivalId) {
          pp('$mm ... arrival ignored - is duplicate');
        } else {
          arrivals.add(event);
          vehicleArrival = event;
          _updateArrivals();
        }
      } else {
        arrivals.add(event);
        vehicleArrival = event;
        _updateArrivals();
      }
    });
    departureStreamSubscription =
        fcmBloc.vehicleDepartureStream.listen((event) {
      pp('$mm ... vehicleDepartureStream delivered.  ${event.created} - ${event.vehicleDepartureId} - ${event.vehicleReg}');
      if (vehicleDeparture != null) {
        if (vehicleDeparture!.vehicleDepartureId! == event.vehicleDepartureId) {
          pp('$mm ... departure ignored - is duplicate');
        } else {
          departures.add(event);
          vehicleDeparture = event;
          _updateDepartures();
        }
      } else {
        departures.add(event);
        vehicleDeparture = event;
        _updateDepartures();
      }
    });
    dispatchStreamSubscription = fcmBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered. ${event.created} - ${event.dispatchRecordId}');
      if (dispatchRecord != null) {
        if (dispatchRecord!.dispatchRecordId! == event.dispatchRecordId) {
          pp('$mm ... dispatch ignored - is duplicate');
        } else {
          dispatches.add(event);
          dispatchRecord = event;
          _updateDispatches();
        }
      } else {
        dispatches.add(event);
        dispatchRecord = event;
        _updateDispatches();
      }
    });
    passengerStreamSubscription = fcmBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered.  ${event.created} - ${event.passengerCountId}');
      myPrettyJsonPrint(event.toJson());
      if (passengerCount != null) {
        if (passengerCount!.passengerCountId! == event.passengerCountId) {
          pp('$mm ... passenger count ignored - is duplicate');
        } else {
          passengerCounts.add(event);
          passengerCount = event;
          _updateCounts();
        }
      } else {
        passengerCounts.add(event);
        passengerCount = event;
        _updateCounts();
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

  DispatchRecord? dispatchRecord;
  VehicleArrival? vehicleArrival;
  VehicleDeparture? vehicleDeparture;
  VehicleHeartbeat? vehicleHeartbeat;
  CommuterRequest? commuterRequest;
  AmbassadorPassengerCount? passengerCount;

  //
  void _updateHeartbeats() {
    final mHeartbeats = <VehicleHeartbeat>[];
    for (var value in heartbeats) {
      var date = DateTime.parse(value.created!);
      if (date.isAfter(widget.cutoffDate)) {
        mHeartbeats.add(value);
      }
    }
    heartbeats = mHeartbeats;
    if (mounted) {
      setState(() {

      });
    }
  }
  void _updateCommuters() {
    final mCommuterRequests = <CommuterRequest>[];
    pp('$mm ... commuterRequests: ${commuterRequests.length}');
    for (var value in commuterRequests) {
      var date = DateTime.parse(value.dateRequested!);
      if (date.isAfter(widget.cutoffDate)) {
        mCommuterRequests.add(value);
      }
    }
    commuterRequests = mCommuterRequests;
    pp('$mm ... commuterRequests after filtering: ${commuterRequests.length}');
    if (mounted) {
      setState(() {});
    }
  }
  void _updateDispatches() {
    final mDispatches = <DispatchRecord>[];
    pp('$mm ... dispatches: ${dispatches.length}');

    for (var value in dispatches) {
      var date = DateTime.parse(value.created!);
      if (date.isAfter(widget.cutoffDate)) {
        mDispatches.add(value);
      }
    }
    dispatches = mDispatches;
    pp('$mm ... dispatches after filter: ${dispatches.length}');
    if (mounted) {
      setState(() {});
    }
  }
  void _updateDepartures() {
    final mDepartures = <VehicleDeparture>[];
    for (var value in departures) {
      var date = DateTime.parse(value.created!);
      if (date.isAfter(widget.cutoffDate)) {
        mDepartures.add(value);
      }
    }
    departures = mDepartures;
    if (mounted) {
      setState(() {});
    }
  }
  void _updateArrivals() {
    final mArrivals = <VehicleArrival>[];
    for (var value in arrivals) {
      var date = DateTime.parse(value.created!);
      if (date.isAfter(widget.cutoffDate)) {
        mArrivals.add(value);
      }
    }
    arrivals = mArrivals;
    if (mounted) {
      setState(() {});
    }
  }
  void _updateCounts() {
    final mCounts = <AmbassadorPassengerCount>[];
    for (var value in passengerCounts) {
      var date = DateTime.parse(value.created!);
      if (date.isAfter(widget.cutoffDate)) {
        mCounts.add(value);
      }
    }
    pp('$mm ............ _updateCounts: totalPassengers: $totalPassengers');
    passengerCounts = mCounts;
    totalPassengers = 0;
    for (var value in mCounts) {
      totalPassengers += value.passengersIn!;
    }
    pp('$mm ............ _updateCounts: totalPassengers after recount: $totalPassengers from ${mCounts.length}');

    if (mounted) {
      setState(() {});
    }
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

  List<ActivityWidget> widgets = [];
  void _buildWidgets() {
        if (stringsHelper == null) {
          return;
        }
        widgets.add(ActivityWidget(
            number: dispatches.length,
            caption: stringsHelper!.dispatchesText,
            numberStyle:
            myTextStyleSmallWithColor(context, Colors.white),
            captionStyle: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 12),
            color: Colors.deepOrange),);
        widgets.add(ActivityWidget(
            number: arrivals.length,
            caption: stringsHelper!.arrivalsText,
            numberStyle:
            myTextStyleSmallWithColor(context, Colors.white),
            captionStyle: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 12),
            color: Colors.teal.shade700),);
        widgets.add(ActivityWidget(
            number: totalPassengers,
            caption: stringsHelper!.passengers,
            numberStyle:
            myTextStyleSmallWithColor(context, Colors.white),
            captionStyle: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 12),
            color: Colors.blue),);
        widgets.add(ActivityWidget(
            number: departures.length,
            caption: stringsHelper!.departuresText,
            numberStyle:
            myTextStyleSmallWithColor(context, Colors.white),
            captionStyle: myTextStyleMediumLargeWithColor(
                context, Theme.of(context).primaryColor, 12),
            color: Colors.brown),);
        widgets.add(ActivityWidget(
          number: heartbeats.length,
          caption: stringsHelper!.heartbeats,
          numberStyle:
          myTextStyleSmallWithColor(context, Colors.white),
          color: Colors.indigo.shade700,
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
        ),);
        widgets.add(ActivityWidget(
          number: commuterRequests.length,
          caption: stringsHelper!.commutersText,
          numberStyle:
          myTextStyleSmallWithColor(context, Colors.white),
          color: Colors.red.shade700,
          captionStyle: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 12),
        ),);
  }

  @override
  Widget build(BuildContext context) {
    final date = getFormattedDateHour(DateTime.now().toIso8601String());
    pp('$mm ... ${dispatches.length} ... dispatches, if zero,  FUCK!');
    _buildWidgets();
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
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6),
                      itemCount: widgets.length,
                      itemBuilder: (ctx,index){
                        final w = widgets.elementAt(index);
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
      this.elevation, this.width});

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
          width: width == null?100:width!,
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
