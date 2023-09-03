import 'package:flutter/material.dart';

import '../utils/functions.dart';

class SplashWidget extends StatefulWidget {
  const SplashWidget({Key? key}) : super(key: key);

  @override
  State<SplashWidget> createState() => _SplashWidgetState();
}

class _SplashWidgetState extends State<SplashWidget> {
  static const mm = '💠💠💠💠💠💠💠💠 SplashWidget';

  @override
  void initState() {
    super.initState();
    _performSetup();
  }

  String? message;

  void _performSetup() async {

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: AnimatedContainer(
        width: 800, height: 600,
        curve: Curves.easeInOutCirc,
        duration: const Duration(milliseconds: 3000),
        child: Center(
          child: Image.asset(
            'assets/ktlogo_red.png',
            height: 400,
            width: 600,
          ),
        ),
      ),
    );
  }
}
