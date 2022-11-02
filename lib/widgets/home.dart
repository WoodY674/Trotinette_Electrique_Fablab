import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:trotinette_electrique_fablab/const.dart';
import 'package:trotinette_electrique_fablab/widgets/Infos_patinette.dart';
import 'package:trotinette_electrique_fablab/widgets/button_gps_mode.dart';
import 'package:trotinette_electrique_fablab/widgets/custom_map.dart';
import 'package:trotinette_electrique_fablab/widgets/destination_input.dart';
import 'package:trotinette_electrique_fablab/helpers/calcul.dart';
import 'package:trotinette_electrique_fablab/helpers/map.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //region init vars
  final destinationAddressController = TextEditingController();
  String destinationAddress = "";
  LatLng? destinationCoordinates;

  Position? _currentPosition;
  LatLng? _currentCoordinates;
  bool _mapDisabled = false;

  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = []; // List of coordinates to join
  Map<PolylineId, Polyline> polylines = {}; // Map storing polylines created by connecting two points

  List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _camPos = const CameraPosition(
    target: LatLng(48.856614, 2.3522219), //Paris
    zoom: 15,
  );


  Timer? timer;
  int timerTimeInterval = 5; // in seconds
  int currentPolylineIndex = 0;
  LatLng? lastCoordinate;
  bool shouldCamFollowRoad = true;
  double speed = 0.0;
  //endregion

  //region override function (init, dispose ...)
  @override
  void initState() {
    super.initState();
    destinationAddressController.addListener(_handleDestinationAddress);
    _handleUserPosition(addMarker: false);

    timer = Timer.periodic(Duration(seconds: timerTimeInterval), (Timer timer) => _handleUserPosChange());
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    timer?.cancel();
    super.dispose();
  }
  //endregion

  //region functions
  _setSpeed(LatLng pos1, LatLng pos2){
   setState(() {
     speed = calculateDistance(pos1, pos2) / timerTimeInterval * 3600;
   });
  }

  /// Handle user position change on map.
  /// if there is an itinerary :
  ///   - camera could follow the user and rotate cam to heading the road
  ///   - camera could show the entire itinary with large zoom-out
  _handleUserPosChange() async {
    if(!GlobalsConst.isSimulation) {
      await _handleUserPosition(addMarker: false);
    }

    if(polylineCoordinates.isNotEmpty) {
      LatLng currPos = _currentCoordinates!;

      if(shouldCamFollowRoad){
        //check if the next point to pass is near the user
        double totalDistance = calculateDistance(currPos, polylineCoordinates[handleMinMax(currentPolylineIndex, 0, polylineCoordinates.length-1).toInt()]);
        if ((GlobalsConst.isSimulation && totalDistance <=0.5) || totalDistance<=0.05) {
          currentPolylineIndex ++;
        }
        LatLng nextCoordinates = polylineCoordinates[handleMinMax(currentPolylineIndex, 0, polylineCoordinates.length-1).toInt()];

        //init a value for lastCoordinate at user position
        if(lastCoordinate == null) {
          setState(() {
            lastCoordinate = currPos;
          });
        }

        moveCameraWithAngle(_mapController, lastCoordinate!, nextCoordinates);
        _setSpeed(currPos, lastCoordinate!);

        //on simulation, the last coordinates is fake using a polyline item coordinates
        setState(() {
          lastCoordinate = (GlobalsConst.isSimulation ? nextCoordinates : currPos);
        });
      }
      else{
        // on second mode, we center the road on the map, with the basic camera orientation
        moveCameraWithAngle(_mapController, currPos, destinationCoordinates!);
        centerRoad(_mapController, currPos, destinationCoordinates!);

      }
    }
  }

  _setCurrentPosition(Position? pos){
    setState(() {
      _currentPosition = pos;
      if(pos != null) {
        _currentCoordinates = LatLng(pos.latitude, pos.longitude);
      }
    });
  }

  /// Get user current position and address.
  /// When it's get, add a marker on map and center camera at user location.
  _handleUserPosition({addMarker:false}) async {
    Position? userPos = await getUserCurrentLocation();
    _setCurrentPosition(userPos);

    log("#####################" + _currentPosition.toString());
    if (_currentPosition != null) {
      Placemark? place = await getAddressFromPos(_currentCoordinates!);

      try { // when no internet connection, can't use geocoding api
        String _currentAddress = formatAdressFromPlacemark(place!);

        if (addMarker) {
          _addMarker(_currentCoordinates!, _currentAddress);
        }
      } catch (e) {
        _toastError("Impossible de placer un marker sur votre destination\nconnexion internet requis");
      }

      _setCameraPos(_currentCoordinates!);
    }
  }

  /// Connect to google map to get a list of coordinates.
  /// This will be used to draw itinerary on GoogleMap
  _createPolylines(LatLng startPos, LatLng destinationPos) async {
    // Generating the list of coordinates to be used for drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyAs16bHc0Z5qlDR0XLE_UqFDzjjNeRTQ2U", // Google Maps API Key
      PointLatLng(startPos.latitude, startPos.longitude),
      PointLatLng(destinationPos.latitude, destinationPos.longitude),
      travelMode: TravelMode.transit,
    );

    log("####### result polyline: "  + result.errorMessage.toString() + result.points.toString() + ", for point " + startPos.latitude.toString() + "--" + startPos.longitude.toString() + "----------"  +destinationPos.latitude.toString() + "--" + destinationPos.longitude.toString());
    //remove all previous coordinates
    setState(() {
       while(polylineCoordinates.isNotEmpty){
        polylineCoordinates.removeLast();
      }
    });

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      setState(() {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      });
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

  /// Remove markers on map and add a new one.
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


  void _handleDestinationAddress(){
    setState(() {
      destinationAddress = destinationAddressController.text;
    });
  }

  /// Set destination, then add marker, generate and center camera on itinerary.
  _handleDestinationSubmit() async {
    LatLng destPos = await getPosFromAddress(destinationAddress);
    setState(() {
      destinationCoordinates = destPos;
    });
    _addMarker(destinationCoordinates!, destinationAddress);
    centerRoad(_mapController, _currentCoordinates!, destPos );
    _createPolylines(_currentCoordinates!, destPos);

    moveCameraWithAngle(_mapController, _currentCoordinates!, destinationCoordinates!);
  }


  //@todo : user could select a zoom value (between 15 and 10), using + - buttons
  void _setCameraPos(LatLng pos, {zoom:15.0, move:true}) async {
    setState(() {
      _camPos = CameraPosition(
        target: pos,
        zoom: zoom,
      );
    });

    if(move) {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(pos));
    }
  }

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
  _toastError(String msg) {
    if (_mapDisabled) {
      Fluttertoast.showToast(
          msg:msg,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 8,
          backgroundColor: Colors.red[700],
          textColor: Colors.black,
          fontSize: 16.0
      );
    }
  }

//@todo : use onMovement, to enabled/disable map
  /// should be launch when the user is moving
  _onMovement(){
    setState(() {
      _mapDisabled = !_mapDisabled;
    });
    _toastDisable();

  }

  _setCameraMode(){
    log("######## click cam mode");
    setState(() {
      shouldCamFollowRoad = !shouldCamFollowRoad;
    });
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          // on below line creating google maps
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    CustomMap(
                        disabled: _mapDisabled,
                        cameraPosition: _camPos,
                        markers: _markers,
                        polylines: polylines,
                        mapController: _mapController
                    ),
                    InfoScreen(),
                    ButtonGpsMode(
                      onPress: _setCameraMode,
                      shouldCamFollowRoad: shouldCamFollowRoad,
                    )
                  ]
                ),
              ),
              DestinationInput(
                controller: destinationAddressController,
                onSubmit: _handleDestinationSubmit,
              )
            ],
          )
        ),
      ),

    );
  }

}
