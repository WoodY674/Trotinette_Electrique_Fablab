import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final directionsService = DirectionsService();
  final request = DirectionsRequest(
    origin: 'Chicago, IL',
    destination: 'San Francisco, CA',
    travelMode: TravelMode.driving,
  );

  final destinationAddressController = TextEditingController();
  String destinationAddress = "";
  LatLng? destinationPos;

  Position? _currentPosition;
  String _currentAddress = "";

  final List<Marker> _markers = <Marker>[];
  Completer<GoogleMapController> _mapController = Completer();

  CameraPosition _camPos = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
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
    destinationPos = await _getPosFromAddress(destinationAddress);
    _addMarker(destinationPos!, destinationAddress);
    _centerRoad();
  }

  _centerRoad() async {
    double miny = (_currentPosition!.latitude <= destinationPos!.latitude)
        ? _currentPosition!.latitude
        : destinationPos!.latitude;
    double minx = (_currentPosition!.longitude <= destinationPos!.longitude)
        ? _currentPosition!.longitude
        : destinationPos!.longitude;
    double maxy = (_currentPosition!.latitude <= destinationPos!.latitude)
        ? destinationPos!.latitude
        : _currentPosition!.latitude;
    double maxx = (_currentPosition!.longitude <= destinationPos!.longitude)
        ? destinationPos!.longitude
        : _currentPosition!.longitude;

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
      appBar: AppBar(
        backgroundColor: Color(0xFF0F9D58),
        title: Text("GFG"),
      ),
      body: Container(
        child: SafeArea(
          // on below line creating google maps
          child: Column(
            children: [
              Container(
                  height: height * .7,
                  width: width,
                  child: GoogleMap(
                initialCameraPosition: _camPos,
                markers: Set<Marker>.of(_markers),
                mapType: MapType.normal,
                myLocationEnabled: true,
                compassEnabled: true,
                onMapCreated: (GoogleMapController controller){
                  _mapController.complete(controller);
                },
              )
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
