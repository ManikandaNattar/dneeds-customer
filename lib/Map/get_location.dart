import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:daily_needs/Map/show_map.dart';
import 'package:daily_needs/chat_screen/chat_page.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/homepage_slider/home_slider.dart';
import 'package:daily_needs/phone_call/phone_call_screen.dart';
import 'package:flutter/services.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:daily_needs/api_model_classes/cancel_order.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:daily_needs/login_model.dart';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:daily_needs/colors.dart';
import '../api.dart';
import 'package:toast/toast.dart';
import 'package:daily_needs/getAllCategoryService.dart';

class MapPage extends StatefulWidget {
  String vendorLat;
  String vendorLong;
  String userLat;
  String userLongi;
  String vendorName;
  String vendorAddress;
  String order_id;
  String userid;
  String vendor_chat_id;
  String vendor_mobile_number;
  String service_Name;
  String booking_customer_name;
  String venddor_id;

  MapPage(
      {this.vendorLat,
      this.vendorLong,
      this.userLat,
      this.userLongi,
      this.vendorAddress,
      this.vendorName,
      this.order_id,
      this.userid,
      this.vendor_chat_id,
      this.vendor_mobile_number,
      this.service_Name,
      this.booking_customer_name,
      this.venddor_id})
      : super();

  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  final CameraPosition _intialPosition =
      CameraPosition(target: LatLng(45.521563, -122.677433));
  Completer<GoogleMapController> _googleController = Completer();
  StreamSubscription _locationSubscription;
  StreamSubscription _locationSubscription1;
  StreamSubscription _locationSubscription2;
  StreamSubscription _locationSubscription3;
  GoogleMapController _gmapController;
  Map<String, String> vendorChatMap = new Map();
  static const platform = const MethodChannel("TwilioChannel");
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  LatLng vendor;
  LatLng customer;
  LatLng vendor_from_map;
  final Set<Marker> _markers = {};
  Marker marker;
  Circle circle;
  double vendorLattitude;
  double vendorLongitude;
  double userLattitude;
  double userLongitude;
  bool isAccepted = false;
  bool isRejected = false;
  bool showMap = false;
  final Set<Polyline> _polyline = {};
  final Set<Polyline> polyline = {};
  List<LatLng> list_for_polylines = List();
  String changevendorName;
  String changevendorAddress;
  String changedVendorMobileNumber;
  String changedVendorChatId;
  List<String> imgListBanner = [];
  GetAllCategoryServices getCategoryBanners;
  final interval = const Duration(seconds: 1);
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyAySBuTqulauB3WO2Pcxuxbp95vXMKACWw");
  List<LatLng> routeCoords;
  final int timerMaxSeconds = 300;
  Timer time;
  int currentSeconds = 0;
  String _eventMessage;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout([int milliseconds]) {
    var duration = interval;
    time = new Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (timer.tick >= timerMaxSeconds) {
            timer.cancel();
            print(time.isActive);
          }
          if (isAccepted) {
            timer.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    currentSeconds = 0;
    time.cancel();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    if (_locationSubscription1 != null) {
      _locationSubscription1.cancel();
    }
    if (_locationSubscription2 != null) {
      _locationSubscription2.cancel();
    }
    if (_locationSubscription3 != null) {
      _locationSubscription3.cancel();
    }
    super.dispose();
  }

  final listenfirebasedatabase =
      FirebaseDatabase.instance.reference().child("user");

  void _onMapCreated(GoogleMapController mapController) {
    setState(() {
      _googleController.complete(mapController);
    });
  }

  @override
  void initState() {
    super.initState();
    checkFirebaseDatabase();
    recieveBanner();
    vendorLattitude = double.parse(widget.vendorLat);
    vendorLongitude = double.parse(widget.vendorLong);
    userLattitude = double.parse(widget.userLat);
    userLongitude = double.parse(widget.userLongi);
    vendor = LatLng(vendorLattitude, vendorLongitude);
    customer = LatLng(userLattitude, userLongitude);
    _markers.add(Marker(
      markerId: MarkerId(customer.toString()),
      position: customer,
      infoWindow: InfoWindow(
        title: 'You are here',
        snippet: '5 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
    list_for_polylines.add(customer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Vendor Details"),
        centerTitle: true,
        backgroundColor: primaryRedColor,
      ),
      body: imgListBanner.length == 0
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[Center(child: CircularProgressIndicator())],
            )
          : Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ListView(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: new Padding(
                              padding: EdgeInsets.all(2.0),
                              child: CarouselWithIndicator(
                                sliderList: imgListBanner,
                                enlargeCenterPage: true,
                              )),
                        ),
                        new SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.0, vertical: 5.0),
                                child: new Card(
                                  elevation: 10.0,
                                  shadowColor: Colors.grey[300],
                                  child: new Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 10.0),
                                          child: Text(
                                            changevendorName ??
                                                widget.vendorName,
                                            style: TextStyle(
                                                fontSize: 20.0,
                                                color: textColor),
                                          )),
                                      Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 5.0),
                                          child: Text(
                                            changevendorAddress ??
                                                widget.vendorAddress,
                                            style: TextStyle(
                                                fontSize: 15.0,
                                                color: textColor),
                                          )),
                                      new SizedBox(
                                        height: 5.0,
                                      ),
                                      new Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 10.0),
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "Status: ",
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: textColor),
                                                ),
                                                new SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(
                                                  isAccepted
                                                      ? "Accepted"
                                                      : "Submitted",
                                                  style: TextStyle(
                                                      color: isAccepted
                                                          ? Colors.green
                                                          : Colors.blueGrey,
                                                      fontSize: 15.0),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      new SizedBox(
                                        height: 10.0,
                                      ),
                                      new Visibility(
                                        visible: isAccepted,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5.0, bottom: 5.0),
                                          child: new Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              new InkWell(
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        border: Border.all(
                                                            color:
                                                                primaryRedColor)),
                                                    child: new Padding(
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: <Widget>[
                                                              new Icon(
                                                                Icons
                                                                    .my_location,
                                                                color:
                                                                    primaryRedColor,
                                                              ),
                                                              new SizedBox(
                                                                width: 10.0,
                                                              ),
                                                              new Text(
                                                                "Track",
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryRedColor),
                                                              )
                                                            ]))),
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ShowMap(
                                                                orderId: widget
                                                                    .order_id,
                                                                initialLong: widget
                                                                    .userLongi,
                                                                initialLat:
                                                                    widget
                                                                        .userLat,
                                                              )));
                                                },
                                              ),
                                              new SizedBox(
                                                height: 10.0,
                                              ),
                                              new InkWell(
                                                child: new Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        border: Border.all(
                                                          color:
                                                              primaryRedColor,
                                                        )),
                                                    child: new Padding(
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: <Widget>[
                                                              new Icon(
                                                                Icons.call,
                                                                color:
                                                                    primaryRedColor,
                                                              ),
                                                              new SizedBox(
                                                                width: 10.0,
                                                              ),
                                                              new Text(
                                                                "Call",
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryRedColor),
                                                              )
                                                            ]))),
                                                onTap: () {
                                                  if (widget
                                                          .vendor_mobile_number !=
                                                      null) {
                                                    callNative(widget
                                                        .vendor_mobile_number);
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              TwilioPhoneCall(
                                                            bookedServiceMobileNmber:
                                                                changedVendorMobileNumber ??
                                                                    widget
                                                                        .vendor_mobile_number,
                                                            bookedService: widget
                                                                .service_Name,
                                                          ),
                                                        ));
                                                  } else {
                                                    Toast.show(
                                                        "Unable To Call Vendor Now",
                                                        context,
                                                        duration:
                                                            Toast.LENGTH_LONG,
                                                        gravity: Toast.BOTTOM);
                                                  }
                                                },
                                              ),
                                              new SizedBox(
                                                height: 10.0,
                                              ),
                                              new InkWell(
                                                child: new Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                        border: Border.all(
                                                          color:
                                                              primaryRedColor,
                                                        )),
                                                    child: new Padding(
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: <Widget>[
                                                              new Icon(
                                                                Icons.message,
                                                                color:
                                                                    primaryRedColor,
                                                              ),
                                                              new SizedBox(
                                                                width: 10.0,
                                                              ),
                                                              new Text(
                                                                "Chat",
                                                                style: TextStyle(
                                                                    color:
                                                                        primaryRedColor),
                                                              )
                                                            ]))),
                                                onTap: () async {
                                                  String user_name =
                                                      await get_string_prefs(
                                                          "user_name");
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ChatPage(
                                                                chatId: changedVendorChatId ??
                                                                    widget
                                                                        .vendor_chat_id,
                                                                user_name: widget
                                                                        .booking_customer_name ??
                                                                    user_name,
                                                                vendor_id: widget
                                                                    .venddor_id,
                                                                user_id: widget
                                                                    .userid,
                                                                order_id: widget
                                                                    .order_id,
                                                                service_id: widget
                                                                    .order_id,
                                                              )));
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      new Visibility(
                                        visible: isAccepted == false,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    "Waiting for Vendor to accept service ",
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  new Text(
                                                    timerText,
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: textColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "",
                                                    style: TextStyle(
                                                        fontSize: 15.0,
                                                        color: Colors.grey,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.0),
        child: MaterialButton(
          height: 50.0,
          child: Text(
            "Cancel Order",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 15.0,
                fontWeight: FontWeight.bold),
          ),
          color: primaryRedColor,
          minWidth: double.infinity,
          onPressed: () async {
            String st = await get_string_prefs("signUpToken");
            String lt = await get_string_prefs("loginToken");
            String signUpToken = st == "" ? null : st;
            String loginToken = lt == "" ? null : lt;
            tryToCancelOrder(
                ord_ID: widget.order_id, userToken: signUpToken ?? loginToken);
          },
        ),
      ),
    );
  }

  void checkFirebaseDatabase() async {
    _locationSubscription =
        listenfirebasedatabase.onValue.listen((event) async {
      var snapshotts = event.snapshot;
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "Y") {
        time.cancel();
        vendorChatMap[widget.order_id] = widget.vendor_chat_id;
        String storeChatIdToPrefs = json.encode(vendorChatMap);
        save_string_prefs("vendorChatMapping", storeChatIdToPrefs);
        setState(() {
          isAccepted = true;
          isRejected = true;
        });
      }
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "R") {
        isAccepted = false;
        while (isAccepted == false) {
          time.cancel();
          listenfirebasedatabase.child(widget.order_id.toString()).set({
            "Latitude": widget.userLat,
            "Longitude": widget.userLongi,
            "is_order_placed": "Y",
            "is_vendor_accepted": "A"
          });
          tryToChangeVendor();
          startTimeout();
          _locationSubscription
              .pause(await Future.delayed(const Duration(minutes: 5)));
          if (isAccepted == false && isRejected == false) {
            continue;
          } else {
            break;
          }
        }
      }
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "N") {
        while (isAccepted == false) {
          startTimeout();
          _locationSubscription
              .pause(await Future.delayed(const Duration(minutes: 5)));
          if (isAccepted == false && isRejected == false) {
            tryToChangeVendor();
          } else {
            break;
          }
        }
      }
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "V") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => HomePage()),
            (Route<dynamic> route) => false);
      }
    });
  }

  void tryToChangeVendor() async {
    String st = await get_string_prefs("signUpToken");
    String lt = await get_string_prefs("loginToken");
    String signUpToken = st == "" ? null : st;
    String loginToken = lt == "" ? null : lt;
    print('orderID:${widget.order_id}');
    changeVendorProcess(
        token: signUpToken ?? loginToken, order_ID: widget.order_id);
  }

  void changeVendorProcess({String order_ID, String token}) async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    changeVendor(orderID: order_ID, token: token).then((onResponse) async {
      if (onResponse is ChangeVendor) {
        if (onResponse.data.message == "New vendor changed Successfully") {
          if (mounted) {
            setState(() {
              changevendorName = onResponse.data.closestVendor.firstName;
              changevendorAddress = onResponse.data.closestVendor.address;
              changedVendorMobileNumber =
                  onResponse.data.closestVendor.mobileNo;
              changedVendorChatId = onResponse.data.chatRoom;
            });
          }
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(""),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: "Order Changed To Another Vendor",
                        )
                      ],
                    ),
                    actions: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: FlatButton(
                          splashColor: Colors.white,
                          color: Colors.red,
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ));
          print(onResponse.data.message);
        } else {
          setState(() {
            isRejected = true;
          });
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(""),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: onResponse.data.message,
                        )
                      ],
                    ),
                    actions: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: FlatButton(
                          splashColor: Colors.white,
                          color: Colors.red,
                          child: Text(
                            'OK',
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            time.cancel();
                            if (_locationSubscription != null) {
                              _locationSubscription.cancel();
                            }

                            if (_locationSubscription1 != null) {
                              _locationSubscription1.cancel();
                            }
                            if (_locationSubscription2 != null) {
                              _locationSubscription2.cancel();
                            }

                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ));
        }
      }
      if (onResponse is int) {
        if (onResponse == 401) {
          String lmail = await get_string_prefs("emailPref");
          String lpass = await get_string_prefs("passwordPref");
          String smail = await get_string_prefs("emailSignUpPref");
          String spass = await get_string_prefs("passwordSignUpPref");
          String lM = lmail == "" ? null : lmail;
          String sM = smail == "" ? null : smail;
          String lP = lpass == "" ? null : lpass;
          String sP = spass == "" ? null : spass;
          String loginMail = lM ?? sM;
          String loginPassword = lP ?? sP;
          if (login_flag == "social") {
            fbCheck(socialID).then((onResponse) async {
              if (onResponse is LoginModel) {
                if (onResponse.data.message == "Login Successfully") {
                  String loginDetails = json.encode(onResponse);
                  Map getToken = json.decode(loginDetails);
                  String newToken = getToken["data"]["access_token"];
                  changeVendorProcess(
                      order_ID: widget.order_id, token: newToken);
                }
              }
            });
          } else {
            loginDailyNeeds(
                password: loginPassword, email: loginMail, login_flag: "email")
              ..then((onResponse) {
                if (onResponse is LoginModel) {
                  if (onResponse.data.message == "Login Successfully") {
                    String loginDetails = json.encode(onResponse);
                    Map getToken = json.decode(loginDetails);
                    String newToken = getToken["data"]["access_token"];
                    changeVendorProcess(
                        order_ID: widget.order_id, token: newToken);
                  }
                }
              });
          }
        }
      }
    });
  }

  void tryToCancelOrder({String ord_ID, String userToken}) async {
    cancelOrder(token: userToken, orderUniqueID: ord_ID).then((onResult) async {
      if (onResult is CancelOrderModel) {
        if (onResult.statusCode == "200") {
          listenfirebasedatabase.child(widget.order_id.toString()).set({
            "Latitude": widget.userLat,
            "Longitude": widget.userLongi,
            "is_order_placed": "Y",
            "is_vendor_accepted": "C"
          });
          _locationSubscription.cancel();
          if (_locationSubscription1 != null) {
            _locationSubscription1.cancel();
          }
          if (_locationSubscription2 != null) {
            _locationSubscription2.cancel();
          }

          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => HomePage()),
              (Route<dynamic> route) => false);
        }
      }
      if (onResult is int) {
        if (onResult == 401) {
          String lmail = await get_string_prefs("emailPref");
          String lpass = await get_string_prefs("passwordPref");
          String smail = await get_string_prefs("emailSignUpPref");
          String spass = await get_string_prefs("passwordSignUpPref");
          String lM = lmail == "" ? null : lmail;
          String sM = smail == "" ? null : smail;
          String lP = lpass == "" ? null : lpass;
          String sP = spass == "" ? null : spass;
          String loginMail = lM ?? sM;
          String loginPassword = lP ?? sP;
          loginDailyNeeds(
              password: loginPassword, email: loginMail, login_flag: "email")
            ..then((onResponse) {
              if (onResponse is LoginModel) {
                if (onResponse.data.message == "Login Successfully") {
                  String loginDetails = json.encode(onResponse);
                  Map getToken = json.decode(loginDetails);
                  String newToken = getToken["data"]["access_token"];
                  tryToCancelOrder(
                      userToken: newToken, ord_ID: widget.order_id);
                }
              }
            });
        }
      }
    });
  }

  void getSomePoints() async {
    routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: LatLng(40.6782, -73.9442),
        destination: LatLng(40.6944, -73.9212),
        mode: RouteMode.driving);
  }

  Future<Uint8List> getBikeImg() async {
    ByteData byteData =
        await DefaultAssetBundle.of(context).load("images/map_bike.png");
    return byteData.buffer.asUint8List();
  }

  Future<void> changeVendorRealTimeDatabaseCheck(
      {String orderIdforDb, String latToDb, String longToDb}) async {
    listenfirebasedatabase.child(orderIdforDb).set({
      "Latitude": latToDb,
      "Longitude": longToDb,
      "is_order_placed": "Y",
      "is_vendor_accepted": "N"
    });
    _locationSubscription2 = Stream.periodic(
            Duration(seconds: 10), (_) => listenfirebasedatabase.onValue)
        .listen((sol) async {
      sol.listen((event) async {
        var acceptsnapshot = event.snapshot;
        if (acceptsnapshot.value[widget.order_id]["is_vendor_accepted"] ==
            "Y") {
          String temp = acceptsnapshot.value[widget.order_id]["lat_lng"];
          var ltlngarr = temp.split(",");
          print("lat is " + ltlngarr[0]);
          print("lng is" + ltlngarr[1]);
          double lat = double.parse(ltlngarr[0]);
          double long = double.parse(ltlngarr[1]);
          List<LatLng> temp_poly_list =
              await googleMapPolyline.getCoordinatesWithLocation(
                  origin: LatLng(double.parse(widget.userLat),
                      double.parse(widget.userLongi)),
                  destination: LatLng(lat, long),
                  mode: RouteMode.driving);
          if (_gmapController != null) {
            _gmapController.animateCamera(
                CameraUpdate.newCameraPosition(new CameraPosition(
              target: LatLng(lat, long),
              zoom: 16.0,
            )));
          }
          setState(() {
            isAccepted = true;
            vendor_from_map = LatLng(lat, long);
            circle = Circle(
              circleId: CircleId("vendor"),
              fillColor: Colors.blue,
              zIndex: 1,
              radius: 5.0,
              center: LatLng(lat, long),
            );
            polyline.add(Polyline(
                polylineId: PolylineId(customer.toString()),
                visible: true,
                points: list_for_polylines = temp_poly_list,
                width: 4,
                color: Colors.blue,
                startCap: Cap.roundCap,
                endCap: Cap.buttCap));
          });
        }
        if (acceptsnapshot.value[widget.order_id]["is_vendor_accepted"] ==
                "R" &&
            acceptsnapshot.value[widget.order_id]["is_vendor_accepted"] !=
                "Y") {
          print("vendor Rejects the service request please change vendor");
        }
      });
    });
    _locationSubscription3 = Stream.periodic(
            Duration(seconds: 10), (_) => listenfirebasedatabase.onValue)
        .interval(Duration(seconds: 180))
        .listen((result) async {
      result.listen((event) {
        var snapshot = event.snapshot;
        print(snapshot.value[widget.order_id]["is_vendor_accepted"]);
        if (snapshot.value[widget.order_id]["is_vendor_accepted"] == "N" &&
            snapshot.value[widget.order_id]["is_vendor_accepted"] != "Y") {
          print("vendor not accept request please change vendor");
        }
        if (snapshot.value[widget.order_id]["is_vendor_accepted"] == "Y") {}
      });
    });
  }

  Future<void> callNative(String vendorMobileNumber) async {
    var params = <String, dynamic>{"vendor_mob_number": vendorMobileNumber};
    try {
      String messageFromNative =
          await platform.invokeMethod("twilio_call", params);
      _eventMessage = messageFromNative;
    } on PlatformException catch (e) {
      _eventMessage = "Failed to Invoke: '${e.message}'.";
    }
    print(_eventMessage);
  }

  void recieveBanner() async {
    getAllCategoryServices().then((onResponseService) {
      if (onResponseService is GetAllCategoryServices) {
        setState(() {
          getCategoryBanners = onResponseService;
          for (var i = 0; i < getCategoryBanners.data.homeBanners.length; i++) {
            imgListBanner.add(getCategoryBanners.data.homeBanners[i].imageUrl);
          }
        });
      }
    });
  }
}
