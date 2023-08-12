import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:kasie_transie_web/environment.dart';
import 'package:kasie_transie_web/network.dart';
import 'firebase_options.dart';
import 'maps/association_route_maps.dart';

late fb.FirebaseApp firebaseApp;
fb.User? fbAuthedUser;
var themeIndex = 0;
// String? locale;
const mx = '🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 KasieTransie Web Admin : main 🔵🔵';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  firebaseApp = await fb.Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('\n\n$mx '
      ' Firebase App has been initialized: ${firebaseApp.name}, checking for authed current user\n');
  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AssociationRouteMaps(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 333;
  static const mm = '🍎🍎🍎🍎 KasieWeb: ';
  void _incrementCounter() async {

    _getData();
    setState(() {

      _counter++;
    });
  }

  @override
  void initState() {
    super.initState();
    _getData();
  }
  void _getData() async {
    debugPrint('$mm getting route data ..........');

    var token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) {
      debugPrint('$mm Token not found, will sign in!');
      final userCred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(email: 'admin@kasietransie.com',
          password: 'pass123_kasie');
      debugPrint('$mm Are we signed in? $userCred');
      if (userCred.user != null) {
        token = await fb.FirebaseAuth.instance.currentUser?.getIdToken();
      }

    }
    if (token == null) {
      throw Exception('Token not available. We are fucked!');
    }
    try {
      final bags = await network.getRouteBags(associationId: '2f3faebd-6159-4b03-9857-9dad6d9a82ac');
      debugPrint('$mm .... route bags: ${bags.length}, if > 0, we are in business!!');
      for (var value in bags) {
        debugPrint('$mm route: ${value.route!.name} 🔵🔵'
            '\n🔵 routeLandmarks: ${value.routeLandmarks.length}'
            '\n🔵 routePoints: ${value.routePoints.length}'
            '\n🔵 routeCities: ${value.routeCities.length}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 140, color: Colors.pink),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getData,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
