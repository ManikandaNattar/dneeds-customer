import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_needs/colors.dart';

class Noti extends StatefulWidget {
  @override
  _NotiState createState() => _NotiState();
}

class _NotiState extends State<Noti> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        centerTitle: true,
        title: Text(
          "Notification",
          style: new TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text(
                  "Notification",
                  style: new TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // SizedBox(
                //   width: 183.0,
                // ),
                Switch(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                  activeTrackColor: Colors.grey[300],
                  activeColor: primaryRedColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
