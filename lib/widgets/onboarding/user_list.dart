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
            elevation: 12,
            padding: EdgeInsets.all(8.0),
          ),
          child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (c, index) {
                final user = users.elementAt(index);
                return GestureDetector(
                  onTap: () {
                    pp('$mm ... user: ${user.toJson()}');
                    onUserPicked(user);
                  },
                  child: Card(
                    shape: getDefaultRoundedBorder(),
                    elevation: 16,
                    child: ListTile(
                      leading: Icon(Icons.person, color: getPrimaryColorLight(context),),
                      title: Row(
                        children: [
                          SizedBox(
                            width: 48,
                            child: Text('${index + 1}'),
                          ),
                          Text('${user.name}', style: myTextStyleMediumLargeWithColor(context, getPrimaryColorLight(context),
                              18),),
                          gapW32,
                          Text('${user.cellphone}'),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(left: 48.0),
                        child: Text('${user.userType}', style: myTextStyleSmall(context),),
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
