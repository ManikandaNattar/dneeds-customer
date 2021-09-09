import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:android_intent/android_intent.dart';

import '../colors.dart';

class RateUs extends StatefulWidget {
  @override
  _RateUsState createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  num _stackToView = 1;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  void initState() {
    getInstalledApps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        title: Text(
          "Rate Us",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17.0),
        ),
        centerTitle: true,
      ),
    );
  }

  void getInstalledApps() async {
    if (Platform.isAndroid) {
      AndroidIntent intent = AndroidIntent(
          action: "action_view",
          data:
              "https://play.google.com/store/apps/details?id=com.DailyNeeds.dailyneeds");
      intent.launch();
    }
  }
}
