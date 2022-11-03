import 'dart:async';
import 'dart:developer';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:patinette_electrique_fablab/helpers/calcul.dart';

String formatAdressFromPlacemark(Placemark place){
  return "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
}

Future<Placemark?> getAddressFromPos(LatLng pos) async {
  try {
    List<Placemark> p = await placemarkFromCoordinates(pos.latitude, pos.longitude);
    // Taking the most probable result
    Placemark place = p[0];
    return place;
  } catch (e) {
    log("An Error occured to get places");
    print(e);
  }
  return null;
}

Future<LatLng> getPosFromAddress(String address) async {
  List<Location> destinationPlacemark = await locationFromAddress(address);
  return LatLng(destinationPlacemark[0].latitude, destinationPlacemark[0].longitude);
}

/// Get user current location
Future<Position?> getUserCurrentLocation() async {
  await Geolocator.requestPermission().then((value){
  }).onError((error, stackTrace) async {
    await Geolocator.requestPermission();
    log("ERROR"+error.toString());
  });
  return await Geolocator.getCurrentPosition();
}


centerRoad(Completer<GoogleMapController> mapController, LatLng pos1, LatLng pos2) async {
  double miny = (pos1.latitude <= pos2.latitude) ? pos1.latitude : pos2.latitude;
  double minx = (pos1.longitude <= pos2.longitude) ? pos1.longitude : pos2.longitude;
  double maxy = (pos1.latitude <= pos2.latitude) ? pos2.latitude : pos1.latitude;
  double maxx = (pos1.longitude <= pos2.longitude) ? pos2.longitude : pos1.longitude;

  double southWestLatitude = miny;
  double southWestLongitude = minx;

  double northEastLatitude = maxy;
  double northEastLongitude = maxx;

  // Accommodate the two locations within the camera view of the map
  final GoogleMapController controller = await mapController.future;
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

moveCameraWithAngle(Completer<GoogleMapController> mapController,LatLng targetCoordinates, LatLng nextCoordinates) async {
  final GoogleMapController controller = await mapController.future;
  controller.animateCamera(
      CameraUpdate.newCameraPosition(
          CameraPosition(
              target: targetCoordinates,
              zoom: 18,
              bearing: angleFromLatLng(targetCoordinates, nextCoordinates)
          )
      )
  );
}