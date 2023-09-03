import 'dart:async';
import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/association_bag.dart';
import 'package:kasie_transie_web/data/association_heartbeat_aggregation_result.dart';
import 'package:kasie_transie_web/email_auth_signin.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/color_and_locale.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/javascript_message_util.dart';
import 'package:kasie_transie_web/utils/navigator_utils.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/association_bag_widget.dart';
import 'package:kasie_transie_web/widgets/charts/heartbeat_line_chart.dart';
import 'package:kasie_transie_web/widgets/counts_widget.dart';
import 'package:kasie_transie_web/widgets/dashboard_widgets/side_board.dart';
import 'package:kasie_transie_web/widgets/days_drop_down.dart';
import 'package:kasie_transie_web/widgets/demo_driver.dart';
import 'package:kasie_transie_web/widgets/live_activities.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_onboarding.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import 'blocs/stream_bloc.dart';
import 'data/ambassador_passenger_count.dart';
import 'data/commuter_request.dart';
import 'data/dispatch_record.dart';
import 'data/location_request.dart';
import 'data/location_response.dart';
import 'data/user.dart';
import 'data/vehicle.dart';
import 'data/vehicle_arrival.dart';
import 'data/vehicle_departure.dart';
import 'data/vehicle_heartbeat.dart';
import 'data/vehicle_heartbeat_aggregation_result.dart';
import 'l10n/translation_handler.dart';
import 'maps/association_route_maps.dart';
import 'maps/association_route_operations.dart';

class AssociationDashboard extends StatefulWidget {
  const AssociationDashboard({Key? key}) : super(key: key);

  @override
  State<AssociationDashboard> createState() => _AssociationDashboardState();
}

class _AssociationDashboardState extends State<AssociationDashboard> {
  final mm = '🥬🥬🥬🥬🥬🥬 AssociationDashboard: 😡';

  User? user;
  // AssociationBag? bigBag;
  bool busy = false;
  int totalPassengers = 0;
  List<Vehicle> cars = [];
  String? ownerDashboard,
      numberOfCars,
      arrivalsText,
      departuresText,
      heartbeatText,
      daysText,
      loadingOwnerData,
      errorGettingData,
      passengerCounts,
      thisMayTakeMinutes,
      historyCars,
      dispatchesText;
  int days = 1;

  bool _showSettings = false;
  bool _showPassengerReport = false;
  bool _showDispatchReport = false;
  bool _showSendMessage = false;
  bool _showCarLocation = false;
  bool _showCars = false;
  bool _showUsers = false;

  late StreamSubscription<AssociationBag> assocBagStreamSubscription;
  late StreamSubscription<VehicleHeartbeat> heartbeatStreamSubscription;
  late StreamSubscription<VehicleArrival> arrivalStreamSubscription;
  late StreamSubscription<VehicleDeparture> departureStreamSubscription;
  late StreamSubscription<DispatchRecord> dispatchStreamSubscription;
  late StreamSubscription<AmbassadorPassengerCount> passengerStreamSubscription;
  late StreamSubscription<CommuterRequest> commuterStreamSubscription;
  late StreamSubscription<LocationRequest> locationRequestStreamSubscription;
  late StreamSubscription<LocationResponse> locationResponseStreamSubscription;

  String notRegistered =
      'You are not registered yet. Please call your administrator';
  String emailNotFound = 'emailNotFound';
  String welcome = 'Welcome';
  String firstTime =
      'This is the first time that you have opened the app and you '
      'need to sign in to your Taxi Association.';
  String changeLanguage = 'Change Language or Color';
  String startEmailLinkSignin = 'Start Email Link Sign In';
  String signInWithPhone = 'Start Phone Sign In';
  late ColorAndLocale colorAndLocale;
  List<AssociationHeartbeatAggregationResult> timeSeriesResults = [];
  AssociationBag? bag;
  List<VehicleHeartbeat> heartbeats = [];
  String date = DateTime.now().toUtc().subtract(Duration(days: 1)).toIso8601String();

  @override
  void initState() {
    super.initState();
    control();
  }

