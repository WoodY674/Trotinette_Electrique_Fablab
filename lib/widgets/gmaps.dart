import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotinette_electrique_fablab/widgets/Infos_patinette.dart';
//import 'package:google_directions_api/google_directions_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /*final directionsService = DirectionsService();
  final request = DirectionsRequest(
    origin: 'Chicago, IL',
    destination: 'San Francisco, CA',
    travelMode: TravelMode.driving,
  );
*/
  final destinationAddressController = TextEditingController();
  String destinationAddress = "";
  LatLng? destinationPos;

  Position? _currentPosition;
  String _currentAddress = "";

  PolylinePoints polylinePoints = PolylinePoints();
  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];
  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  final List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _camPos = const CameraPosition(
    target: LatLng(48.856614, 2.3522219),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    destinationAddressController.addListener(_updateDestination);
    _initStartPos();
    /*directionsService.route(request,
            (DirectionsResult response, DirectionsStatus status) {
          if (status == DirectionsStatus.ok) {
            // do something with successful response
          } else {
            // do something with error response
          }
        });*/
  }

  _initStartPos() async {
    await getUserCurrentLocation();
    log("#####################" + _currentPosition.toString());
    if(_currentPosition != null) {
      LatLng currentLatLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      Placemark? place = await _getAddressFromPos(LatLng(_currentPosition!.latitude, _currentPosition!.longitude));

      setState(() {
        _currentAddress = _formatAdressFromPlacemark(place!);
      });

      _addMarker(currentLatLng, _currentAddress);
      _setCameraPos(currentLatLng);

      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(
        CameraUpdate.newLatLng(LatLng(_currentPosition!.latitude, _currentPosition!.longitude))
      );
    }
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    super.dispose();
  }

  _createPolylines(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAs16bHc0Z5qlDR0XLE_UqFDzjjNeRTQ2U", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    log("####### result polyline: "  + result.errorMessage.toString() + result.points.toString() + ", for point " + startLatitude.toString() + "--" + startLongitude.toString() + "----------"  +destinationLatitude.toString() + "--" + destinationLongitude.toString());
    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      setState(() {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      });
      log("not empty polyline");
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    setState(() {
      polylines[id] = polyline;
    });
  }

  _addMarker(LatLng pos, String name){
    _markers.add(Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: pos,
        infoWindow: InfoWindow(
          title: name,
        )
    ));
  }

  _setCameraPos(LatLng pos, {zoom:15.0}){
    setState(() {
      _camPos = CameraPosition(
        target: pos,
        zoom: zoom,
      );
    });
  }

  // created method for getting user current location
  Future<Position?> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
      log("####### geolocator.then " + value.toString());
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      log("ERROR"+error.toString());
    });
    _currentPosition = await Geolocator.getCurrentPosition();
    log("############ before return " + _currentPosition.toString());
    return _currentPosition;
  }

  void _updateDestination(){
    setState(() {
      destinationAddress = destinationAddressController.text;
    });
  }

  _formatAdressFromPlacemark(Placemark place){
    return "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
  }

  Future<Placemark?> _getAddressFromPos(LatLng pos) async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      // Taking the most probable result
      Placemark place = p[0];
      return place;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<LatLng> _getPosFromAddress(String address) async {
    List<Location> destinationPlacemark = await locationFromAddress(address);
    return LatLng(destinationPlacemark[0].latitude, destinationPlacemark[0].longitude);
  }

  _setDestination() async {
    LatLng destPos = await _getPosFromAddress(destinationAddress);
    setState(() {
      destinationPos = destPos;
    });
    _addMarker(destinationPos!, destinationAddress);
    _centerRoad(LatLng(_currentPosition!.latitude, _currentPosition!.longitude ),LatLng(destinationPos!.latitude, destinationPos!.longitude ) );
    _createPolylines(_currentPosition!.latitude, _currentPosition!.longitude,
      destinationPos!.latitude, destinationPos!.longitude);
  }

  _centerRoad(LatLng pos1, LatLng pos2) async {
    double miny = (pos1.latitude <= pos2.latitude) ? pos1.latitude : pos2.latitude;
    double minx = (pos1.longitude <= pos2.longitude) ? pos1.longitude : pos2.longitude;
    double maxy = (pos1.latitude <= pos2.latitude) ? pos2.latitude : pos1.latitude;
    double maxx = (pos1.longitude <= pos2.longitude) ? pos2.longitude : pos1.longitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    // Accommodate the two locations within the camera view of the map
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          northeast: LatLng(northEastLatitude, northEastLongitude),
          southwest: LatLng(southWestLatitude, southWestLongitude),
        ),
        100.0,
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(

      body: Container(
        child: SafeArea(
          // on below line creating google maps
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                      Container(
                          width: width,
                          child: GoogleMap(
                            initialCameraPosition: _camPos,
                            markers: Set<Marker>.of(_markers),
                            polylines: Set<Polyline>.of(polylines.values),

                            mapType: MapType.normal,
                            myLocationEnabled: true,
                            compassEnabled: true,
                            onMapCreated: (GoogleMapController controller){
                              _mapController.complete(controller);
                            },
                          )
                      ),
                    InfoScreen(),
                  ],
                ),
              ),

              Container(
                height: height * .06,
                width: width,
                child: TextField(
                  controller: destinationAddressController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Destination',
                  ),
                ),
              ),
              Container(
                height: height * .06,
                  width: width,
                  child: IconButton(
                    onPressed: _setDestination,
                    icon: Icon(Icons.golf_course)
                )
              ),

            ],
          )

        ),
      ),

      /*// on pressing floating action button the camera will take to user current location
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          getUserCurrentLocation().then((value) async {
            log(value.toString());
            _addMarker(LatLng(value.latitude, value.longitude), "Destination");

            // specified current users location
            CameraPosition cameraPosition = new CameraPosition(
              target: LatLng(value.latitude, value.longitude),
              zoom: 14,
            );

            final GoogleMapController controller = await _mapController.future;
            controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
            setState(() {
            });
          });
        },
        child: Icon(Icons.local_activity),
      ),*/
    );
  }
}
