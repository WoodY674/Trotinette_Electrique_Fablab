import 'dart:async';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trotinette_electrique_fablab/models/Patinette.dart';
import 'package:trotinette_electrique_fablab/api/trotinette_usecase.dart';


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

int gear(speed){
  if(speed > 0 && speed <= 6 ){
    return 1;
  }else if(speed > 6 && speed <= 15){
    return 2;
  }else if(speed > 15 && speed <= 25){
    return 3;
  }
  return 0;
}

class InfoScreen extends StatefulWidget {

  const InfoScreen({Key? key}) : super(key: key);
  @override
  _InfoScreen createState() => _InfoScreen();
}

class _InfoScreen extends State<InfoScreen> {

  final TrotinetteUseCase trotUseCase = TrotinetteUseCase();
  Patinette patinette = Patinette(battery: 100, speed: 0);
  int countDownSimulation = 0;
  @override
  void initState() {
    super.initState();
    //futurePatinette = fetchPatinette(widget.userId);
    Timer _timer = new Timer.periodic(Duration(seconds: 2), (Timer timer) => getTrotinetteData());
  }

  void getTrotinetteData() async {
    //fake
    Patinette res = Patinette(battery: 100-countDownSimulation%100, speed: math.min(countDownSimulation%25, 25));

    //Patinette res = await trotUseCase.getTrotinetteData();
    setState(() {
      patinette = res;
      countDownSimulation ++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(child: Container(
        margin: EdgeInsetsDirectional.only(start: 50, top: 30),
        padding: EdgeInsetsDirectional.all(10),
        height: 60,
        width: 90 * 3,
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
                Icon(selectBatteryIcon(patinette.battery), color: Colors.white),
                Text(
                  patinette.battery.toString() + ' %',
                  style: const TextStyle(
                  color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10, end: 10),
                ),
                const Icon(Icons.speed, color: Colors.white),
                Text(' ' + patinette.speed.toString() + ' Km/h',
                  style: const TextStyle(
                  color: Colors.white,
                  ),
                ),
                Container(
                  margin: const EdgeInsetsDirectional.only(start: 10, end: 10),
                ),
                const Image(
                    image: AssetImage('Assets/gearbox.png'),
                  height: 18,
                ),
                Text(' ' + gear(patinette.speed).toString(),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
      ),
    );
  }

}