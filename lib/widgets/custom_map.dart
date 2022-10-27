import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomMap extends StatefulWidget {
  const CustomMap({Key? key, required this.disabled, required this.cameraPosition,
    required this.markers, required this.polylines, required this.mapController}) : super(key: key);
  final bool disabled;
  final CameraPosition cameraPosition;
  final List<Marker> markers;
  final Map<PolylineId, Polyline> polylines;
  final Completer<GoogleMapController> mapController;

  @override
  _CustomMapState createState() => _CustomMapState();
}

class _CustomMapState extends State<CustomMap> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Container(
      width: width,
      child: AbsorbPointer(
          absorbing: widget.disabled, //absorbing: true|false = disable|enable
          child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                (widget.disabled ? Colors.grey.withOpacity(.3) : Colors.black.withOpacity(0)),
                BlendMode.screen,
              ),

              child:Container(
                  width: width,
                  child: GoogleMap(
                    initialCameraPosition: widget.cameraPosition,
                    markers: Set<Marker>.of(widget.markers),
                    polylines: Set<Polyline>.of(widget.polylines.values),

                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    onMapCreated: (GoogleMapController controller){
                      widget.mapController.complete(controller);
                    },
                  )
              )
          )
      ),
    );
  }

}
