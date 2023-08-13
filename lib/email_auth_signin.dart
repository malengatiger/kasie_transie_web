import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/signin_strings.dart';

import '../data/user.dart' as lib;
import '../utils/emojis.dart';
import '../utils/prefs.dart';

class EmailAuthSignin extends StatefulWidget {
  const EmailAuthSignin(
      {Key? key, required this.onGoodSignIn, required this.onSignInError})
      : super(key: key);

  final Function(lib.User) onGoodSignIn;
  final Function onSignInError;

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

  var formKey = GlobalKey<FormState>();
  bool busy = false;
  bool initializing = false;
  lib.User? user;
  SignInStrings? signInStrings;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
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
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Email Sign In',
              style: myTextStyleLarge(context),
            ),
          ),
        ),
        body: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 480,
                height: 640,
                child: Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 48,
                        ),
                        Text(
                          'Email Authentication',
                          style: myTextStyleMediumLarge(context, 24),
                        ),
                        const SizedBox(
                          height: 48,
                        ),
                        Expanded(
                            child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 48,
                              ),
                              SizedBox(
                                width: 420,
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    label: const Text('Email Address'),
                                    hintText: 'Enter your Email address',
                                    icon: const Icon(Icons.email),
                                    iconColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 36,
                              ),
                              SizedBox(
                                width: 420,
                                child: TextFormField(
                                  controller: pswdController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    label: const Text('Password'),
                                    hintText: 'Enter your password',
                                    icon: const Icon(Icons.lock),
                                    iconColor: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              busy
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 12,
                                        backgroundColor: Colors.amber,
                                      ),
                                    )
                                  : SizedBox(
                                      width: 300,
                                      height: 60,
                                      child: ElevatedButton(
                                          style: const ButtonStyle(
                                            elevation: MaterialStatePropertyAll<
                                                double>(8.0),
                                          ),
                                          onPressed: () {
                                            _signIn();
                                          },
                                          child: const Text(
                                              'Send Sign In Credentials')),
                                    )
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
