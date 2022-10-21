import 'dart:async';

import 'package:flutter/material.dart';

int vitesse = 0;
int autonomie = 0;

void main() {
  runApp(const InfoScreen());
}

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Column(
        children: [
      Column(
      children: [
      Container(
      width: 392,
        height: 100,
        margin: EdgeInsets.only(top : 0),
        padding: EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        decoration:
        BoxDecoration(
          color: Colors.lightGreen,
        ),
        child: Text('Vitesse : ' + vitesse.toString() + 'Km/h'),
      ),
        Container(
          width: 392,
          height: 20,
          margin: EdgeInsets.only(top : 0),
          padding: EdgeInsets.only(top: 0),
          alignment: Alignment.center,
          decoration:
          BoxDecoration(
            color: Colors.lightGreen,
          ),
          child: Text('Autonomie : ' + autonomie.toString() + 'Km'),
        ),

        ],
      ),
      ],
      ),

      ),




    );

  }
}