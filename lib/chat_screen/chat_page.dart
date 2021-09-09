import 'package:daily_needs/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/get_user_location.dart';

import 'package:webview_flutter/webview_flutter.dart';

String order_id;

class ChatPage extends StatefulWidget {
  String chatId;
  String user_name;
  String order_id;
  String vendor_id;
  String user_id;
  String service_id;

  ChatPage(
      {this.chatId,
      this.user_name,
      this.order_id,
      this.user_id,
      this.vendor_id,
      this.service_id})
      : super();

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  WebViewController _webViewController;
  int pos = 1;
  var id = "bca7625e0e1aea42624f728364d25535";

  @override
  void initState() {
    super.initState();
    print(
        '${widget.vendor_id}, ${widget.order_id}, ${widget.user_id}, ${widget.service_id}');
  }

  void _handleLoad(String value) {
    print(1);
    setState(() {
      pos = 0;
    });
  }

  @override
  void dispose() {
    _webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        title: Text('Chat'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: pos,
        children: [
          SingleChildScrollView(
            child: new Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.85,
              child: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: WebView(
                  initialUrl: "https://dneeds.in/chat-test",
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                    Map<String, String> header = {
                      "chat_room": "${widget.chatId}",
                      "first_name": widget.user_name
                    };
                  },
                  onPageStarted: (_) {
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("chat_room", "${widget.chatId}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("first_name", "${widget.user_name}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("order_id", "${widget.order_id}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("vendor_id", "${widget.vendor_id}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("user_id", "${widget.user_id}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("service_id", "${widget.order_id}")');
                    _webViewController.evaluateJavascript(
                        'sessionStorage.setItem("user_type", "client")');
                  },
                  onPageFinished: _handleLoad,
                ),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text("Loading..."),
              )
            ],
          ),
        ],
      ),
    );
  }
}