  control() async {
    await _getTokenAndData();
    await _setTexts();
    _listen();
    _getData(false);

  }
  @override
  void dispose() {
    assocBagStreamSubscription.cancel();
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

  void _listen() {
    pp('$mm will listen to fcm messaging ... '
        '${E.heartBlue} ${E.heartBlue} ${E.heartBlue} ...');

    assocBagStreamSubscription =
        networkHandler.associationBagStream.listen((event) async {
          pp('$mm associationBagStream delivered event ... ${E.heartBlue} ');
          bag = event;
          final d = DateTime.now().toLocal().toIso8601String();
          final cl = await prefs.getColorAndLocale();
          date = await getFmtDate(d, cl.locale, context);
          if (mounted) {
            setState(() {});
          }
        });

    heartbeatStreamSubscription = streamBloc.heartbeatStreamStream.listen((event) {
      pp('$mm heartbeatStreamStream delivered event ... ${E.heartBlue} ');
      heartbeats.add(event);
      if (mounted) {
        setState(() {});
      }
    });

    arrivalStreamSubscription = streamBloc.vehicleArrivalStream.listen((event) {
      pp('$mm ... vehicleArrivalStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    departureStreamSubscription =
        streamBloc.vehicleDepartureStream.listen((event) {
          pp('$mm ... vehicleDepartureStream delivered. ');
          if (mounted) {
            setState(() {});
          }
        });
    dispatchStreamSubscription = streamBloc.dispatchStream.listen((event) {
      pp('$mm ... dispatchStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    passengerStreamSubscription = streamBloc.passengerCountStream.listen((event) {
      pp('$mm ... passengerCountStream delivered. ');
      if (mounted) {
        setState(() {});
      }
    });
    locationResponseStreamSubscription =
        streamBloc.locationResponseStream.listen((event) {
          pp('$mm ... locationResponseStream delivered. ');
          if (mounted) {
            setState(() {});
          }
        });

    locationRequestStreamSubscription =
        streamBloc.locationRequestStream.listen((event) {
          pp('$mm ... locationRequestStream delivered. ');
          if (mounted) {
            setState(() {});
          }
        });
  }


  Future _getTokenAndData() async {
    user = await prefs.getUser();
    if (user == null) {
      _navigateToEmailAuth();
    } else {
      pp('$mm ... calling javascriptMessageUtil to get FCM token via JavaScript ...');
      await javascriptMessageUtil.getTokenAndData(window, user!);
    }
  }


  Future _setTexts() async {
    var c = await prefs.getColorAndLocale();
    numberOfCars = await translator.translate('numberOfCars', c.locale);
    arrivalsText = await translator.translate('arrivals', c.locale);
    departuresText = await translator.translate('departures', c.locale);
    heartbeatText = await translator.translate('heartbeats', c.locale);
    dispatchesText = await translator.translate('dispatches', c.locale);
    ownerDashboard = await translator.translate('dashboard', c.locale);
    daysText = await translator.translate('days', c.locale);
    historyCars = await translator.translate('historyCars', c.locale);
    passengerCounts = await translator.translate('passengersIn', c.locale);
    loadingOwnerData = await translator.translate('loadingOwnerData', c.locale);
    thisMayTakeMinutes =
        await translator.translate('thisMayTakeMinutes', c.locale);
    errorGettingData = await translator.translate('errorGettingData', c.locale);
    emailNotFound = await translator.translate('emailNotFound', c.locale);
    notRegistered = await translator.translate('notRegistered', c.locale);
    firstTime = await translator.translate('firstTime', c.locale);
    changeLanguage = await translator.translate('changeLanguage', c.locale);
    welcome = await translator.translate('welcome', c.locale);
    startEmailLinkSignin =
        await translator.translate('signInWithEmail', c.locale);
    signInWithPhone = await translator.translate('signInWithPhone', c.locale);
    setState(() {});
  }

  Future _navigateToColor() async {
    pp('$mm _navigateToColor popup inside dialog or bottom sheet ......');
    // await navigateWithScale(
    //     LanguageAndColorChooser(
    //       onLanguageChosen: () {},
    //     ),
    //     context);
    colorAndLocale = await prefs.getColorAndLocale();
    await _setTexts();
  }

  Future<void> _navigateToEmailAuth() async {
    var res = await navigateWithScale(
        EmailAuthSignin(
          onGoodSignIn: (u) {
            pp('\n\n$mm ................ onGoodSignIn: ${u.toJson()}');
          },
          onSignInError: () {
            if (mounted) {
              showSnackBar(
                  duration: const Duration(seconds: 2),
                  padding: 20,
                  backgroundColor: Theme.of(context).primaryColor,
                  textStyle: myTextStyleMedium(context),
                  message: 'Error: Sign in failed',
                  context: context);
            }
          },
          refresh: true,
        ),
        context);

    pp('\n\n$mm ................ back from sign in: $res, call _getTokenAndData() ');
    user = await prefs.getUser();
    await _getTokenAndData();
    _getData(true);
  }

  Future<void> _navigateToMaps() async {
    await navigateWithScale(const AssociationRouteOperations(), context);
    user = await prefs.getUser();
    _getData(false);
  }

  Future<void> _navigateToRouteAssignments() async {
    // await navigateWithScale(const RouteAssigner(), context);
    // user = await prefs.getUser();
    // _getData(false);
  }

  Future _refreshBag() async {
    date = DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String();
    setState(() {
      busy = true;
    });
    try {
      _handleData(true);
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.redAccent,
            textStyle: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
            message: errorGettingData == null
                ? 'Error getting data'
                : errorGettingData!,
            context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _getData(bool refresh) async {
    pp('$mm ............................ getting association bag, cars and timeSeries data ....');
    try {
      setState(() {
        busy = true;
      });
      user = await prefs.getUser();
      if (user == null) {
        throw Exception('Fuck!! No User');
      }
      if (user!.userId == null) {
        throw Exception('Fuck!! No User id! wtf?');
      }
      await _handleData(refresh);
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            duration: const Duration(seconds: 10),
            backgroundColor: Colors.red,
            textStyle: const TextStyle(color: Colors.white),
            message: 'Error getting data: $e',
            context: context);
      }
    }
    pp('$mm ........ setting state ${E.peach}..... association bag, cars and timeSeries data obtained....');
    setState(() {
      busy = false;
    });
  }

  Future<void> _handleData(bool refresh) async {
    final date = DateTime.now().toUtc().subtract(Duration(days: days));
    pp('$mm _handleData ............................ '
        'getting association time series ...');

    timeSeriesResults = await networkHandler.getAssociationHeartbeatTimeSeries(
        user!.associationId!, date.toIso8601String());
    cars = await networkHandler.getAssociationVehicles(
        associationId: user!.associationId!, refresh: refresh);

    pp('$mm _handleData .. association 🔵🔵 timeSeries : '
        '${E.appleRed} ${timeSeriesResults.length}');

    setState(() {});
  }

  Future<void> _navigateToUserList() async {
    pp('$mm .... _navigateToUserList ..........');
    await navigateWithScale(
        UserOnboarding(),
        context);
    pp('$mm .... back from car list');
  }


  Future<void> _navigateToCarList() async {
    pp('$mm .... _navigateToCarList ..........');
    await navigateWithScale(
        CarList(
          cars: cars,
          onCarPicked: (car) {},
        ),
        context);
    pp('$mm .... back from car list');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    // pp('$mm ................... width: $width height: $height');
    final width1 = 300.0;
    final width2 = 800.0;
    final width3 = 440.0;

    final cutoffDate = DateTime.now().toUtc().subtract(Duration(days: days));
    // pp('$mm build ................... time-series: ${timeSeriesResults.length}');

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Association Dashboard',
                  style: myTextStyleMediumLarge(context, 18),
                ),
                gapW32,
                gapW32,
                Text(
                  'History for all data',
                  style: myTextStyleSmall(context),
                ),
                gapW16,
                Text(
                  '$days',
                  style: myTextStyleMediumLargeWithColor(
                      context, Theme.of(context).primaryColor, 20),
                ),
                gapW32,
                DaysDropDown(
                    onDaysPicked: (d) {
                      setState(() {
                        days = d;
                        date = DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String();
                      });
                      _refreshBag();
                    },
                    hint: daysText == null ? 'Days' : daysText!),
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    _navigateToColor();
                  },
                  icon: Icon(
                    Icons.color_lens,
                    color: Theme.of(context).primaryColor,
                  )),
              IconButton(
                  onPressed: () {
                    _navigateToMaps();
                  },
                  icon: Icon(
                    Icons.map,
                    color: Theme.of(context).primaryColor,
                  )),
              IconButton(
                  onPressed: () {
                    _navigateToCarList();
                  },
                  icon: Icon(Icons.airport_shuttle,
                      color: Theme.of(context).primaryColor)),
              IconButton(
                  onPressed: () {
                    _navigateToRouteAssignments();
                  },
                  icon: Icon(Icons.settings,
                      color: Theme.of(context).primaryColor)),
            ],
          ),
          body: Stack(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: width1,
                    child: SideBoard(
                        title: 'Menu',
                        onUsers: () {
                          setState(() {
                            _navigateToUserList();
                          });
                        },
                        onCars: () {
                          setState(() {
                            _showCars = true;
                          });
                        },
                        onLocateCar: () {
                          setState(() {
                            _showCarLocation = true;
                          });
                        },
                        onSendMessage: () {
                          setState(() {
                            _showSendMessage = true;
                          });
                        },
                        onDispatchReport: () {
                          setState(() {
                            _showDispatchReport = true;
                          });
                        },
                        onPassengerReport: () {
                          setState(() {
                            _showPassengerReport = true;
                          });
                        },
                        onSettings: () {
                          setState(() {
                            _showSettings = true;
                          });
                        }),
                  ),
                  gapW32,
                   SizedBox(
                    width: width2,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Card(
                            shape: getDefaultRoundedBorder(),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                  height: 540,
                                  child: const AssociationHeartbeatChart(
                                  )),
                            ),
                          ),
                          gapH32,
                          gapH32,
                          LiveDisplay(
                              width: 840, height: 160, cutoffDate: cutoffDate),
                        ],
                      ),
                    ),
                  ),
                  gapW32,
                 SizedBox(
                    width: width3,
                    child: dispatchesText == null? gapW32: AssociationCountsWidget(
                        color: Theme.of(context).cardColor,
                        width: width,
                        operationsSummary: 'Operations Summary',
                        dispatches: dispatchesText!,
                        passengers: passengerCounts!,
                        arrivals: arrivalsText!,
                        departures: departuresText!,
                        heartbeats: heartbeatText!,
                        lastUpdated: DateTime.now().toIso8601String(),
                        date: date),
                  ),
                ],
              ),
              busy? Positioned(child: Center(child: TimerWidget(title: 'Loading data ...'))): gapW32,
            ],
          )),
    );
  }
}

