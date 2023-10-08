import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/local_storage/storage_manager.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/charts/car_actions.dart';
import 'package:kasie_transie_web/widgets/my_form_field.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_search.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:uuid/uuid.dart';

import '../../utils/emojis.dart';

class CarEditor extends StatefulWidget {
  const CarEditor(
      {Key? key, this.car, required this.onOwnerRequired, this.user})
      : super(key: key);

  final Vehicle? car;
  final User? user;
  final Function onOwnerRequired;

  @override
  _CarEditorState createState() => _CarEditorState();
}

class _CarEditorState extends State<CarEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🔆🔆🔆🔆🔆🔆 CarEditor 🔵🔵';
  bool busy = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController vehicleRegController = TextEditingController();
  TextEditingController makeController = TextEditingController();
  TextEditingController modelController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController yearController = TextEditingController();

  User? owner;
  User? user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm ... initState ... ${widget.car}');
    _checkOwner();
  }

  void _checkOwner() async {
    if (widget.car != null) {
      setState(() {
        busy = true;
      });
      owner = await storageManager.getUserById(widget.car!.ownerId!);
      setState(() {
        busy = false;
      });
    }
    _buildExisting();
    setState(() {

    });
  }
  void _buildExisting() async {
    user = await prefs.getUser();
    if (ignoreWidgetUser) {
      ignoreWidgetUser = false;
    } else {
      if (widget.car != null) {
        pp('$mm ... _buildExisting ... car not null');
        vehicleRegController.text = widget.car!.vehicleReg!;
        makeController.text = widget.car!.make!;
        capacityController.text = '${widget.car!.passengerCapacity!}';
        modelController.text = widget.car!.model!;
        yearController.text = widget.car!.year!;

        return;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    pp('\n\n$mm ... _submit car ..... ');
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        pp('$mm ... _submit : validation is cool! ${E.peach}..... ');
      } else {
        return;
      }
    } else {
      return;
    }
    setState(() {
      busy = true;
    });
    final m = int.parse(capacityController.value.text);
    final year = DateTime.now().year;
    if (m > year || m < (year - 20)) {
      showSnackBar(
          message: 'Model Year is invalid',
          context: context,
          backgroundColor: Colors.red);
      return;
    }
    try {
      int pCount = int.parse(capacityController.value.text);
      if (pCount == 0) {
        _showCountError();
        return;
      }
      if (pCount > 50) {
        _showCountError();
        return;
      }
      if (owner == null) {
        showSnackBar(
            message: 'Please select owner',
            context: context,
            backgroundColor: Colors.red);
        return;
      }
      if (widget.car != null) {
        widget.car!.vehicleReg = vehicleRegController.value.text;
        widget.car!.make = makeController.value.text;
        widget.car!.model = modelController.value.text;
        widget.car!.passengerCapacity = pCount;
        widget.car!.ownerId = owner!.userId!;
        widget.car!.ownerName = owner!.name;
        //
        final v = await networkHandler.updateVehicle(widget.car!);
        pp('$mm ... car updated: ');
        if (v != null) {
          myPrettyJsonPrint(v.toJson());
        }
        if (mounted) {
          showToast(
              message: 'Vehicle added to database',
              context: context,
              padding: 28);
        }
      } else {
        final veh = Vehicle(
            vehicleId: Uuid().v4().toString(),
            countryId: null,
            ownerName: owner!.name,
            ownerId: owner!.userId,
            created: DateTime.now().toUtc().toIso8601String(),
            dateInstalled: null,
            vehicleReg: vehicleRegController.value.text,
            make: makeController.value.text,
            model: modelController.value.text,
            year: yearController.value.text,
            qrCodeUrl: null,
            passengerCapacity: int.parse(capacityController.value.text),
            associationId: user!.associationId!,
            associationName: user!.associationName);

        final v = await networkHandler.addVehicle(veh);
        pp('$mm ... car added: ');
        if (v != null) {
          myPrettyJsonPrint(v.toJson());
        }
        if (mounted) {
          showToast(
              message: 'Vehicle added to database',
              context: context,
              padding: 28);
        }
      }
    } catch (e) {
      pp(e);
      if (mounted) {
        showSnackBar(
            message: 'Error: $e',
            context: context,
            padding: 20,
            backgroundColor: Colors.red);
      }
    }
    setState(() {
      busy = false;
    });
  }

  bool ignoreWidgetUser = false;
  bool _showOwners = false;

  void _showCountError() {
    showSnackBar(
        message: 'capacity of the car seems wrong, please check',
        context: context,
        backgroundColor: Colors.red);
  }

  void _clearForm() {
    vehicleRegController = TextEditingController();
    makeController = TextEditingController();
    modelController = TextEditingController();
    capacityController = TextEditingController();
    yearController = TextEditingController();
    setState(() {
      ignoreWidgetUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Center(
          child: Card(
            shape: getDefaultRoundedBorder(),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100.0, vertical: 24),
                child: SizedBox(
                  height: 660,
                  child: Card(
                    shape: getDefaultRoundedBorder(),
                    elevation: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  gapH16,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Car Manager',
                                        style: myTextStyleMediumLargeWithColor(
                                            context,
                                            getPrimaryColor(context),
                                            24),
                                      ),
                                      CarActions(
                                        onEdit: () {
                                          _clearForm();
                                        },
                                        onRequestLocation: () {},
                                        onStartMonitor: () {},
                                        onSendMessage: () {},
                                        colors: [
                                          Colors.blue,
                                          Colors.red,
                                          Colors.amber,
                                          Colors.teal,
                                          Colors.purple
                                        ],
                                        onFindOwner: () {
                                          pp('$mm ... onFindOwner ....');
                                          setState(() {
                                            _showOwners = true;
                                          });
                                        }, onPickPhotos: (){},
                                      )
                                    ],
                                  ),
                                  owner == null ? gapH4 : gapH32,
                                  owner == null
                                      ? gapH32
                                      : Row(
                                          children: [
                                            Text(
                                              'Owner: ',
                                              style: myTextStyleSmall(context),
                                            ),
                                            gapW16,
                                            Text(
                                              '${owner!.name}',
                                              style:
                                                  myTextStyleMediumLargeWithColor(
                                                      context,
                                                      getPrimaryColor(context),
                                                      24),
                                            )
                                          ],
                                        ),
                                  gapH32,
                                  MyFormField(
                                      controller: vehicleRegController,
                                      label: 'Registration',
                                      hint: 'Enter Registration',
                                      icon: Icon(Icons.person, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: makeController,
                                      label: 'Make',
                                      hint: 'Enter Make',
                                      icon: Icon(Icons.person, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: modelController,
                                      label: 'Model',
                                      hint: 'Enter Model',
                                      icon: Icon(Icons.email, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: capacityController,
                                      label: 'Capacity',
                                      hint: 'Enter Capacity',
                                      icon: Icon(Icons.people, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: yearController,
                                      label: 'Model Year',
                                      hint: 'Enter Model Year',
                                      icon: Icon(Icons.calendar_month, color: getPrimaryColor(context),)),
                                  gapH16,
                                  gapH32,
                                  SizedBox(
                                    width: 300,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _submit();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text('Submit'),
                                        )),
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        _showOwners
            ? Positioned(
                child: Center(
                child: Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 16,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: UserSearch(onUserPicked: (u) {
                      pp('$mm onUserPicked: ${E.redDot}  ${u.name}');
                      owner = u;
                      setState(() {
                        _showOwners = false;
                      });
                    }),
                  ),
                ),
              ))
            : gapW16,
        busy
            ? Positioned(
                child: Center(
                    child: TimerWidget(
                title: 'Creating or updating car ...',
              )))
            : gapH16,
      ],
    );
  }
}
