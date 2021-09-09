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

class Eg extends StatefulWidget {
  String newUserId;
  String order_id;
  String userLat;
  String userLongi;
  String vendor_chat_id;
  String phoneNo;

  Eg(
      {Key key,
        this.newUserId,
        this.order_id,
        this.userLat,
        this.userLongi,
        this.vendor_chat_id,
        this.phoneNo})
      : super();

  @override
  EgState createState() => EgState();
}

class EgState extends State<Eg> {
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
  String accessToken;

  @override
  void initState() {
   test();
  }

  void test() async {
    accessToken = await get_string_prefs("token");
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    if (userId != null) {
      getAllOrderWithTrackingById(userId: userId, token: accessToken)
          .then((value) async {
        if (value is GetAllOrder) {
          if (value.statusCode == "100") {
            setState(() {
             errorMsg = value.data.message;
            });
          }
          if (value.statusCode == "200") {
            for (var i = 0; i < value.data?.orders?.length; i++) {
              if (value.data.orders[i].isOrderCompleted == "N") {
                print(value.data.orders[i].chatRoomId);
                Navigator.push(
                    context, CupertinoPageRoute(builder: (context) => ChatPage(
                  chatId: value.data.orders[i].chatRoomId,
                  vendor_id: value.data.orders[i].vendorId,
                  user_id: value.data.orders[i].userId,
                  order_id: value.data.orders[i].id,
                  service_id: value.data.orders[i].serviceId,
                )));
              }
            }
          }
        }
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}
