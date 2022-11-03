import 'dart:async';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:patinette_electrique_fablab/const.dart';
import 'package:patinette_electrique_fablab/models/Patinette.dart';
import 'package:patinette_electrique_fablab/api/patinette_usecase.dart';
import 'package:patinette_electrique_fablab/helpers/batinette_data.dart';
import 'package:patinette_electrique_fablab/helpers/calcul.dart';
import 'package:patinette_electrique_fablab/helpers/notification_center.dart';
import 'package:patinette_electrique_fablab/helpers/styles.dart';

class InfoScreen extends StatefulWidget {

  const InfoScreen({Key? key}) : super(key: key);
  @override
  _InfoScreen createState() => _InfoScreen();
}

class _InfoScreen extends State<InfoScreen> {
  //region init vars
  final PatinetteUseCase trotUseCase = PatinetteUseCase();
  Patinette patinette = const Patinette(battery: 100, speed: 0, gear:0);
  int countDownSimulation = 0;
  Timer? _timer;
  //endregion

  //region override function (init, dispose ...)
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) => setPatinetteData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  //endregion

  //region get/set patinette data
  Future<Patinette> getPatinetteData() async {
    if(GlobalsConst.isSimulation) { // fake data
      int speed = math.min(countDownSimulation % 25, 30);
      return Patinette(battery: 100 - countDownSimulation % 100,
          speed: speed,
          gear: defineGear(speed));
    }
    else {
      return await trotUseCase.getPatinetteData();
    }
  }

  void setPatinetteData() async {
    Patinette res = await getPatinetteData();

    setState(() {
      patinette = res;
      countDownSimulation ++;
    });

    Observable.instance.notifyObservers(NotificationCenter.trottinetteDataReceived.stateImpacted, notifyName: NotificationCenter.trottinetteDataReceived.name, map: {"patinette":patinette});
  }
  //endregion

  Widget getWidgetDataPatinetteUnit(String text){
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 2, end: 15),
      child: Text( text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 32.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(child: Container(
    margin: const EdgeInsetsDirectional.only(start: 23, top: 60),
    padding: const EdgeInsetsDirectional.all(10),
    height: 70,
    width: 117 * 3,
    decoration: getBoxDecoration(),

    child:
        Row(
          children: [
            Icon(selectBatteryIcon(patinette.battery), color: Colors.white, size: 24,),
            Text( handleMinMax(patinette.battery, 0, 100).toString(),
              style: getTextStyleDataPatinette()
            ),
            getWidgetDataPatinetteUnit("%"),

            const Icon(Icons.speed, color: Colors.white, size: 24),
            Text(' ' + patinette.speed.toString(),
              style: getTextStyleDataPatinette()
            ),
            getWidgetDataPatinetteUnit("Km/h"),

            const Image(
              image: AssetImage('Assets/gearbox.png'),
              height: 20,
            ),
            Text(" " + patinette.gear.toString(),
              style: getTextStyleDataPatinette()
            ),
          ],
        ),
      ),
    );
  }

}