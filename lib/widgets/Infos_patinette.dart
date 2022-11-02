import 'dart:async';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:trotinette_electrique_fablab/const.dart';
import 'package:trotinette_electrique_fablab/models/Patinette.dart';
import 'package:trotinette_electrique_fablab/api/trotinette_usecase.dart';
import 'package:trotinette_electrique_fablab/helpers/batinette_data.dart';

import 'package:trotinette_electrique_fablab/helpers/calcul.dart';

class InfoScreen extends StatefulWidget {

  const InfoScreen({Key? key}) : super(key: key);
  @override
  _InfoScreen createState() => _InfoScreen();
}

class _InfoScreen extends State<InfoScreen> {

  final TrotinetteUseCase trotUseCase = TrotinetteUseCase();
  Patinette patinette = Patinette(battery: 100, speed: 0, gear:0);
  int countDownSimulation = 0;

  @override
  void initState() {
    super.initState();
    Timer _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) => setTrotinetteData());
  }

  Future<Patinette> getTrotinetteData() async {
    if(GlobalsConst.isSimulation) { // fake data
      return Patinette(battery: 100 - countDownSimulation % 100,
          speed: math.min(countDownSimulation % 25, 10),
          gear: 0);
    }
    else {
      return await trotUseCase.getTrotinetteData();
    }
  }

  void setTrotinetteData() async {
    Patinette res = await getTrotinetteData();

    setState(() {
      patinette = res;
      countDownSimulation ++;
    });

  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(child: Container(
        margin: const EdgeInsetsDirectional.only(start: 23, top: 60),
        padding: const EdgeInsetsDirectional.all(10),
        height: 70,
        width: 117 * 3,
        decoration: BoxDecoration(
            color: Colors.green[900],
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
                Icon(selectBatteryIcon(patinette.battery), color: Colors.white, size: 24,),
                Text(
                  handleMinMax(patinette.battery, 0, 100).toString(),
                  style: const TextStyle(
                  color: Colors.white,
                    fontSize: 32.0,
                  ),
                ),

                Container(
                  margin: const EdgeInsetsDirectional.only(start: 2, end: 15),
                  child: Text(
                    '%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                    ),
                  ),
                ),

                const Icon(Icons.speed, color: Colors.white, size: 24),
                Text(' ' + patinette.speed.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                  ),
                ),

                Container(
                  margin: const EdgeInsetsDirectional.only(start: 2, end: 15),
                  child: Text(
                    'Km/h',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32.0,
                    ),
                  ),
                ),
                const Image(
                  image: AssetImage('Assets/gearbox.png'),
                  height: 20,
                ),
                Text(" " + patinette.gear.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32.0,
                  ),
                ),
              ],
            ),
      ),
    );
  }

}