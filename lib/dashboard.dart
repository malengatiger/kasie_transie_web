import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/association_bag.dart';
import 'package:kasie_transie_web/data/association_heartbeat_aggregation_result.dart';
import 'package:kasie_transie_web/email_auth_signin.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/color_and_locale.dart';
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/navigator_utils.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/counts_widget.dart';
import 'package:kasie_transie_web/widgets/dashboard_widgets/side_board.dart';
import 'package:kasie_transie_web/widgets/days_drop_down.dart';
import 'package:kasie_transie_web/widgets/demo_driver.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import 'blocs/fcm_bloc.dart';
import 'data/ambassador_passenger_count.dart';
import 'data/dispatch_record.dart';
import 'data/location_response.dart';
import 'data/user.dart';
import 'data/vehicle.dart';
import 'data/vehicle_arrival.dart';
import 'data/vehicle_departure.dart';
import 'data/vehicle_heartbeat_aggregation_result.dart';
import 'l10n/translation_handler.dart';
import 'maps/association_route_maps.dart';

class AssociationDashboard extends StatefulWidget {
  const AssociationDashboard({Key? key}) : super(key: key);

  @override
  State<AssociationDashboard> createState() => _AssociationDashboardState();
}

class _AssociationDashboardState extends State<AssociationDashboard> {
  final mm = '🥬🥬🥬🥬🥬🥬 AssociationDashboard: 😡';

  User? user;
  AssociationBag? bigBag;
  bool busy = false;
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

  late StreamSubscription<DispatchRecord> dispatchStreamSub;
  late StreamSubscription<AmbassadorPassengerCount> passengerStreamSub;
  late StreamSubscription<VehicleArrival> arrivalStreamSub;
  late StreamSubscription<VehicleDeparture> departureStreamSub;
  late StreamSubscription<LocationResponse> locResponseStreamSub;
  late StreamSubscription<List<Vehicle>> vehiclesStreamSub;

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

  @override
  void initState() {
    super.initState();
    _listen();
    _checkAuth();
  }

  @override
  void dispose() {
    dispatchStreamSub.cancel();
    passengerStreamSub.cancel();
    super.dispose();
  }

