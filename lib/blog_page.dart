import 'dart:async';

import 'package:flutter/material.dart';
import './colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BLogPage extends StatefulWidget {
  String title;

  BLogPage({Key key, this.title}) : super(key: key);

  @override
  _BlogPageState createState() => _BlogPageState();
}

class _BlogPageState extends State<BLogPage> {
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
          "Blog",
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
                initialUrl: "https://dneeds.in/blog.html",
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
