import 'package:daily_needs/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwilioPhoneCall extends StatefulWidget {
  String bookedService;
  String bookedServiceMobileNmber;
  TwilioPhoneCall({this.bookedService, this.bookedServiceMobileNmber})
      : super();
  @override
  TwilioPhoneCallState createState() => TwilioPhoneCallState();
}

class TwilioPhoneCallState extends State<TwilioPhoneCall> {
  static const platform = const MethodChannel("TwilioChannel");
  String _eventMessage;
  bool isHoldPrssed = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: new Stack(
            children: <Widget>[
              new Positioned(
                top: MediaQuery.of(context).size.height * 0.20,
                height: 100.0,
                width: MediaQuery.of(context).size.width,
                child: new Padding(
                  padding: EdgeInsets.only(left: 20.0, right: 20.0),
                  child: new Container(
                    child: Column(
                      children: <Widget>[
                        new Text(
                          widget.bookedService,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        new SizedBox(
                          height: 25.0,
                        ),
                        /* new Text(
                          widget.bookedServiceMobileNmber,
                          style: TextStyle(fontSize: 16.0),
                        )*/
                      ],
                    ),
                  ),
                ),
              ),
              new Positioned(
                  top: MediaQuery.of(context).size.height * 0.85,
                  height: 80.0,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          new InkWell(
                            child: new Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryRedColor),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.pause,
                                  color: isHoldPrssed
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                isHoldPrssed = !isHoldPrssed;
                              });
                              callNativeForEndCall("hold");
                            },
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),
                          new Text(
                            "Hold",
                            style: TextStyle(color: textColor),
                          )
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          new InkWell(
                            child: new Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: primaryRedColor),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onTap: () {
                              callNativeForEndCall("hangup");
                              Navigator.of(context).pop();
                            },
                          ),
                          new SizedBox(
                            height: 10.0,
                          ),
                          new Text(
                            "End Call",
                            style: TextStyle(color: textColor),
                          )
                        ],
                      ),
                    ],
                  ))
            ],
          )),
    );
  }

  Future<void> callNativeForEndCall(String methodname) async {
    try {
      String messageFromNative = await platform.invokeMethod(methodname);
      _eventMessage = messageFromNative;
    } on PlatformException catch (e) {
      _eventMessage = "Failed to Invoke: '${e.message}'.";
    }
    print(_eventMessage);
  }
}
