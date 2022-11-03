import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as Math;
import 'package:vector_math/vector_math.dart' as vMath;

///Get a distance between 2 points (in km)
double calculateDistance(LatLng pos1, LatLng pos2){
  double p = 0.017453292529943295;
  double a = 0.5 - Math.cos((pos2.latitude - pos1.latitude) * p) / 2
      + Math.cos(pos1.latitude * p) * Math.cos(pos2.latitude * p)
          * (1 - Math.cos((pos2.longitude - pos1.longitude) * p)) /2;
  
  return 12742 * Math.asin(Math.sqrt(a));
}

/// get an angle betwween 2 points
double angleFromLatLng(LatLng curPos, LatLng nextPos){
  double lon = (nextPos.longitude - curPos.longitude);

  double y = Math.sin(lon) * Math.cos(nextPos.longitude);
  double x = Math.cos(curPos.latitude) * Math.sin(nextPos.latitude)
      - Math.sin(curPos.latitude) * Math.cos(nextPos.latitude) * Math.cos(lon);

  double brng = Math.atan2(y, x);
  brng = vMath.degrees(brng);
  brng = (brng + 360) % 360;
  brng = 360 - brng;

  return brng;
}

/// Get a value between a min and max
num handleMinMax(num value, num min, num max){
  return Math.max(Math.min(value, max), min);
}