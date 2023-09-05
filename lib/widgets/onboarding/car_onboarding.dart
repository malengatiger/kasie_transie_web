import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/navigator_utils.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/car_list.dart';
import 'package:kasie_transie_web/widgets/demo_driver.dart';
import 'package:kasie_transie_web/widgets/onboarding/car_editor.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_editor.dart';
import 'package:kasie_transie_web/widgets/onboarding/file_uploader_widget.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_list.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_search.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import 'file_examples.dart';

class CarOnboarding extends StatefulWidget {
  const CarOnboarding({Key? key}) : super(key: key);

  @override
  _CarOnboardingState createState() => _CarOnboardingState();
}

class _CarOnboardingState extends State<CarOnboarding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '💦💦💦💦 CarOnboarding 💦💦';

  var cars = <Vehicle>[];
  User? owner;
  bool busy = false;
  bool _showOwnerSearch = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUser();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Vehicle? selectedCar;
  User? deviceUser;
  void _getUser() async {
    deviceUser = await prefs.getUser();
    setState(() {

    });
  }

bool _showUpload = false;
  void _navigateToExamples() {
    navigateWithScale(FileExamples(), context);
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(mainAxisAlignment: MainAxisAlignment.start,
          children: [
            deviceUser == null? gapW32:Text('${deviceUser!.associationName}',
            style: myTextStyleMediumLargeWithColor(context, getPrimaryColor(context), 14),),
            gapW128, gapW32,
            Text('Vehicle Management',
              style: myTextStyleMediumLargeWithColor(context, getPrimaryColorLight(context), 24),),

          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToExamples();
              },
              icon: Icon(Icons.file_copy_outlined)),

        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: getDefaultRoundedBorder(),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: (width / 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              gapH16,
                              Row(mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 300,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            _showUpload = true;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text('Upload Vehicle File'),
                                        )),
                                  ),
                                ],
                              ),
                              gapH4,
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      'Uploaded vehicle file may be in .csv or .json file type',
                                    style: myTextStyleSmall(context),),

                                  IconButton(onPressed: (){
                                    _navigateToExamples();
                                  }, icon: Icon(Icons.question_mark, size: 24,), ),
                                ],
                              ),
                              gapH32,
                              Expanded(
                                child: CarList(
                                  onCarPicked: (u) {
                                    pp('$mm ... car picked: ${u.vehicleReg}');
                                    setState(() {
                                      selectedCar = u;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        gapW32,
                        SizedBox(
                          width: (width / 2),
                          child: CarEditor(
                            car: selectedCar,
                            user: owner,
                            onOwnerRequired: (){
                              _showOwnerSearch = true;
                              setState(() {

                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          _showUpload
              ? Positioned(
              child: Center(
                  child: FileUploaderWidget(
                    isVehicles: false,
                    isUsers: true,
                    onFileUploaded: () {
                      setState(() {
                        _showUpload = false;
                      });
                    },
                    onClose: () {
                      setState(() {
                        _showUpload = false;
                      });
                    },
                  )))
              : gapW16,
          _showOwnerSearch
              ? Positioned(
                  child: Center(
                      child: UserSearch(onUserPicked: (u){
                        pp('$mm ... user picked: ${u.name}');
                          setState(() {
                            owner = u;
                          });
                      },
                      ),
                  ),
          ): gapW16,

          busy? Positioned(child: Center(child: TimerWidget(title: 'Loading all users',))):gapW32
        ],
      ),
    ));

  }
}
