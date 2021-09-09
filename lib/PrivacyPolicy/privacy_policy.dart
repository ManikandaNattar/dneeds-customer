import 'dart:async';
import 'package:daily_needs/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Privacy extends StatefulWidget {
  @override
  _PrivacyState createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  num _stackToView = 1;
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  void _handleLoad(String value) {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        title: Text(
          "Privacy Policy",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17.0),
        ),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _stackToView,
        children: [
          Column(
            children: <Widget>[
              Expanded(
                  child: WebView(
                initialUrl: "https://dneeds.in/privacy_policy.html",
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: _handleLoad,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
              )),
            ],
          ),
          Container(
              child: Center(
            child: CircularProgressIndicator(),
          )),
        ],
      ),
    );
  }
}
