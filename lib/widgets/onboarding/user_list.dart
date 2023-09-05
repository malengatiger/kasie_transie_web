import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:kasie_transie_web/data/user.dart';
import 'package:kasie_transie_web/utils/functions.dart';

import '../../utils/emojis.dart';

class UserList extends StatelessWidget {
  const UserList({super.key, required this.users, required this.onUserPicked});

  final List<User> users;
  final Function(User) onUserPicked;
  static final mm = '${E.redDot}${E.redDot}${E.redDot} UserList: ';

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 12,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: bd.Badge(
          badgeContent: Text(
            '${users.length}',
            style: myTextStyleSmall(context),
          ),
          badgeStyle: bd.BadgeStyle(
            elevation: 20,
            padding: EdgeInsets.all(8.0),
          ),
          child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (c, index) {
                final user = users.elementAt(index);
                final initial1 = user.firstName!.substring(0, 0).toUpperCase();
                final initial2 = user.lastName!.substring(0, 0).toUpperCase();

                return GestureDetector(
                  onTap: () {
                    pp('$mm ... user: ${user.toJson()}');
                    onUserPicked(user);
                  },
                  child: Card(
                    shape: getDefaultRoundedBorder(),
                    elevation: 16,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage('assets/profile.png', ),
                        radius: 18.0,
                        // backgroundColor: Colors.black,
                        // child: Text(
                        //   '$initial1 $initial2',
                        //   style: myTextStyleMediumLargeWithColor(
                        //       context, Colors.black, 18),
                        // ),
                      ),
                      title: Row(mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('${index + 1}', style: myTextStyleTiny(context),),
                          ),
                          gapW8,
                          Text(
                            '${user.name}',
                            style: myTextStyleMediumLargeWithColor(
                                context, getPrimaryColorLight(context), 18),
                          ),

                        ],
                      ),
                    ),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
