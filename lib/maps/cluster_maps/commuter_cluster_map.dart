import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:kasie_transie_web/l10n/strings_helper.dart';
import 'package:kasie_transie_web/maps/cluster_maps/toggle.dart';
import '../../utils/emojis.dart';
import '../../utils/functions.dart';
import 'cluster_covers.dart';
import 'package:kasie_transie_web/data/route.dart' as lib;

class CommuterClusterMap extends StatefulWidget {
  const CommuterClusterMap(
      {Key? key, required this.commuterRequestCovers, required this.date, required this.routes})
      : super(key: key);
  final String date;
  final List<CommuterRequestCover> commuterRequestCovers;
  final List<lib.Route> routes;
  @override
  CommuterClusterMapState createState() => CommuterClusterMapState();
}

class CommuterClusterMapState extends State<CommuterClusterMap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Completer<GoogleMapController> _googleMapController = Completer();
  final mm = '🍐🍐🍐🍐CommuterClusterMap 🍐🍐';

  var routes = <lib.Route>[];
  Set<Marker> markers = {};
  late ClusterManager clusterManager;
  final CameraPosition _parisCameraPosition =
      const CameraPosition(target: LatLng(-27.856613, 25.352222), zoom: 14.0);

  StringsHelper? stringsHelper;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    clusterManager = _initClusterManager();
    super.initState();
    _setTexts();
  }

  void _setTexts() async {
    stringsHelper = await StringsHelper.getTranslatedTexts();
    pp('$mm ... commuterRequestCovers: ${widget.commuterRequestCovers.length}');
  }


  ClusterManager<ClusterItem> _initClusterManager() {
    pp('$mm ......... _initClusterManager, ${E.appleRed} items: ${widget.commuterRequestCovers.length}');
    clusterManager = ClusterManager<CommuterRequestCover>(
        widget.commuterRequestCovers, _updateMarkers,
        markerBuilder: _markerBuilder);

    return clusterManager;
  }

  void _updateMarkers(Set<Marker> p1) {
    // pp('$mm ... updateMarkers ... ${p1.length} markers');
    setState(() {
      markers = p1;
    });
  }

  Future<Marker> Function(Cluster<CommuterRequestCover>) get _markerBuilder =>
      (cluster) async {
        var size = cluster.isMultiple ? 125.0 : 75.0;
        var text = cluster.isMultiple ? cluster.count.toString() : "1";
        final ic = await getMarkerBitmap(
          size.toInt(),
          text: text,
          color: 'pink',
          borderColor: Colors.white,
          fontWeight: FontWeight.normal,
          fontSize: 14,
        );
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            pp('$mm ---- cluster? ${E.redDot} $cluster');
            for (var p in cluster.items) {
              pp('$mm ... CommuterRequestCover - cluster item: ${E.appleRed} '
                  '${p.request.routeLandmarkName}'
                  '\n${E.leaf} route: ${p.request.routeName} ');
            }
          },
          icon: ic,
        );
      };

  bool hybrid = true;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoomToStart() async {
    pp('$mm ... zooming to first commuter request ...');
    final pc = widget.commuterRequestCovers.first;
    final latLng = pc.latLng;
    var cameraPos = CameraPosition(target: latLng, zoom: 14.0);
    final GoogleMapController controller = await _googleMapController.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPos));
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.people_rounded,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              stringsHelper == null?'Commuter Requests': stringsHelper!.commuterRequests,
              style: myTextStyleMediumLargeWithColor(
                  context, Theme.of(context).primaryColor, 20),
            ),
          ],
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      stringsHelper == null?'Start Time: ':stringsHelper!.timeLastUpdate,
                      style: myTextStyleTiny(context),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      widget.date,
                      style: myTextStyleSmall(context),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                )
              ],
            )),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _parisCameraPosition,
            buildingsEnabled: true,
            mapType: hybrid ? MapType.hybrid : MapType.normal,
            markers: markers,
            onCameraMove: clusterManager.onCameraMove,
            onCameraIdle: clusterManager.updateMap,
            onMapCreated: (GoogleMapController cont) {
              pp('$mm .......... onMapCreated ...........');
              _googleMapController.complete(cont);
              clusterManager.setMapId(cont.mapId);
              clusterManager.setItems(widget.commuterRequestCovers);
              _zoomToStart();
            },
          ),
          Positioned(
            right: 12,
            top: 0,
            child: SizedBox(
              width: 48,
              height: 48,
              child: HybridToggle(
                  onHybrid: () {
                    setState(() {
                      hybrid = true;
                    });
                  },
                  onNormal: () {
                    setState(() {
                      hybrid = false;
                    });
                  },
                  hybrid: hybrid),
            ),
          ),
        ],
      ),
    ));
  }
}
