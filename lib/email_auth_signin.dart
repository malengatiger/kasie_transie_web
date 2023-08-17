import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/l10n/strings_helper.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/signin_strings.dart';

import '../data/user.dart' as lib;
import '../utils/emojis.dart';
import '../utils/prefs.dart';
import 'l10n/translation_handler.dart';

class EmailAuthSignin extends StatefulWidget {
  const EmailAuthSignin(
      {Key? key, required this.onGoodSignIn, required this.onSignInError, required this.refresh})
      : super(key: key);

  final Function(lib.User) onGoodSignIn;
  final Function onSignInError;
  final bool refresh;

  @override
  EmailAuthSigninState createState() => EmailAuthSigninState();
}

class EmailAuthSigninState extends State<EmailAuthSignin>
    with SingleTickerProviderStateMixin {
  final mm = '💦💦💦💦💦💦 EmailAuthSignin 🔷🔷';
  late AnimationController _controller;
  TextEditingController emailController =
      TextEditingController(text: "robertg@gmail.com");
  TextEditingController pswdController = TextEditingController(text: "pass123");

  late StreamSubscription<bool> subscription;
  var formKey = GlobalKey<FormState>();
  bool busy = false;
  bool initializing = false;
  lib.User? user;
  SignInStrings? signInStrings;

  StringsHelper? stringsHelper;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
    _setTexts();
  }

  void _listen() {
    subscription = translator.translationStream.listen((event) {
      pp('$mm ... translationStream ');
      if (mounted) {
        setState(() {

        });();
      }
    });
  }
  Future _setTexts() async {
    stringsHelper = await StringsHelper.getTranslatedTexts();
    setState(() {

    });
  }
  @override
  void dispose() {
    _controller.dispose();
    subscription.cancel();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      busy = true;
    });
    try {
      fb.UserCredential userCred = await fb.FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.value.text,
              password: pswdController.value.text);

      pp('\n\n$mm ... Firebase user creds after signin: ${userCred.user} - ${E.leaf}');

      if (userCred.user != null) {
        user = await networkHandler.getUserById(userCred.user!.uid);
        if (user != null) {
          pp('$mm KasieTransie user found on database:  🍎 ${user!.toJson()} 🍎');

          user!.password = pswdController.value.text;
          user!.fcmToken = await userCred.user!.getIdToken();
          await prefs.saveUser(user!);
          pp('\n\n\n$mm ... about to pop! ..... ');

          if (mounted) {
            showSnackBar(
                duration: const Duration(seconds: 2),
                padding: 20,
                backgroundColor: Theme.of(context).primaryColor,
                textStyle: myTextStyleMedium(context),
                message: 'You have been signed in OK. Welcome!',
                context: context);
            widget.onGoodSignIn(user!);
          }
        }
      } else {
        widget.onSignInError();
      }
    } catch (e) {
      pp(e);
      widget.onSignInError();
    }
    setState(() {
      busy = false;
    });
  }

  Future<void> _doSettings() async {
    // try {
    // var settingsList =
    //     await listApiDog.getSettings(user!.associationId!, true);
    // if (settingsList.isNotEmpty) {
    //   settingsList.sort((a, b) => b.created!.compareTo(a.created!));
    //   await themeBloc.changeToTheme(settingsList.first.themeIndex!);
    //   pp('$mm KasieTransie theme has been set to:  🍎 ${settingsList.first.themeIndex!} 🍎');
    //   await themeBloc.changeToLocale(settingsList.first.locale!);
    //   await prefs.saveSettings(settingsList.first);
    //   pp('$mm ........ settings should be saved by now ...');
    // } else {
    //   final m = lib.SettingsModel(ObjectId(),
    //     associationId: user!.associationId,
    //     created: DateTime.now().toUtc().toIso8601String(),
    //     commuterGeofenceRadius: 200,
    //     commuterSearchMinutes: 30,
    //     commuterGeoQueryRadius: 50,
    //     distanceFilter: 10,
    //     geofenceRadius: 200,
    //     heartbeatIntervalSeconds: 300,
    //     locale: 'en',
    //     loiteringDelay: 30,
    //     themeIndex: 0,
    //     vehicleGeoQueryRadius: 200,
    //     vehicleSearchMinutes: 30,
    //     numberOfLandmarksToScan: 0,
    //     refreshRateInSeconds: 300,
    //   );
    //   //
    //   pp('$mm ........ adding default settings for association ...');
    //   final sett = await dataApiDog.addSettings(m);
    //   await prefs.saveSettings(sett);
    // }
    // } catch (e) {
    //   pp('$mm ... settings fucking up! ${E.redDot}');
    //   pp(e);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 480,
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                stringsHelper == null? gapW32 : Expanded(
                    child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        stringsHelper!.signInWithEmail,
                        style: myTextStyleMediumLargeWithColor(
                            context, Theme.of(context).primaryColor, 20),
                      ),
                      gapH32,
                      SizedBox(
                        width: 420,
                        child: TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            label:  Text(stringsHelper!.emailAddress),
                            hintText: stringsHelper!.enterEmail,
                            icon: const Icon(Icons.email),
                            iconColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      gapH32,
                      SizedBox(
                        width: 420,
                        child: TextFormField(
                          controller: pswdController,
                          obscureText: true,
                          decoration: InputDecoration(
                            label:  Text(stringsHelper!.password),
                            hintText: stringsHelper!.enterPassword,
                            icon: const Icon(Icons.lock),
                            iconColor: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      gapH32,
                      gapH16,
                      busy
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 12,
                                backgroundColor: Colors.amber,
                              ),
                            )
                          : ElevatedButton(
                              style: const ButtonStyle(
                                elevation:
                                    MaterialStatePropertyAll<double>(8.0),
                              ),
                              onPressed: () {
                                _signIn();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child:  Text(stringsHelper!.sendSignIn),
                              )),
                      gapH32,
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
