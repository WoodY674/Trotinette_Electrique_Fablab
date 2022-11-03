import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:patinette_electrique_fablab/helpers/styles.dart';


class ButtonGpsMode extends StatefulWidget {
  const ButtonGpsMode({Key? key, required this.onPress, required this.shouldCamFollowRoad}) : super(key: key);
  final Function onPress;
  final bool shouldCamFollowRoad;

  @override
  _ButtonGpsMode createState() => _ButtonGpsMode();
}

class _ButtonGpsMode extends State<ButtonGpsMode> {
  late bool shouldCamFollowRoad = widget.shouldCamFollowRoad;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Positioned(
      bottom: 5.0,
      left: 5.0,
      child: Container(
        height: 75,
        width: 75,
        decoration: getBoxDecoration(),

        child: IconButton(
          icon: Icon((shouldCamFollowRoad ? Icons.explore : Icons.map), color: Colors.white, size: 40),
          onPressed: (){
            widget.onPress();
            setState(() {
              shouldCamFollowRoad = !shouldCamFollowRoad;
            });
          },
        )
      ),
    );
  }
}