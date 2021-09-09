import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:daily_needs/colors.dart';
import 'package:flutter/services.dart';

bool enbleMap = false;

class MapExample extends StatefulWidget {
  @override
  MapExampleState createState() => MapExampleState();
}

class MapExampleState extends State<MapExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new DraggableScrollableSheet(
          initialChildSize: 0.3,
          minChildSize: 0.1,
          maxChildSize: 0.8,
          builder: (BuildContext context, myscrollController) {
            return Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10.0),
                        topLeft: Radius.circular(10.0)),
                    color: Colors.white),
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.only(right: 20.0, left: 20.0),
                      child: new Text(
                        "Your Location",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    new SizedBox(
                      height: 10.0,
                    ),
                    new Padding(
                      padding: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: Text("vasanth vasanth vasanth"),
                    ),
                    new Divider()
                  ],
                ));
          }),
    );
  }
}
