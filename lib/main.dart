import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:kasie_transie_web/utils/emojis.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/splash_page.dart';
import 'package:page_transition/page_transition.dart';
import 'blocs/theme_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dot;
import 'maps/association_route_maps.dart';

late fb.FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
var themeIndex = 0;
// String? locale;
final mx = '🔵🔵🔵🔵🔵 KasieTransie Web Admin ${E.redDot}';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await fb.Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('\n\n$mx '
      ' Firebase App has been initialized: ${firebaseApp.name}, checking for authed current user\n');
  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;

  dot.dotenv.load();
  runApp(const KasieWeb());
}

class KasieWeb extends StatelessWidget {
  const KasieWeb({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pp('$mx 🌀🌀🌀🌀 Tap detected; should dismiss keyboard ...');
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StreamBuilder(
          stream: themeBloc.localeAndThemeStream,
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              pp(' 🔵 🔵 🔵'
                  'build: theme index has changed to ${snapshot.data!.themeIndex}'
                  '  and locale is ${snapshot.data!.locale.toString()}');
              themeIndex = snapshot.data!.themeIndex;
            }

            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'KasieTransie',
                theme: themeBloc.getTheme(themeIndex).lightTheme,
                darkTheme: themeBloc.getTheme(themeIndex).darkTheme,
                themeMode: ThemeMode.system,
                home: AnimatedSplashScreen(
                  splash: const SplashWidget(),
                  animationDuration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInCirc,
                  splashIconSize: 160.0,
                  nextScreen: const AssociationRouteMaps(),
                  splashTransition: SplashTransition.fadeTransition,
                  pageTransitionType: PageTransitionType.leftToRight,
                  backgroundColor: Colors.blue.shade900,
                ));
          }),
    );
  }
}
