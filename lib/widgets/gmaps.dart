import 'dart:async';
import 'dart:developer';
import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotinette_electrique_fablab/widgets/Infos_patinette.dart';
//import 'package:google_directions_api/google_directions_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vector_math/vector_math.dart' as vMath;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //region init vars
  final destinationAddressController = TextEditingController();
  String destinationAddress = "";
  LatLng? destinationPos;

  Position? _currentPosition;
  String _currentAddress = "";
  bool _mapDisabled = false;

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = []; // List of coordinates to join
  Map<PolylineId, Polyline> polylines = {
  }; // Map storing polylines created by connecting two points

  List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _camPos = const CameraPosition(
    target: LatLng(48.856614, 2.3522219),
    zoom: 14.4746,
  );

  //endregion
  Timer? timer;
  int currentPolyIndex = 0;
  LatLng? lastPos = null;
  bool isSimulation = true;
  bool shouldCamFollowRoad = true;
  int timerReqTime = 5; // in seconds
  double speed = 0.0;

  @override
  void initState() {
    super.initState();
    destinationAddressController.addListener(_updateDestination);
    _setUserCurrentPosition(addMarker: false);
    //timer = Timer.periodic(Duration(seconds: 5), (Timer timer) => _setUserCurrentPosition(addMarker: false));
    timer = Timer.periodic(Duration(seconds: timerReqTime), (Timer timer) => _handleUserPosChange());
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    timer?.cancel();
    super.dispose();
  }

  _calculVitesse(LatLng pos1, LatLng pos2){
   setState(() {
     speed = _calculateDistance(pos1, pos2) / timerReqTime * 3600;
   });
   log("######## VITESSE = " + speed.toString());
  }

  _handleUserPosChange() async {
    if(!isSimulation) {
      await _setUserCurrentPosition(addMarker: false);
    }

    if(polylineCoordinates.isNotEmpty) {
      final GoogleMapController controller = await _mapController.future;
      LatLng currPos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);

      if(shouldCamFollowRoad){
        double totalDistance = _calculateDistance(currPos, polylineCoordinates[_handleMinMax(currentPolyIndex, 0, polylineCoordinates.length-1)]);
        if ((isSimulation && totalDistance <=0.5) || totalDistance<=0.05) {
          currentPolyIndex ++;
        }
        LatLng pointPos = polylineCoordinates[_handleMinMax(currentPolyIndex, 0, polylineCoordinates.length-1)];

        if(lastPos == null) {
          setState(() {
            lastPos = currPos;
          });
        }

        controller.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: pointPos,
                    zoom: 20,
                    //bearing: _angleFromLatLng(currPos, pointPos)
                    bearing: _angleFromLatLng(lastPos!, pointPos)
                )
            )
        );
        _calculVitesse(currPos, lastPos!);

        setState(() {
          lastPos = (isSimulation ? pointPos : currPos);
        });

      }
      else{
        _centerRoad(currPos, destinationPos!);
        controller.animateCamera(
            CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: currPos,
                    zoom: 20,
                    bearing: _angleFromLatLng(currPos, destinationPos!)
                )
            )
        );
      }
    }
  }

  ///Get a distance between 2 points (in km)
  _calculateDistance(LatLng pos1, LatLng pos2){
    double p = 0.017453292529943295;
    double a = 0.5 - Math.cos((pos2.latitude - pos1.latitude) * p) / 2 + Math.cos(pos1.latitude * p) * Math.cos(pos2.latitude * p) * (1 - Math.cos((pos2.longitude - pos1.longitude) * p)) /2;
    return 12742 * Math.asin(Math.sqrt(a));
  }

  _handleMinMax(num value, num min, num max){
    return Math.max(Math.min(value, max), min);
  }

  /// Get user current position.
  /// When it's get, add a marker on map and center camera at user location.
  _setUserCurrentPosition({addMarker:false}) async {
    await getUserCurrentLocation();
    log("#####################" + _currentPosition.toString());
    if (_currentPosition != null) {
      LatLng currentLatLng = LatLng(
          _currentPosition!.latitude, _currentPosition!.longitude);
      Placemark? place = await _getAddressFromPos(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude));

      setState(() {
        _currentAddress = _formatAdressFromPlacemark(place!);
      });

      if(addMarker) {
        _addMarker(currentLatLng, _currentAddress);
      }
      _setCameraPos(currentLatLng);

      LatLng pos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(pos));
    }
  }

  /// Connect to google map to get a list of coordinates.
  /// This will be used to draw itinerary on GoogleMap
  _createPolylines(double startLatitude, double startLongitude,
      double destinationLatitude, double destinationLongitude) async {
    // Generating the list of coordinates to be used for drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAs16bHc0Z5qlDR0XLE_UqFDzjjNeRTQ2U", // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.transit,
    );

    log("####### result polyline: "  + result.errorMessage.toString() + result.points.toString() + ", for point " + startLatitude.toString() + "--" + startLongitude.toString() + "----------"  +destinationLatitude.toString() + "--" + destinationLongitude.toString());
    // Adding the coordinates to the list
    setState(() {
       while(polylineCoordinates.isNotEmpty){
        polylineCoordinates.removeLast();
      }
    });
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
    setState(() {
      _markers = [];
    });
    _markers.add(Marker(
        markerId: MarkerId(_markers.length.toString()),
        position: pos,
        infoWindow: InfoWindow(
          title: name,
        )
    ));
  }

  /// Get user current location
  Future<Position?> getUserCurrentLocation() async {
    await Geolocator.requestPermission().then((value){
    }).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
      log("ERROR"+error.toString());
    });
    _currentPosition = await Geolocator.getCurrentPosition();
    log("############ before return " + _currentPosition.toString());
    return _currentPosition;
  }

  //region destination
  void _updateDestination(){
    setState(() {
      destinationAddress = destinationAddressController.text;
    });
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

    final GoogleMapController controller = await _mapController.future;
    LatLng pos = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: pos,
          zoom: 20,
          bearing: _angleFromLatLng(pos, destinationPos!)
        )
      )
    );
  }

  /// get an angle betwween 2 points
  _angleFromLatLng(LatLng curPos, LatLng nextPos){
    double lon = (nextPos.longitude - curPos.longitude);

    double y = Math.sin(lon) * Math.cos(nextPos.longitude);
    double x = Math.cos(curPos.latitude) * Math.sin(nextPos.latitude) - Math.sin(curPos.latitude) * Math.cos(nextPos.latitude) * Math.cos(lon);

    double brng = Math.atan2(y, x);
    brng = vMath.degrees(brng);
    brng = (brng + 360) % 360;
    brng = 360 - brng;

    return brng;
  }
  //endregion

  //region helpers
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
  //endregion

  //region camera
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
        70.0,
      ),
    );
  }

  _setCameraPos(LatLng pos, {zoom:15.0}){
    setState(() {
      _camPos = CameraPosition(
        target: pos,
        zoom: zoom,
      );
    });
  }
  //endregion

  _toastDisable() {
    if (_mapDisabled) {
      Fluttertoast.showToast(
          msg: "Ecran désactivé lors du déplacement",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0
      );
    }
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
                        child: AbsorbPointer(
                          absorbing: _mapDisabled, //absorbing: true|false = disable|enable
                          child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            (_mapDisabled ? Colors.grey : Colors.black),
                            BlendMode.screen,
                          ),

                        child:Container(
                          height: height * .7,
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
                        )
                      )
                    ),
                  ),
                  InfoScreen(),
                ]
                ),
              ),
              Container(
                height: height * .06,
                width: width,
                child: Row(
                  children: [
                    Expanded(
                      child:TextField(
                        controller: destinationAddressController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Destination',
                        ),
                      ),
                    ),
                    Container(
                      width:60,
                      child:IconButton(
                        onPressed: _setDestination,
                        icon: Icon(Icons.golf_course)
                      )
                    )
                  ],
                ),
              ),
            ],
          )

        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _mapDisabled = !_mapDisabled;
            shouldCamFollowRoad = !shouldCamFollowRoad;
          });
          _toastDisable();
          currentPolyIndex ++;
        },
        backgroundColor: (shouldCamFollowRoad ? Colors.green : Colors.red),
      )
     
    );
  }
}
