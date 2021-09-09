import 'dart:async';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class Contact extends StatefulWidget {
  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
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
          "Contact us",
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
                initialUrl: "https://dneeds.in/contact.html",
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: _handleLoad,
                onWebViewCreated: (WebViewController controller) {
                  _controller.complete(controller);
                },
                navigationDelegate: (NavigationRequest request) async {
                  if (request.url.contains("mailto:")) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                  } else if (request.url.contains("tel:")) {
                    launch(request.url);
                    return NavigationDecision.prevent;
                  }
                  return NavigationDecision.navigate;
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
