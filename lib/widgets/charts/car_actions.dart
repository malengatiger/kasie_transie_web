import 'package:flutter/material.dart';
import 'package:kasie_transie_web/utils/functions.dart';

class CarActions extends StatelessWidget {
  const CarActions(
      {Key? key,
      required this.onEdit,
      required this.onRequestLocation,
      required this.onStartMonitor,
      required this.onSendMessage,  required this.colors, required this.onFindOwner, required this.onPickPhotos})
      : super(key: key);

  final Function onEdit;
  final Function onRequestLocation;
  final Function onStartMonitor;
  final Function onSendMessage;
  final Function onFindOwner;
  final Function onPickPhotos;



  final List<Color> colors;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: getDefaultRoundedBorder(),
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(onPressed: () {
              onEdit();
            }, icon: colors.isEmpty? Icon(Icons.remove_circle): Icon(Icons.remove_circle, color: colors[0],) ),
            gapW16,
            IconButton(onPressed: () {
              onRequestLocation();
            }, icon: colors.isEmpty? Icon(Icons.location_on): Icon(Icons.location_on, color: colors[1],)),
            gapW16,
            IconButton(onPressed: () {
              onStartMonitor();
            }, icon: colors.isEmpty? Icon(Icons.monitor_heart_sharp): Icon(Icons.monitor_heart_sharp, color: colors[2],)),
            gapW16,
            IconButton(onPressed: () {
              onSendMessage();
            }, icon: colors.isEmpty? Icon(Icons.send): Icon(Icons.send, color: colors[3],)),
            gapW16,
            IconButton(onPressed: () {
              onFindOwner();
            }, icon: colors.isEmpty? Icon(Icons.person): Icon(Icons.person, color: colors[4],)),
            gapW16,
            // IconButton(onPressed: () {
            //   onPickPhotos();
            // }, icon: colors.isEmpty? Icon(Icons.camera_alt_sharp):
            // Icon(Icons.camera_alt_sharp, color: colors[5],)),

          ],
        ),
      ),
    );
  }
}
