import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/constants.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/my_form_field.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_actions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:uuid/uuid.dart';

import '../../utils/emojis.dart';

class UserEditor extends StatefulWidget {
  const UserEditor({Key? key, this.user, required this.onUserCreated, required this.onUserUpdated}) : super(key: key);
  final User? user;
  final Function(User) onUserCreated;
  final Function(User) onUserUpdated;
  @override
  _UserEditorState createState() => _UserEditorState();
}

class _UserEditorState extends State<UserEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = ' 🔆🔆🔆🔆🔆🔆 UserEditor 🔵🔵';
  bool busy = false;
  final formKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  String? userType;
  TextEditingController emailController = TextEditingController();
  TextEditingController cellphoneController = TextEditingController();
  User? user;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm ... initState ... ${widget.user}');
    _buildExisting();
  }

  void _buildExisting() async {
    user = await prefs.getUser();
    if (ignoreWidgetUser) {
      ignoreWidgetUser = false;
    } else {
      if (widget.user != null) {
        pp('$mm ... _buildExisting ... user not null');
        firstNameController.text = widget.user!.firstName!;
        lastNameController.text = widget.user!.lastName!;
        cellphoneController.text = widget.user!.cellphone!;
        emailController.text = widget.user!.email!;
        userType = widget.user!.userType;

        return;
      }
    }
    pp('$mm ... _buildExisting has no user ...');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() async {
    pp('$mm ... _submit ..... ');
    if (formKey.currentState != null) {
      if (formKey.currentState!.validate()) {
        pp('$mm ... _submit : validation is cool! ${E.peach}..... ');
      } else {
        return;
      }
    } else {
      return;
    }
    if (!isValidPhoneNumber(cellphoneController.value.text)) {
      showSnackBar(
          message:
              'The cellphone number is not valid, please check that you have the + prefix',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    if (!isValidEmail(emailController.value.text)) {
      showSnackBar(
          message: 'The email address is not valid, please check',
          backgroundColor: Colors.red,
          context: context);
      return;
    }
    if (userType == null) {
      showSnackBar(
          message: 'Please select user type',
          backgroundColor: Colors.red,
          context: context);
      return;
    }

    setState(() {
      busy = true;
    });
    try {
      if (widget.user != null) {
        widget.user!.firstName = firstNameController.value.text;
        widget.user!.lastName = lastNameController.value.text;
        widget.user!.email = emailController.value.text;
        widget.user!.cellphone = firstNameController.value.text;
        widget.user!.userType = userType;
        //
        final res = await networkHandler.updateUser(widget.user!);
        pp('$mm ... user updated ... ');
        if (res != null) {
          myPrettyJsonPrint(res.toJson());
        }
      } else {
        final m = User(
            userId: null,
            firstName: firstNameController.value.text,
            lastName: lastNameController.value.text,
            userType: userType,
            gender: null,
            countryId: null,
            associationId: user!.associationId!,
            associationName: user!.associationName!,
            fcmToken: null,
            password: Uuid().v4().toString(),
            email: emailController.value.text,
            cellphone: cellphoneController.value.text,
            thumbnailUrl: null,
            imageUrl: null);
        //
        final res = await networkHandler.createUser(m);
        pp('$mm ... user created ... ');
        if (res != null) {
          myPrettyJsonPrint(res.toJson());
          showToast(message: 'User created OK: ${m.name}',
              padding: 24,
              textStyle: myTextStyleMediumLargeWithColor(context, Colors.white, 18),
              context: context);
        }
      }
    } catch (e) {
      pp('$mm ... user NOT created; failed ${E.redDot}... ');
      pp(e);
      showSnackBar(message: '$e', context: context, backgroundColor: Colors.red);
    }
    setState(() {
      busy = false;
    });
  }

  bool isValidEmail(String email) {
    // Define a regex pattern for email validation
    final RegExp regExp = RegExp(
      r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$',
      caseSensitive: false,
      multiLine: false,
    );

    // Use the regex pattern to match the email address
    return regExp.hasMatch(email);
  }

  bool isValidPhoneNumber(String phoneNumber) {
    // Define a regex pattern for international phone numbers
    final RegExp regExp = RegExp(
      r'^\+(?:[0-9] ?){6,14}[0-9]$',
      caseSensitive: false,
      multiLine: false,
    );

    // Use the regex pattern to match the phone number
    return regExp.hasMatch(phoneNumber);
  }

  bool ignoreWidgetUser = false;

  void _clearForm() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    cellphoneController = TextEditingController();
    userType = null;
    setState(() {
      ignoreWidgetUser = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    pp('$mm ... build method : ...... ');
    _buildExisting();
    return Stack(
      children: [
        Center(
          child: Card(
            shape: getDefaultRoundedBorder(),
            elevation: 12,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 64.0, vertical: 24),
                child: SizedBox(
                  height: 660,
                  child: Card(
                    shape: getDefaultRoundedBorder(),
                    elevation: 16,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 64.0),
                      child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16.0),
                              child: Column(
                                children: [
                                  gapH16,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'User Editor',
                                        style: myTextStyleMediumLarge(context, 20),
                                      ),
                                      UserActions(onEdit: (){},
                                          onRequestLocation: (){},
                                          onStartMonitor: (){},
                                          onSendMessage: (){},
                                          colors: [
                                            Colors.red,
                                            Colors.blue,
                                            Colors.amber,
                                            Colors.teal,
                                            Colors.purple
                                          ],
                                          onFindOwner: (){})
                                    ],
                                  ),
                                  gapH64,
                                  MyFormField(
                                      controller: firstNameController,
                                      label: 'First Name',
                                      hint: 'Enter Name',
                                      icon: Icon(Icons.person, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: lastNameController,
                                      label: 'Surname',
                                      hint: 'Enter Surname',
                                      icon: Icon(Icons.person, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: emailController,
                                      label: 'Email',
                                      hint: 'Enter Email',
                                      icon: Icon(Icons.email, color: getPrimaryColor(context),)),
                                  gapH16,
                                  MyFormField(
                                      controller: cellphoneController,
                                      textStyle:
                                          myTextStyleMediumLargeWithColor(
                                              context,
                                              getPrimaryColorLight(context),
                                              24),
                                      label: 'Cellphone Number',
                                      hint: 'Enter Cellphone Number',
                                      icon: Icon(Icons.phone, color: getPrimaryColor(context),)),
                                  gapH16,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(Icons.handyman, color: getPrimaryColor(context),),
                                      gapW16,
                                      UserTypeDropDown(onUserType: (type) {
                                        pp('$mm ... type picked: $type');
                                        setState(() {
                                          this.userType = type;
                                        });
                                      }),
                                      gapW32,
                                      userType == null
                                          ? gapW32
                                          : Text(
                                              '$userType',
                                              style:
                                                  myTextStyleMediumLargeWithColor(
                                                      context,
                                                      Theme.of(context)
                                                          .primaryColor,
                                                      20),
                                            ),
                                    ],
                                  ),
                                  gapH64,
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
        busy
            ? Positioned(
                child: Center(
                    child: TimerWidget(
                title: 'Creating or updating user ...',
              )))
            : gapH16,
      ],
    );
  }
}

class UserTypeDropDown extends StatelessWidget {
  const UserTypeDropDown({super.key, required this.onUserType});

  final Function(String) onUserType;

  @override
  Widget build(BuildContext context) {
    final list = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
          value: Constants.AMBASSADOR, child: Text('${Constants.AMBASSADOR}')),
      DropdownMenuItem<String>(
          value: Constants.ASSOCIATION_OFFICIAL,
          child: Text('${Constants.ASSOCIATION_OFFICIAL}')),
      DropdownMenuItem<String>(
          value: Constants.OWNER, child: Text('${Constants.OWNER}')),
      DropdownMenuItem<String>(
          value: Constants.MARSHAL, child: Text('${Constants.MARSHAL}')),
      DropdownMenuItem<String>(
          value: Constants.DRIVER, child: Text('${Constants.DRIVER}')),
      DropdownMenuItem<String>(
          value: Constants.ROUTE_BUILDER,
          child: Text('${Constants.ROUTE_BUILDER}')),
    ];

    return DropdownButton<String>(
        hint: Text('Select User Type'), items: list, onChanged: onChanged);
  }

  void onChanged(String? value) {
    if (value != null) {
      onUserType(value);
    }
  }
}
