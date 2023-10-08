import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/navigator_utils.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_editor.dart';
import 'package:kasie_transie_web/widgets/onboarding/file_uploader_widget.dart';
import 'package:kasie_transie_web/widgets/onboarding/user_list.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';

import 'file_examples.dart';

class UserOnboarding extends StatefulWidget {
  const UserOnboarding({Key? key}) : super(key: key);

  @override
  _UserOnboardingState createState() => _UserOnboardingState();
}

class _UserOnboardingState extends State<UserOnboarding>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🔵🔵🔵🔵🔵 UserOnboarding 🔵🔵';

  var users = <User>[];
  bool busy = false;
  bool _showUpload = false;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _getUsers(false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  User? selectedUser;
  User? deviceUser;

  Future _getUsers(bool refresh) async {
    setState(() {
      busy = true;
    });
    try {
      deviceUser = await prefs.getUser();
      users = await networkHandler.getAssociationUsers(
          associationId: deviceUser!.associationId!, refresh: refresh);
      users.sort((a, b) => a.name.compareTo(b.name));
      pp('$mm ... association users : ${users.length}');
    } catch (e) {
      pp(e);
    }
    setState(() {
      busy = false;
    });
  }

  void _navigateToExamples() {
    navigateWithScale(FileExamples(), context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            deviceUser == null
                ? gapW32
                : Text(
                    '${deviceUser!.associationName}',
                    style: myTextStyleMediumLargeWithColor(
                        context, getPrimaryColor(context), 14),
                  ),
            gapW128,
            gapW32,
            Text(
              'User Management',
              style: myTextStyleMediumLargeWithColor(
                  context, getPrimaryColorLight(context), 24),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToExamples();
              },
              icon: Icon(Icons.file_copy_outlined)),
          IconButton(
              onPressed: () {
                _getUsers(true);
              },
              icon: Icon(Icons.refresh)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 48.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: (width / 3),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              gapH16,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                          child: Text('Upload User File'),
                                        )),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _getUsers(true);
                                      },
                                      icon: Icon(Icons.refresh)),
                                ],
                              ),
                              gapH4,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Uploaded user file may be in .csv or .json file type',
                                    style: myTextStyleSmall(context),
                                  ),
                                  IconButton(
                                      onPressed: () {
                                        _navigateToExamples();
                                      },
                                      icon: Icon(
                                        Icons.question_mark,
                                        size: 24,
                                      )),
                                ],
                              ),
                              gapH32,
                              Expanded(
                                child: UserList(
                                  users: users,
                                  onUserPicked: (u) {
                                    pp('$mm ... user picked: ${u.name} ... should set the fucking state!!');
                                    setState(() {
                                      selectedUser = u;
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
                          child: UserEditor(
                            // onFormCleared: () {
                            //   setState(() {
                            //     selectedUser = null;
                            //   });
                            // },
                            user: selectedUser,
                            onUserCreated: (m) {
                              pp('$mm ... user created: ${m.name} ');
                              _getUsers(false);
                            },
                            onUserUpdated: (m) {
                              pp('$mm ... user updated: ${m.name} ');
                              _getUsers(false);
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
                    _getUsers(true);
                    setState(() {
                      _showUpload = false;
                    });
                  },
                  onClose: () {
                    _getUsers(true);
                    setState(() {
                      _showUpload = false;
                    });
                  },
                )))
              : gapW16,
          busy
              ? Positioned(
                  child: Center(
                      child: TimerWidget(
                  title: 'Loading all users',
                )))
              : gapW32
        ],
      ),
    ));
  }
}
