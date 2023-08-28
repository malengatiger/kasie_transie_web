import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/functions.dart';

class SideBoard extends StatelessWidget {
  const SideBoard(
      {super.key,
      required this.title,
      required this.onUsers,
      required this.onCars,
      required this.onLocateCar,
      required this.onSendMessage,
      required this.onDispatchReport,
      required this.onPassengerReport,
      required this.onSettings, this.width});

  final String title;
  final Function onUsers;
  final Function onCars;
  final Function onLocateCar;
  final Function onSendMessage;
  final Function onDispatchReport;
  final Function onPassengerReport;
  final Function onSettings;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width == null ? 300 : width!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Card(
          shape: getDefaultRoundedBorder(),
          elevation: 8,
          child: Column(
            children: [
              gapH16,
              Image.asset(
                'assets/ktlogo_red.png',
                width: 240,
                height: 80,
              ),
              gapH32,
              Text(
                title,
                style: myTextStyleLarge(context),
              ),
              Expanded(
                child: ListView(
                  children: [
                    gapH32,
                    MenuItem(
                        onTapped: () {
                          onUsers();
                        },
                        icon: Icon(Icons.people),
                        title: 'Users'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onCars();
                        },
                        icon: Icon(Icons.airport_shuttle),
                        title: 'Taxis'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onLocateCar();
                        },
                        icon: Icon(Icons.location_on),
                        title: 'Locate Taxi'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onSendMessage();
                        },
                        icon: Icon(Icons.send),
                        title: 'Send Message'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onDispatchReport();
                        },
                        icon: Icon(Icons.edit),
                        title: 'Dispatch Report'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onPassengerReport();
                        },
                        icon: Icon(Icons.list),
                        title: 'Passenger Report'),
                    gapH16,
                    MenuItem(
                        onTapped: () {
                          onSettings();
                        },
                        icon: Icon(Icons.settings),
                        title: 'Settings'),
                    gapH16,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem(
      {super.key,
      required this.onTapped,
      required this.icon,
      required this.title,
      this.subTitle});

  final Function onTapped;
  final Icon icon;
  final String title;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: ListTile(
        leading: icon,
        title: Text(
          title,
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 16),
        ),
        subtitle: subTitle == null ? gapH16 : Text(subTitle!),
      ),
    );
  }
}
