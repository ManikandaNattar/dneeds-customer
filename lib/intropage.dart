import 'dart:ui';
import 'package:daily_needs/daily_homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';
import 'package:flutter_twilio_voice/flutter_twilio_voice.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_needs/otpscreen/otp_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/api_model_classes/check_mobile.dart';
import 'package:location/location.dart';

class Intro extends StatefulWidget {
  @override
  IntroSetState createState() => IntroSetState();
}

class IntroSetState extends State<Intro> {
  TextEditingController phoneno = new TextEditingController();
  bool phoneIsEmpty = false;
  String userId;
  String _platformVersion = 'Unknown';
  String _eventMessage;
  bool isLoading = false;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String user;
  Location location = new Location();
  bool _serviceEnabled;
  LocationData _locationData;

  @override
  void initState() {
    super.initState();
    checkFirstTimeCome();
    tryToGetLocationPermission();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await FlutterTwilioVoice.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void _onEvent(Object event) {
    setState(() {
      _eventMessage =
          "Battery status: ${event == 'charging' ? '' : 'dis'}charging.";
    });
  }

  void _onError(Object error) {
    setState(() {
      _eventMessage = 'Battery status: unknown.';
    });
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 5));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                new Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(color: Colors.white),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Text(
                          "Start Servicing with DNeeds",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: primaryRedColor,
                              fontSize: 25.0,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        new Text(
                          "A friend in need",
                          style: TextStyle(
                              color: primaryRedColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: TextField(
                            controller: phoneno,
                            decoration: InputDecoration(
                              hintText: "Enter Mobile Number",
                              prefixIcon: Icon(
                                Icons.phone_iphone,
                                color: Colors.grey,
                              ),
                              errorText:
                                  phoneIsEmpty ? "Enter Mobile Number" : null,
                              counterText: "",
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                            ),
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        SizedBox(
                          height: 40.0,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: MaterialButton(
                            color: primaryRedColor,
                            height: 40.0,
                            child: Text(
                              "Continue",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                            minWidth: double.infinity,
                            splashColor: Colors.white,
                            onPressed: () {
                              if (!phoneno.text.isEmpty &&
                                  phoneno.text.length == 10) {
                                callCheckMobileNumber(
                                    mobile: phoneno.text.toString());
                              } else {
                                setState(() {
                                  phoneIsEmpty = true;
                                });
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0, right: 10.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Skip for now",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: primaryRedColor,
                                  fontFamily: ""),
                            ),
                          )),
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void getUserDetails() async {
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String newUserId = loginId ?? signupId;
    setState(() {
      userId = newUserId;
    });
    if (userId != null) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void checkFirstTimeCome() async {
    var citiesList = await get_stringList_pref("cities");
    print(citiesList);
    bool check = await get_bool_prefs("isMobileAuth");
    print("is mobile auth check=" + check.toString());
    String checkmob = await get_string_prefs("mobile");
    print("mob saved in intro page=" + checkmob);
    bool homeloginflag = await get_bool_prefs("isHomeLogin");
    print("login via home menu=" + homeloginflag.toString());
  }

  Future<void> callCheckMobileNumber({String mobile}) async {
    checkMobileNumber(mobileNumber: mobile).then((onResponse) {
      if (onResponse is Check_MobileNumber) {
        if (onResponse.data.message == "Mobile number not exist.") {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Otp(
                      mobleNumber: this.phoneno.text, isMobileEntry: true)));
        } else if (onResponse.data.message == "Mobile number already exist.") {
          save_string_prefs('mobile', this.phoneno.text);
          save_bool_prefs('isMobileAuth', true);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        }
      }
    });
  }

  void tryToGetLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    print("is location activated=" + _serviceEnabled.toString());
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        tryToGetLocationPermission();
      }
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        tryToGetLocationPermission();
      }
    }

    _locationData = await location.getLocation().then((value) {
      print(value.longitude);
    });
  }
}
