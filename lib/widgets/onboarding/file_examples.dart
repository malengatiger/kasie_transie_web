import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import '../../utils/functions.dart';
import 'dart:html' as html;

class FileExamples extends StatefulWidget {
  const FileExamples({Key? key}) : super(key: key);

  @override
  _FileExamplesState createState() => _FileExamplesState();
}

class _FileExamplesState extends State<FileExamples>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool busy = false;
  bool _showUsers = true;
  bool _showCars = false;
  static const mm = '🔵🔵🔵🔵🔵 FileExamples 🔵🔵';

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getFiles();
  }

  String? csvStringCars, jsonStringCars;
  String? csvStringUsers, jsonStringUsers;

  User? user;
  Future _getFiles() async {
    setState(() {
      busy = true;
    });
    try {
      user = await prefs.getUser();
      csvStringUsers = await rootBundle.loadString('assets/files/users.csv');
      csvStringCars = await rootBundle.loadString('assets/files/vehicles.csv');

      jsonStringUsers = await rootBundle.loadString('assets/files/users.json');
      jsonStringCars =
          await rootBundle.loadString('assets/files/vehicles.json');
      //
      pp('$mm ... csvStringUsers length: ${csvStringUsers?.length}');
      pp('$mm ... csvStringCars length: ${csvStringCars?.length}');

      pp('$mm ... jsonStringUsers length: ${jsonStringUsers?.length}');
      pp('$mm ... jsonStringCars length: ${jsonStringCars?.length}');
    } catch (e) {
      pp(e);
    }

    setState(() {
      busy = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _downloadExamples(String fileName) async {
    final anchor = html.AnchorElement(href: 'assets/files/$fileName')
      ..target = 'a_target_name'
      ..download = fileName
      ..click();

    pp('should be downloading $fileName .... anchor origin: ${anchor.origin}');
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user == null
                ? gapW32
                : Text(
                    '${user!.associationName}',
                    style: myTextStyleMediumLargeWithColor(
                        context, getPrimaryColor(context), 18),
                  ),
            gapW32,
            gapW32,
            gapW32,
            Text(
              'File Examples for Uploads',
              style: myTextStyleMediumLargeWithColor(
                  context, getPrimaryColorLight(context), 24),
            ),
          ],
        ),
        bottom: PreferredSize(preferredSize: Size.fromHeight(20), child: Column(
          children: [
            Text('You can use either one of the 2 types to upload your users and your vehicle',
            style: myTextStyleSmall(context),)
          ],
        )),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 28.0),
        child: Row(
          children: [
            SizedBox(
              width: (width / 2) - 64,
              child: Card(
                shape: getDefaultRoundedBorder(),
                elevation: 12,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      gapH32,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User File Examples: .csv type',
                            style: myTextStyleMediumLargeWithColor(
                                context, getPrimaryColor(context), 20),
                          ),
                          IconButton(
                              tooltip: 'Download users.csv',
                              onPressed: () {
                                _downloadExamples('users.csv');
                              },
                              icon: Icon(
                                Icons.download,
                                size: 24, color: Colors.blue,
                              ))
                        ],
                      ),
                      gapH32,
                      csvStringUsers == null
                          ? gapW32
                          : ExampleFile(text: csvStringUsers!),
                      gapH32,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vehicle File Example : .csv type',
                            style: myTextStyleMediumLargeWithColor(
                                context, getPrimaryColor(context), 20),
                          ),
                          IconButton(
                              tooltip: 'Download vehicles.csv',
                              onPressed: () {
                                _downloadExamples('vehicles.csv');
                              },
                              icon: Icon(
                                Icons.download,
                                size: 24, color: Colors.blue,
                              ))
                        ],
                      ),
                      gapH32,
                      csvStringCars == null
                          ? gapW32
                          : ExampleFile(text: csvStringCars!),
                      gapH32,
                    ],
                  ),
                ),
              ),
            ),
            gapW32,
            SizedBox(
              width: (width / 2) - 128,
              child: Card(
                shape: getDefaultRoundedBorder(),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      gapH32,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'User File Example: .json type',
                            style: myTextStyleMediumLargeWithColor(
                                context, getPrimaryColor(context), 20),
                          ),
                          IconButton(
                              tooltip: 'Download users.json',
                              onPressed: () {
                                _downloadExamples('users.json');
                              },
                              icon: Icon(
                                Icons.download,
                                size: 24, color: Colors.blue,
                              ))
                        ],
                      ),
                      gapH32,
                      jsonStringUsers == null
                          ? gapW32
                          : ExampleFile(text: jsonStringUsers!),
                      gapH32,
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vehicle File Example : .json type',
                            style: myTextStyleMediumLargeWithColor(
                                context, getPrimaryColor(context), 20),
                          ),
                          IconButton(tooltip: 'Download vehicles.json',
                              onPressed: () {
                                _downloadExamples('vehicles.json');
                              },
                              icon: Icon(
                                Icons.download,
                                size: 24, color: Colors.blue
                              ))
                        ],
                      ),
                      jsonStringCars == null
                          ? gapW32
                          : ExampleFile(text: jsonStringCars!),
                      gapH32,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class ExampleFile extends StatelessWidget {
  const ExampleFile({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: getDefaultRoundedBorder(),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                text,
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                speed: const Duration(milliseconds: 5),
              ),
            ],

            // totalRepeatCount: 0,
            isRepeatingAnimation: false,
            pause: const Duration(milliseconds: 1),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
        ));
  }
}
