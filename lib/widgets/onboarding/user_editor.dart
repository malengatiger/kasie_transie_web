import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/utils/constants.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import '../../utils/emojis.dart';

class UserEditor extends StatefulWidget {
  const UserEditor({Key? key, this.user}) : super(key: key);

  final User? user;

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

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    pp('$mm ... initState ... ${widget.user}');
    _buildExisting();
  }

  void _buildExisting() {
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

      }
    }
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
              padding: const EdgeInsets.all(24.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  shape: getDefaultRoundedBorder(),
                  elevation: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Form(
                        key: formKey,
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
                                    'User Editor',
                                    style: myTextStyleLarge(context),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _clearForm();
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 28,
                                      ))
                                ],
                              ),
                              gapH32,
                              MyFormField(
                                  controller: firstNameController,
                                  label: 'First Name',
                                  hint: 'Enter Name',
                                  icon: Icon(Icons.person)),
                              gapH32,
                              MyFormField(
                                  controller: lastNameController,
                                  label: 'Surname',
                                  hint: 'Enter Surname',
                                  icon: Icon(Icons.person)),
                              gapH32,
                              MyFormField(
                                  controller: emailController,
                                  label: 'Email',
                                  hint: 'Enter Email',
                                  icon: Icon(Icons.email)),
                              gapH32,
                              MyFormField(
                                  controller: cellphoneController,
                                  textStyle: myTextStyleMediumLargeWithColor(
                                      context,
                                      getPrimaryColorLight(context),
                                      24),
                                  label: 'Cellphone Number',
                                  hint: 'Enter Cellphone Number',
                                  icon: Icon(Icons.phone)),
                              gapH32,
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(Icons.handyman),
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
                              gapH32,
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
                        )),
                  ),
                ),
              ),
            ),
          ),
        ),
        busy? Positioned(child: Center(child: TimerWidget(title: 'Creating or updating user ...',))): gapH16,
      ],
    );
  }
}

class MyFormField extends StatelessWidget {
  const MyFormField(
      {super.key,
      required this.controller,
      required this.label,
      required this.hint,
      required this.icon,
      this.textStyle});

  final TextEditingController controller;
  final String label, hint;
  final Icon icon;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: textStyle == null
          ? myTextStyleMediumLargeWithColor(context, Colors.white, 18)
          : textStyle!,
      decoration: InputDecoration(
        label: Text(label),
        hintText: hint,
        icon: icon,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return hint;
        }
        return null;
      },
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
