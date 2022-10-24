import 'dart:async';

import 'package:flutter/material.dart';

int speed = 0;
int autonomy = 0;

void main() {
  runApp(const InfoScreen());
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
        ),

        child:
            Row(
              children: [
                Icon(Icons.battery_full, color: Colors.white),
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