class SignInLanding extends StatelessWidget {
  const SignInLanding(
      {Key? key,
      required this.welcome,
      required this.firstTime,
      required this.changeLanguage,
      required this.signInWithPhone,
      required this.startEmailLinkSignin,
      required this.onNavigateToEmailAuth,
      required this.onNavigateToPhoneAuth,
      required this.onNavigateToColor})
      : super(key: key);

  final String welcome,
      firstTime,
      changeLanguage,
      signInWithPhone,
      startEmailLinkSignin;
  final Function onNavigateToEmailAuth,
      onNavigateToPhoneAuth,
      onNavigateToColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              'assets/gio.png',
            )),
        const SizedBox(
          height: 12,
        ),
        Text(
          welcome,
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColorLight, 40),
        ),
        const SizedBox(
          height: 32,
        ),
        Text(
          firstTime,
          style: myTextStyleMedium(context),
        ),
        const SizedBox(
          height: 24,
        ),
        SizedBox(
          width: 300,
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: const MaterialStatePropertyAll(4.0),
              backgroundColor:
                  MaterialStatePropertyAll(Theme.of(context).primaryColorLight),
            ),
            onPressed: () {
              onNavigateToColor();
            },
            // icon: const Icon(Icons.language),

            child: Text(
              changeLanguage,
              style: myTextStyleSmallBlack(context),
            ),
          ),
        ),
        const SizedBox(
          height: 160,
        ),
        SizedBox(
          width: 340,
          child: ElevatedButton.icon(
              onPressed: () {
                onNavigateToPhoneAuth();
              },
              style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(8.0),
                backgroundColor:
                    MaterialStatePropertyAll(Theme.of(context).primaryColor),
              ),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  signInWithPhone,
                  style: myTextStyleSmallBlack(context),
                ),
              ),
              icon: const Icon(Icons.phone)),
        ),
        const SizedBox(
          height: 24,
        ),
        Container(
          color: Theme.of(context).primaryColorLight,
          width: 160,
          height: 2,
        ),
        const SizedBox(
          height: 24,
        ),
        SizedBox(
          width: 340,
          child: ElevatedButton.icon(
              onPressed: () {
                onNavigateToEmailAuth();
              },
              style: ButtonStyle(
                elevation: const MaterialStatePropertyAll(8.0),
                backgroundColor:
                    MaterialStatePropertyAll(Theme.of(context).primaryColor),
              ),
              icon: const Icon(Icons.email),
              label: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  startEmailLinkSignin,
                  style: myTextStyleSmallBlack(context),
                ),
              )),
        ),
        const SizedBox(
          height: 24,
        ),
      ],
    );
  }
}
