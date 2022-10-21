import 'package:flutter/material.dart';
import 'package:trotinette_electrique_fablab/widgets/gmaps.dart';
import 'package:google_directions_api/google_directions_api.dart';

void main() {
  runApp(const MyApp());
  DirectionsService.init('AIzaSyAKZciqbtnw7aSe4lwAGlB-AHw6t4GHW6g');

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // on below line we are specifying title of our app
      title: 'Ma patinette',
      // on below line we are hiding debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // on below line we are specifying theme
        primarySwatch: Colors.green,
      ),
      // First screen of our app
      home: const HomePage(),
    );
  }
}
