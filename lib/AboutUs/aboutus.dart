import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
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
        backgroundColor: Colors.red,
        title: Text(
          "About",
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
                initialUrl: "https://dneeds.in/about.html",
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
