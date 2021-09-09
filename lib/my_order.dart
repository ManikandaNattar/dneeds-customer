import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';

import 'package:daily_needs/api_model_classes/cancel_order.dart';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/my_order_reusuable.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/login_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_needs/Map/show_map.dart';
import 'colors.dart';
import 'package:daily_needs/chat_screen/chat_page.dart';
import 'package:daily_needs/phone_call/phone_call_screen.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import './../utils.dart' as utils;

class MyOrder extends StatefulWidget {
  String newUserId;
  String order_id;
  String userLat;
  String userLongi;
  String vendor_chat_id;
  String phoneNo;

  MyOrder(
      {Key key,
      this.newUserId,
      this.order_id,
      this.userLat,
      this.userLongi,
      this.vendor_chat_id,
      this.phoneNo})
      : super();

  @override
  MyOrderState createState() => MyOrderState();
}

class MyOrderState extends State<MyOrder> {
  GetAllOrder allOrders;

  GetAllCategoryServices getCategoryServices;
  String user;
  bool isOrderEmpty = false;
  List<Orders> myOrders = new List();
  String errorMsg;
  Map<String, String> chatStringMap = new Map();
  String login_flag = '';
  String socialID = '';
  String user_name;
  String _eventMessage;
  static const platform = const MethodChannel("TwilioChannel");
  StreamSubscription _locationSubscription;
  StreamSubscription _locationSubscription1;
  StreamSubscription _locationSubscription2;
  Timer time;
  Map<String, String> vendorChatMap = new Map();
  bool isAccepted = false;
  bool isRejected = false;
  String changevendorName;
  String changevendorAddress;
  String changedVendorMobileNumber;
  String changedVendorChatId;
  final interval = const Duration(seconds: 1);
  int currentSeconds = 0;
  final int timerMaxSeconds = 300;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3));
    super.initState();
    checkFirebaseDatabase();
    errorMsg = "Loading...";
    getUserId();
  }

  @override
  void dispose() {
    user = null;
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    if (_locationSubscription1 != null) {
      _locationSubscription1.cancel();
    }
    if (_locationSubscription2 != null) {
      _locationSubscription2.cancel();
    }
    super.dispose();
  }

  startTimeout([int milliseconds]) {
    var duration = interval;
    time = new Timer.periodic(duration, (timer) {
      if (mounted) {
        setState(() {
          currentSeconds = timer.tick;
          if (timer.tick >= timerMaxSeconds) {
            timer.cancel();
          }
          if (isAccepted) {
            timer.cancel();
          }
        });
      }
    });
  }

  void checkFirebaseDatabase() async {
    _locationSubscription =
        listenfirebasedatabase.onValue.listen((event) async {
      var snapshotts = event.snapshot;
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "Y") {
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
          listenfirebasedatabase.child(widget.order_id.toString()).set({
            "Latitude": widget.userLat,
            "Longitude": widget.userLongi,
            "is_order_placed": "Y",
            "is_vendor_accepted": "A"
          });
          tryToChangeVendor();
          if (isAccepted == false && isRejected == false) {
            continue;
          } else {
            break;
          }
        }
      }
      if (snapshotts.value[widget.order_id]["is_vendor_accepted"] == "N") {
        while (isAccepted == false) {
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

  final listenfirebasedatabase =
      FirebaseDatabase.instance.reference().child("user");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: user == null
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text("Please login to see Order"),
                )
              ],
            )
          : allOrders == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(errorMsg),
                    )
                  ],
                )
              : _loadOrdersList(),
      /*SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: allOrders.data.orders
                          .map((eachorder) => MyOrderReusuable(
                                orders: eachorder,
                              ))
                          .toList(),
                    ),
                  )*/
    );
  }

  Widget _loadOrdersList() {
    return SingleChildScrollView(
      child: Column(children: <Widget>[
        new Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: allOrders.data.orders
                .map((eachorder) => Padding(
                      padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        elevation: 10.0,
                        shadowColor: Colors.grey[100],
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              eachorder.serviceType,
                              style: TextStyle(
                                fontSize: 20.0,
                                color: textColor,
                              ),
                            ),
                            Column(
                              children: eachorder.subServices
                                  .map((sub_orders) => Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0.0, right: 0.0),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    new SizedBox(
                                                      height: 5.0,
                                                    ),
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 5.0,
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 4.0),
                                                          child: Row(
                                                            children: <Widget>[
                                                              Container(
                                                                child: eachorder
                                                                            .issueImageUrl !=
                                                                        ""
                                                                    ? CachedNetworkImage(
                                                                        imageUrl: baseUrl +
                                                                            eachorder
                                                                                .issueImageUrl,
                                                                        width:
                                                                            70,
                                                                        height:
                                                                            70,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                        placeholder:
                                                                            (context, url) =>
                                                                                CircularProgressIndicator(),
                                                                        errorWidget: (context,
                                                                                url,
                                                                                error) =>
                                                                            Image
                                                                                .asset(
                                                                              "images/no_category.png",
                                                                              width: 70,
                                                                              height: 70,
                                                                            ))
                                                                    : Image
                                                                        .asset(
                                                                        "images/no_category.png",
                                                                        width:
                                                                            70,
                                                                        height:
                                                                            70,
                                                                      ),
                                                                height: 100.0,
                                                                width: 100.0,
                                                              ),
                                                              SizedBox(
                                                                width: 20.0,
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    sub_orders
                                                                        .subService,
                                                                    style:
                                                                        new TextStyle(
                                                                      fontSize:
                                                                          20.0,
                                                                      color:
                                                                          textColor,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 6.0,
                                                                  ),
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        "Price: ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                textColor),
                                                                      ),
                                                                      Text(
                                                                        '\u{20B9}',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                      Text(
                                                                        sub_orders
                                                                            .price,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.green),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  new SizedBox(
                                                                    height: 6.0,
                                                                  ),
                                                                  Row(
                                                                    children: <
                                                                        Widget>[
                                                                      new Text(
                                                                        "Date: ",
                                                                        style: TextStyle(
                                                                            color:
                                                                                textColor),
                                                                      ),
                                                                      Text(
                                                                        eachorder
                                                                            .serviceRequestDate,
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.grey),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        eachorder.isVendorAccepted ==
                                                                            "Y",
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        new SizedBox(
                                                                          height:
                                                                              6.0,
                                                                        ),
                                                                        Row(
                                                                          children: <
                                                                              Widget>[
                                                                            new Text(
                                                                              "Order No: ",
                                                                              style: TextStyle(color: textColor),
                                                                            ),
                                                                            Text(
                                                                              eachorder.orderNo == null ? '' : eachorder.orderNo,
                                                                              style: TextStyle(color: Colors.grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        new SizedBox(
                                                          height: 10.0,
                                                        ),
                                                      ],
                                                    ),
                                                    Divider(
                                                      color: Colors.black54,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            eachorder.isOrderCompleted == "Y"
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        top: 5.0, bottom: 5.0),
                                    child: new Text("Completed"),
                                  )
                                : eachorder.isVendorAccepted == "Y" &&
                                        eachorder.isOrderCompleted == "N"
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5.0),
                                        child: Column(
                                          children: [
                                            new Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                new InkWell(
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                              color:
                                                                  primaryRedColor)),
                                                      child: new Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  7.0),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
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
                                                            builder:
                                                                (context) =>
                                                                    ShowMap(
                                                                      initialLat:
                                                                          eachorder
                                                                              .lat,
                                                                      initialLong:
                                                                          eachorder
                                                                              .long,
                                                                      orderId:
                                                                          eachorder
                                                                              .orderId,
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
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                            color:
                                                                primaryRedColor,
                                                          )),
                                                      child: new Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  7.0),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
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
                                                    //  _callNumber(eachorder.vendorMobile);
                                                    print(1);
                                                    utils
                                                        .checkPermission(
                                                            Permission
                                                                .microphone)
                                                        .then((value) {
                                                      if (value != null) {
                                                        if (value == true) {
                                                          if (eachorder
                                                                  .vendorMobile !=
                                                              null) {
                                                            callNative(eachorder
                                                                .vendorMobile);
                                                            Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          TwilioPhoneCall(
                                                                    bookedService: eachorder
                                                                        .subServices[
                                                                            0]
                                                                        .service,
                                                                    bookedServiceMobileNmber:
                                                                        eachorder
                                                                            .vendorMobile,
                                                                  ),
                                                                ));
                                                          } else {
                                                            Toast.show(
                                                                "Unable To Call Vendor Now",
                                                                context,
                                                                duration: Toast
                                                                    .LENGTH_LONG,
                                                                gravity: Toast
                                                                    .BOTTOM);
                                                          }
                                                        }
                                                      }
                                                    });
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
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                            color:
                                                                primaryRedColor,
                                                          )),
                                                      child: new Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  7.0),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
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
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    ChatPage(
                                                                      chatId: eachorder
                                                                          .chatRoomId,
                                                                      user_name:
                                                                          user_name,
                                                                      vendor_id:
                                                                          eachorder
                                                                              .vendorId,
                                                                      user_id:
                                                                          eachorder
                                                                              .userId,
                                                                      order_id:
                                                                          eachorder
                                                                              .orderId,
                                                                      service_id:
                                                                          eachorder
                                                                              .orderId,
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
                                                                  .circular(
                                                                      5.0),
                                                          border: Border.all(
                                                            color:
                                                                primaryRedColor,
                                                          )),
                                                      child: new Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  7.0),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
                                                                new Icon(
                                                                  Icons.cancel,
                                                                  color:
                                                                      primaryRedColor,
                                                                ),
                                                                new SizedBox(
                                                                  width: 10.0,
                                                                ),
                                                                new Text(
                                                                  "Cancel",
                                                                  style: TextStyle(
                                                                      color:
                                                                          primaryRedColor),
                                                                )
                                                              ]))),
                                                  onTap: () async {
                                                    String st =
                                                        await get_string_prefs(
                                                            "signUpToken");
                                                    String lt =
                                                        await get_string_prefs(
                                                            "loginToken");
                                                    String signUpToken =
                                                        st == "" ? null : st;
                                                    String loginToken =
                                                        lt == "" ? null : lt;
                                                    tryToCancelOrder(
                                                        ord_ID:
                                                            eachorder.orderId,
                                                        token: signUpToken ??
                                                            loginToken);
                                                  },
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0, bottom: 5.0),
                                              child: Text(
                                                ' In Progress',
                                                style: TextStyle(
                                                    color: Colors.green),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5.0),
                                        child: new Text(
                                          "Submitted",
                                          style:
                                              TextStyle(color: Colors.orange),
                                        ),
                                      )
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ]),
    );
  }

  void tryToCancelOrder({String ord_ID, String token}) async {
    cancelOrder(token: token, orderUniqueID: ord_ID).then((onResult) async {
      if (onResult is CancelOrderModel) {
        if (onResult.statusCode == "200") {
          listenfirebasedatabase.child(ord_ID.toString()).set({
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
                  tryToCancelOrder(token: newToken, ord_ID: ord_ID);
                }
              }
            });
        }
      }
    });
  }

  void tryToChangeVendor() async {
    String st = await get_string_prefs("signUpToken");
    String lt = await get_string_prefs("loginToken");
    String signUpToken = st == "" ? null : st;
    String loginToken = lt == "" ? null : lt;
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

  getOrders({String userId, String token}) async {
    getAllOrderWithTrackingById(userId: userId, token: token)
        .then((onResponse) async {
      if (onResponse is GetAllOrder) {
        if (onResponse.statusCode == "100") {
          setState(() {
            errorMsg = onResponse.data.message;
          });
        }
        if (onResponse.data.message == "orders is retrieved Successfully") {
          setState(() {
            allOrders = onResponse;
          });
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
                  getOrders(userId: userId, token: newToken);
                }
              }
            });
          } else {
            loginDailyNeeds(
                    password: loginPassword,
                    email: loginMail,
                    login_flag: "mobile")
                .then((onLoginResponse) {
              if (onLoginResponse is LoginModel) {
                if (onLoginResponse.data.message == "Login Successfully") {
                  String loginDetails = json.encode(onLoginResponse);
                  Map getToken = json.decode(loginDetails);
                  String newToken = getToken["data"]["access_token"];
                  getOrders(userId: userId, token: newToken);
                }
              }
            });
          }
        }
      }
    }).catchError((onError) {
      if (onError is SocketException) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Alert"),
                  content: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomDialogue(
                        isSimpleDialogue: true,
                        message: "No network connection found",
                      )
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      splashColor: primaryColor.withOpacity(0.5),
                      child:
                          Text('RETRY', style: TextStyle(color: primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        getOrders(userId: userId, token: token);
                      },
                    ),
                  ],
                ));
      } else if (onError is TimeoutException) {
        showDialog(
            context: context,
            builder: (_) => new AlertDialog(
                  title: new Text("Alert"),
                  content: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      CustomDialogue(
                        isSimpleDialogue: true,
                        message: "Timeout",
                      )
                    ],
                  ),
                  actions: <Widget>[
                    FlatButton(
                      splashColor: primaryColor.withOpacity(0.5),
                      child:
                          Text('RETRY', style: TextStyle(color: primaryColor)),
                      onPressed: () {
                        Navigator.of(context).pop();
                        getOrders(userId: userId, token: token);
                      },
                    ),
                  ],
                ));
      }
    });
  }

  void getUserId() async {
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    login_flag = await get_string_prefs("loginFlag");
    socialID = await get_string_prefs("social_id");
    String uname = await get_string_prefs("user_name");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    if (mounted) {
      setState(() {
        user = userId;
        user_name = uname;
      });
    }

    String st = await get_string_prefs("signUpToken");
    String lt = await get_string_prefs("loginToken");
    String signUpToken = st == "" ? null : st;
    String loginToken = lt == "" ? null : lt;
    String chatIds = await get_string_prefs("vendorChatMapping");
    if (chatIds != "" && chatIds != null) {
      setState(() {});
    }
    if (userId != null) {
      getOrders(userId: userId, token: signUpToken ?? loginToken);
    }
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
  }
  // void _callNumber(mobileNo) async {
  //   String url = "tel:" + mobileNo;
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     throw 'Could not call';
  //   }
  // }
}
