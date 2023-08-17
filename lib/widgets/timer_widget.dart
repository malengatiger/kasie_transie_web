import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_analog_clock/flutter_analog_clock.dart';
import 'package:kasie_transie_web/l10n/strings_helper.dart';

import '../utils/functions.dart';

class TimerWidget extends StatefulWidget {
  const TimerWidget({Key? key, required this.title, this.subTitle})
      : super(key: key);

  final String title;
  final String? subTitle;

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵🔵🔵🔵️ TimerWidget: ❤️ ';

  late Timer timer;
  int elapsed = 0;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    startTimer();
  }


  void startTimer() {
    pp('$mm ... timer starting ....');
    timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      elapsed = timer.tick;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.now();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return SizedBox(
      width: width/3,
      height: height/2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 12,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                 gapH16,
                  Text(
                    widget.title,
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColorLight, 24),
                  ),
                 gapH8,
                  widget.subTitle == null
                      ? const SizedBox()
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: Text(widget.subTitle!),
                        ),
                  gapH32,gapH32,
                  SizedBox(width: 128, height: 128,
                    child: AnalogClock(
                      dateTime: date,
                      isKeepTime: true,
                      child: const Align(
                        alignment: FractionalOffset(0.5, 0.75),
                        child: Text('GMT+2'),
                      ),
                    ),
                  ),
                 gapH32,
                  Text(
                    getFormattedTime(timeInSeconds: elapsed),
                    style: myTextStyleMediumLargeWithColor(
                        context, Theme.of(context).primaryColor, 32),
                  ),
                  gapH16,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
