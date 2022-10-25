import 'dart:async';

import 'package:flutter/material.dart';

int speed = 0;
int autonomy = 50;

void main() {
  runApp(const InfoScreen());
}

IconData selectBatteryIcon(autonomy){
  print(autonomy);
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
  }else if(autonomy < 1 ){
    return Icons.battery_0_bar;
  }
  else{
    return Icons.battery_0_bar;
  }

}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(child: Container(
        margin: EdgeInsetsDirectional.only(start: 50, top: 30),
        padding: EdgeInsetsDirectional.all(10),
        height: 60,
        width: 100 * 2,
        decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),

        child:
            Row(
              children: [
                Icon(selectBatteryIcon(autonomy), color: Colors.white),
                Text(
                  autonomy.toString() + '%',
                  style: TextStyle(
                  color: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsetsDirectional.only(start: 10, end: 10),
                ),
                Icon(Icons.speed, color: Colors.white),
                Text(speed.toString() + 'Km/h',
                  style: TextStyle(
                  color: Colors.white,
                  ),
                ),
              ],
            ),
      ),
    );


    
  }
}