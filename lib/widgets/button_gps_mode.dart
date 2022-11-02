import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


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
        height: 50,
        width: 50,
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

        child: IconButton(
          icon: Icon((shouldCamFollowRoad ? Icons.explore : Icons.map)),
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