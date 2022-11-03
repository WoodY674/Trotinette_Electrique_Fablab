import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

BoxDecoration getBoxDecoration(){
  return BoxDecoration(
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
  );
}

TextStyle getTextStyleDataPatinette(){
  return const TextStyle(
    color: Colors.white,
    fontSize: 32.0,
  );
}