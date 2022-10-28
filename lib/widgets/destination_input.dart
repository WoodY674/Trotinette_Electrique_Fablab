import 'dart:developer';
import 'package:flutter/material.dart';

class DestinationInput extends StatefulWidget {
  const DestinationInput({Key? key, required this.controller, required this.onSubmit}) : super(key: key);
  final TextEditingController controller;
  final Function onSubmit;

  @override
  _DestinationInputState createState() => _DestinationInputState();
}

class _DestinationInputState extends State<DestinationInput> {
  late TextEditingController destinationAddressController = widget.controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    destinationAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Container(
      height: height * .06,
      width: width,
      child: Row(
        children: [
          Expanded(
            child:TextField(
              controller: destinationAddressController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Destination',
              ),
            ),
          ),
          Container(
              width:60,
              child:IconButton(
                  onPressed: () => {widget.onSubmit()},
                  icon: Icon(Icons.send)
              )
          )
        ],
      ),
    );
  }

}
