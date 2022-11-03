import 'package:flutter/material.dart';

IconData selectBatteryIcon(autonomy){
  if(autonomy >= 90){
    return Icons.battery_full;
  }else if(autonomy >= 75 && autonomy < 90){
    return Icons.battery_6_bar;
  }else if(autonomy >= 60 && autonomy < 75){
    return Icons.battery_5_bar;
  }else if(autonomy >= 45 && autonomy < 60){
    return Icons.battery_4_bar;
  }else if(autonomy >= 30 && autonomy < 45){
    return Icons.battery_3_bar;
  }else if(autonomy >= 15 && autonomy < 30){
    return Icons.battery_2_bar;
  }else if(autonomy < 15 ){
    return Icons.battery_1_bar;
  }else if(autonomy < 5 ){
    return Icons.battery_0_bar;
  }
  else{
    return Icons.battery_0_bar;
  }
}

int defineGear(speed){
  if(speed > 0 && speed <= 6 ){
    return 1;
  }else if(speed > 6 && speed <= 15){
    return 2;
  }else if(speed > 15){
    return 3;
  }
  return 0;
}