  void _listen() async {
    pp('$mm ... listen to streams ........ ');
    // vehiclesStreamSub =
    //     networkHandler.vehiclesStream.listen((List<Vehicle> list) {
    //   pp('$mm ... listApiDog.vehiclesStream delivered vehicles for: ${list.length}');
    //   cars = list;
    //   // _refreshBag();
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
    departureStreamSub =
        fcmBloc.vehicleDepartureStream.listen((VehicleDeparture departure) {
      pp('$mm ... fcmBloc.vehicleDepartureStream delivered vehicle departure for: ${departure.vehicleReg}');
      if (mounted) {
        setState(() {});
      }
    });
    locResponseStreamSub = fcmBloc.locationResponseStream
        .listen((LocationResponse locationResponse) {
      pp('$mm ... fcmBloc.locationResponseStream delivered loc response for: ${locationResponse.vehicleReg}');
      if (mounted) {
        setState(() {});
      }
    });
    arrivalStreamSub =
        fcmBloc.vehicleArrivalStream.listen((VehicleArrival vehicleArrival) {
      pp('$mm ... fcmBloc.dispatchStream delivered dispatch for: ${vehicleArrival.vehicleReg}');
      bigBag!.arrivals.add(vehicleArrival);
      if (mounted) {
        setState(() {});
      }
    });
    dispatchStreamSub = fcmBloc.dispatchStream.listen((DispatchRecord dRec) {
      pp('$mm ... fcmBloc.dispatchStream delivered dispatch for: ${dRec.vehicleReg}');
      bigBag!.dispatchRecords.add(dRec);
      totalPassengers += dRec.passengers!;
      if (mounted) {
        setState(() {});
      }
    });
    passengerStreamSub =
        fcmBloc.passengerCountStream.listen((AmbassadorPassengerCount cunt) {
      pp('$mm ... fcmBloc.passengerCountStream delivered count for: ${cunt.vehicleReg}');
      bigBag!.passengerCounts.add(cunt);
      _calculateTotalPassengers();
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _checkAuth() async {
    await _setTexts();
    user = await prefs.getUser();
    if (user == null) {
      _navigateToEmailAuth();
    } else {
      _getPermission();
      _getData(false);
    }
  }

  void _getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
    ].request();
    pp('$mm PermissionStatus: statuses: $statuses');
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
    pp('\n\n$mm ................ back from sign in: $res');
    user = await prefs.getUser();
    _getData(false);
  }

  Future<void> _navigateToMaps() async {
    await navigateWithScale(const AssociationRouteMaps(), context);
    user = await prefs.getUser();
    _getData(false);
  }

  Future<void> _navigateToRouteAssignments() async {
    // await navigateWithScale(const RouteAssigner(), context);
    // user = await prefs.getUser();
    // _getData(false);
  }

  int totalPassengers = 0;

  List<AssociationHeartbeatAggregationResult> results = [];
  Future _refreshBag() async {
    final date = DateTime.now().toUtc().subtract(Duration(days: days));
    setState(() {
      busy = true;
    });
    try {
     _handleData();
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
    pp('$mm ............................ getting owner data ....');
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
      await _handleData();
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
    setState(() {
      busy = false;
    });
  }

  Future<void> _handleData() async {
    final date = DateTime.now().toUtc().subtract(Duration(days: days));
    pp('$mm _handleData ............................ '
        'getting association data ...');

    cars = await networkHandler.getAssociationVehicles(user!.associationId!);

    bigBag = await networkHandler.getAssociationBag(
        user!.associationId!, date.toIso8601String());
    results = await networkHandler.getAssociationHeartbeatTimeSeries(
        user!.associationId!, date.toIso8601String());

    pp('$mm _handleData .. association bag: ${E.appleRed} '
        '\n🔴 cars: ${cars.length} '
        '\n🔴 vehicleHeartbeats: ${bigBag?.heartbeats.length} '
        '\n🔴 vehicleArrivals: ${bigBag?.arrivals.length} '
        '\n🔴 dispatchRecords: ${bigBag?.dispatchRecords.length} '
        '\n🔴 passengerCounts: ${bigBag?.passengerCounts.length} '
        '\n🔴 vehicleDepartures: ${bigBag?.departures.length}');

    pp('$mm _handleData: ${E.appleRed} heartbeat aggregates: ${results.length}');
    results.sort((a, b) => a.key.compareTo(b.key));
    if (results.isNotEmpty) {
      pp('$mm _handleData ... last aggregate: ........... : ${E.redDot}');
      myPrettyJsonPrint(results.last.toJson());
    }

    _calculateTotalPassengers();
  }

  void _calculateTotalPassengers() {
    totalPassengers = 0;
    for (var value in bigBag!.passengerCounts) {
      totalPassengers += value.passengersIn!;
    }
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

  int days = 1;

  bool _showSettings = false;
  bool _showPassengerReport = false;
  bool _showDispatchReport = false;
  bool _showSendMessage = false;
  bool _showCarLocation = false;
  bool _showCars = false;
  bool _showUsers = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final sideWidth = width / 4;
    final rightWidth = width - sideWidth;

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
                // _navigateToScanner();
              },
              icon: Icon(Icons.airport_shuttle,
                  color: Theme.of(context).primaryColor)),
          IconButton(
              onPressed: () {
                _navigateToRouteAssignments();
              },
              icon:
                  Icon(Icons.settings, color: Theme.of(context).primaryColor)),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              shape: getRoundedBorder(radius: 16),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: sideWidth,
                      child: SideBoard(
                          title: 'Menu',
                          onUsers: () {
                            setState(() {
                              _showUsers = true;
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
                    SizedBox(
                      width: rightWidth - 80,
                      child: Column(
                        children: [
                          gapH16,
                          user == null
                              ? const Text('....')
                              : Text(
                                  user!.associationName!,
                                  style: myTextStyleMediumLargeWithColor(
                                      context,
                                      Theme.of(context).primaryColor,
                                      28),
                                ),
                          gapH16,
                          gapH32,
                          arrivalsText == null
                              ? gapW16
                              : Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: CountsGridWidget(
                                      passengerCounts: totalPassengers,
                                      arrivalsText: arrivalsText!,
                                      departuresText: departuresText!,
                                      dispatchesText: dispatchesText!,
                                      heartbeatText: heartbeatText!,
                                      arrivals: bigBag == null
                                          ? 0
                                          : bigBag!.arrivals.length,
                                      departures: bigBag == null
                                          ? 0
                                          : bigBag!.departures.length,
                                      heartbeats: bigBag == null
                                          ? 0
                                          : bigBag!.heartbeats.length,
                                      dispatches: bigBag == null
                                          ? 0
                                          : bigBag!.dispatchRecords.length,
                                      passengerCountsText: passengerCounts!,
                                    ),
                                  ),
                                )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          busy
              ? Positioned(
                  left: 300,
                  right: 300,
                  bottom: 200,
                  top: 200,
                  child: TimerWidget(
                    title: 'Loading Association data ...',
                    subTitle: thisMayTakeMinutes == null
                        ? 'This may take a few minutes, please wait!'
                        : thisMayTakeMinutes!,
                  ))
              : const SizedBox(),
        ],
      ),
    ));
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
