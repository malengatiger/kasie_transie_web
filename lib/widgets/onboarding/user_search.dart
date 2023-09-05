import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/data/vehicle.dart';
import 'package:kasie_transie_web/network.dart';
import 'package:kasie_transie_web/utils/functions.dart';
import 'package:kasie_transie_web/utils/prefs.dart';
import 'package:kasie_transie_web/widgets/timer_widget.dart';
import 'package:badges/badges.dart' as bd;
import '../../utils/emojis.dart';

class UserSearch extends StatefulWidget {
  const UserSearch({super.key, required this.onUserPicked});

  final Function(User) onUserPicked;

  @override
  State<UserSearch> createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  static const mm = '🍎🍎🍎🍎🍎 UserSearch';
  final TextEditingController _textEditingController = TextEditingController();
  String search = 'Search';
  String searchVehicles = 'Search Users';
  Vehicle? carPicked;
  bool busy = false;
  List<User> users = [];
  User? user;

  @override
  void initState() {
    super.initState();
    _getUsers(false);
  }

  void _getUsers(bool refresh) async {
    pp('$mm ... getUsers ...');
    setState(() {
      busy = true;
    });
    try {
      user = await prefs.getUser();
      users = await networkHandler.getAssociationUsers(
          associationId: user!.associationId!, refresh: refresh);
      pp('$mm ... users found: ${users.length}');
      _setUserNames();
    } catch (e) {
      print(e);
    }
    setState(() {
      busy = false;
    });
  }

  final _userNames = <String>[];
  var _usersToDisplay = <User>[];

  void _setUserNames() {
    _userNames.clear();
    for (var element in users) {
      _userNames.add(element.name!);
      _usersToDisplay.add(element);
    }

    pp('$mm ..... users to process: ${_usersToDisplay.length}');
  }

  User? _findUser(String name) {
    for (var u in users) {
      if (u.name.toLowerCase() == name.toLowerCase()) {
        return u;
      }
    }
    pp('$mm ..................................${E.redDot} ${E.redDot} DID NOT FIND $name');

    return null;
  }

  void _runFilter(String text) {
    pp('$mm .... _runFilter: text: $text ......');
    if (text.isEmpty) {
      pp('$mm .... text is empty ......');
      _usersToDisplay.clear();
      for (var u in users) {
        _usersToDisplay.add(u);
      }
      setState(() {});
      return;
    }
    _usersToDisplay.clear();

    pp('$mm ...  filtering users that contain: $text from ${_userNames.length} car plates');
    for (var u in _userNames) {
      if (u.toLowerCase().contains(text.toLowerCase())) {
        var user = _findUser(u);
        if (user != null) {
          _usersToDisplay.add(user);
        }
      }
    }
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Users',
                  style: myTextStyleMediumLargeWithColor(
                      context, getPrimaryColor(context), 24),
                ),
                gapH32,
                Row(
                  children: [
                    SizedBox(
                      width: 300,
                      child: TextField(
                        controller: _textEditingController,
                        onChanged: (text) {
                          pp('........... text to use for list filter: $text');
                          _runFilter(text);
                        },
                        decoration: InputDecoration(
                            label: Text(
                              search,
                              style: myTextStyleSmall(
                                context,
                              ),
                            ),
                            icon: Icon(
                              Icons.search,
                              color: Theme.of(context).primaryColor,
                            ),
                            border: const OutlineInputBorder(gapPadding: 2.0),
                            hintText: 'Search Users',
                            hintStyle: myTextStyleSmallWithColor(
                                context, Theme.of(context).primaryColor)),
                      ),
                    ),
                  ],
                ),
                gapH32,
                Expanded(
                    child: bd.Badge(
                      badgeContent: Text('${_usersToDisplay.length}', style: myTextStyleSmall(context),),
                      badgeStyle: bd.BadgeStyle(
                        elevation: 16,
                        badgeColor: Colors.purple,
                        padding: EdgeInsets.all(12),
                      ),
                      child: ListView.builder(
                          itemCount: _usersToDisplay.length,
                          itemBuilder: (_, index) {
                            final u = _usersToDisplay.elementAt(index);
                            return GestureDetector(
                              onTap: () {
                                widget.onUserPicked(u);
                              },
                              child: Card(
                                shape: getDefaultRoundedBorder(),
                                elevation: 16,
                                child: ListTile(
                                  leading: Icon(Icons.person, color: getPrimaryColor(context),),
                                  title: Text(
                                    '${u.name}',
                                    style: myTextStyleMediumLargeWithColor(
                                        context, Colors.white, 16),
                                  ),
                                ),
                              ),
                            );
                          }),
                    )),
              ],
            ),
          ),
          busy
              ? Positioned(
                  child: Center(child: TimerWidget(title: 'Loading users')))
              : gapW32,
        ],
      ),
    );
  }
}
