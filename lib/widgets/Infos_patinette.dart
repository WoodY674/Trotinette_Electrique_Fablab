import 'dart:async';
import 'dart:math' as math;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_observer/Observer.dart';
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
  _InfoScreenState createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> with Observer{
  //region init vars
  final PatinetteUseCase trotUseCase = PatinetteUseCase();
  Patinette patinette = Patinette(battery: 100, speed: 0, gear:0);
  int countDownSimulation = 0;
  Timer? _timer;
  //endregion

  //region override function (init, dispose ...)
  @override
  void initState() {
    super.initState();
    Observable.instance.addObserver(this);
    //10 second to get only remaining battery should be largely enough
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) => setPatinetteData());
  }

  @override
  update(Observable observable, String? notifyName, Map? map) {
    if(notifyName == NotificationCenter.speedCalculated.name){
      if(map != null && map.keys.contains("speed") && map.keys.contains("gear")){
        patinette.gear = map["gear"];
        patinette.speed = map["speed"].round();
      }
    }
    //throw UnimplementedError();
  }

  @override
  void dispose() {
    _timer?.cancel();
    Observable.instance.removeObserver(this);
    super.dispose();
  }
  //endregion

  //region get/set patinette data
  Future<Patinette> getPatinetteData() async {
    if(GlobalsConst.isSimulation) {
      //fake data V1:
      //int speed = math.min(countDownSimulation % 25, 30);
      //return Patinette(battery: 100 - countDownSimulation % 100,
      //           speed: speed,
      //           gear: defineGear(speed));

      //fake V2
      setState(() {
        patinette.battery = 100 - countDownSimulation % 100;
      });
      return patinette;
    }
    else {
      return await trotUseCase.getPatinetteData();
    }
  }

  void setPatinetteData() async {
    Patinette res = await getPatinetteData();

    if(GlobalsConst.isSimulation) {
      setState(() {
        patinette = res;
        countDownSimulation ++;
      });
    }
    else{
      setState(() {
        patinette.battery = res.battery;
      });
    }

    Observable.instance.notifyObservers(NotificationCenter.trottinetteDataReceived.stateImpacted, notifyName: NotificationCenter.trottinetteDataReceived.name, map: {"patinette":patinette});
  }
  //endregion

  Widget getWidgetDataPatinetteUnit(String text, {fontSize:32.0}){
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 2, end: 15),
      child: Text( text,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
        ),
      ),
    );
  }

  double adaptFontSizeOnDataPatinette(){
    int nbVariableChars = patinette.speed.abs().toString().length + patinette.battery.toString().length;
    return math.min(32.0, 32.0 + ((4 - nbVariableChars) * 3));
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
              style: getTextStyleDataPatinette(fontSize: adaptFontSizeOnDataPatinette())
            ),
            getWidgetDataPatinetteUnit("%", fontSize: adaptFontSizeOnDataPatinette()),

            const Icon(Icons.speed, color: Colors.white, size: 24),
            Text(' ' + patinette.speed.toString(),
              style: getTextStyleDataPatinette(fontSize: adaptFontSizeOnDataPatinette())
            ),
            getWidgetDataPatinetteUnit("Km/h", fontSize: adaptFontSizeOnDataPatinette()),

            const Image(
              image: AssetImage('Assets/gearbox.png'),
              height: 20,
            ),
            Text(" " + patinette.gear.toString(),
              style: getTextStyleDataPatinette(fontSize: adaptFontSizeOnDataPatinette())
            ),
          ],
        ),
      ),
    );
  }

}