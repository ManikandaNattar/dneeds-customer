import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:daily_needs/chat_screen/chat_page.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/save_storage/save_storage.dart';

import '../colors.dart';
import '../login_model.dart';

class VendorListPage extends StatefulWidget {
  String newUserId;

  VendorListPage({Key key, this.newUserId}) : super();

  @override
  _VendorListPageState createState() => _VendorListPageState();
}

class _VendorListPageState extends State<VendorListPage> {
  GetAllOrder allOrders;
  List<Orders> alOrders = [];
  GetAllCategoryServices getCategoryServices;
  String accessToken;
  String user;
  String user_name;
  String errorMsg;

  @override
  void initState() {
    super.initState();
    errorMsg = "Loading...";
    alOrders = [];
    getVendorList();
  }

  @override
  void dispose() {
    user = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: user != null && allOrders == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text(errorMsg),
                  )
                ],
              )
            : user == null
                ? new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text("Please Book Service To Chat With Vendor"),
                      )
                    ],
                  )
                : alOrders.length == 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Text("There is no accepted orders"),
                          )
                        ],
                      )
                    : Scrollbar(
                        child: ListView.separated(
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.black,
                          ),
                          itemCount: alOrders.length,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(alOrders[index].subServices.length == 0
                                ? ""
                                : alOrders[index].subServices[0].service),
                            subtitle: Text(changeDateTimeFormat(
                                alOrders[index].createdDatetime)),
                            onTap: () => {
                              print(
                                  'isVendorAcc:${alOrders[index].isVendorAccepted} : ${alOrders.length}'),
                              if (alOrders[index].isVendorAccepted == "Y")
                                {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ChatPage(
                                                chatId:
                                                    alOrders[index].chatRoomId,
                                                user_name: user_name,
                                                order_id:
                                                    alOrders[index].orderId,
                                                user_id: alOrders[index].userId,
                                                vendor_id:
                                                    alOrders[index].vendorId,
                                                service_id:
                                                    alOrders[index].orderId,
                                              )))
                                }
                            },
                            trailing: Icon(Icons.chat),
                          ),
                        ),
                      ));
  }

  String changeDateTimeFormat(String createdDatetime) {
    DateTime tempDate =
        new DateFormat("yyyy-MM-dd h:mm").parse(createdDatetime);
    String date = DateFormat("E, d MMM yyyy h:mm a").format(tempDate);
    return date;
  }

  getVendorList() async {
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    user_name = await get_string_prefs("user_name");
    if (mounted) {
      setState(() {
        user = userId;
      });
    }

    accessToken = await get_string_prefs("token");
    if (user != null) {
      getAllOrderWithTrackingById(userId: userId, token: accessToken)
          .then((onResponse) async {
        if (onResponse is GetAllOrder) {
          if (onResponse.statusCode == "100") {
            setState(() {
              errorMsg = onResponse.data.message;
            });
          }
          if (onResponse.statusCode == "200") {
            setState(() {
              allOrders = onResponse;
              for (var i = 0; i < allOrders.data.orders.length; i++) {
                if ((allOrders.data.orders[i].isVendorAccepted == "Y") &&
                    (allOrders.data.orders[i].isOrderCompleted == "N")) {
                  alOrders.add(onResponse.data.orders[i]);
                }
              }
            });
          }
          if (onResponse.statusCode == 401) {
            String login_flag = await get_string_prefs("loginFlag");
            String socialID = await get_string_prefs("social_id");
            print("is the flag " + login_flag);
            if (login_flag == null || login_flag == "") {
              login_flag = "email";
            }
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
                if (onResponse is GetAllOrder) {
                  if (onResponse.data.message == "Login Successfully") {
                    String loginDetails = json.encode(onResponse);
                    Map getToken = json.decode(loginDetails);
                    String newTokenagain = getToken["data"]["access_token"];
                    save_string_prefs("token", newTokenagain);
                    getAllOrderWithTrackingById(
                            userId: userId, token: newTokenagain)
                        .then((onOrderResponse) async {
                      if (onOrderResponse.statusCode == "100") {
                        setState(() {
                          errorMsg = onResponse.data.message;
                        });
                      }
                      if (onOrderResponse.statusCode == "200") {
                        setState(() {
                          allOrders = onOrderResponse;
                          for (var i = 0;
                              i < allOrders.data.orders.length;
                              i++) {
                            if ((allOrders.data.orders[i].isVendorAccepted ==
                                    "Y") &&
                                (allOrders.data.orders[i].isOrderCompleted ==
                                    "N")) {
                              alOrders.add(onOrderResponse.data.orders[i]);
                            }
                          }
                        });
                      }
                    });
                  }
                }
              });
            } else {
              loginDailyNeeds(
                      login_flag: login_flag,
                      email: loginMail,
                      password: loginPassword)
                  .then((onResponse) {
                if (onResponse is LoginModel) {
                  if (onResponse.data.message == "Login Successfully") {
                    String loginDetails = json.encode(onResponse);
                    Map getToken = json.decode(loginDetails);
                    String newTokenagain = getToken["data"]["access_token"];
                    save_string_prefs("token", newTokenagain);
                    getAllOrderWithTrackingById(
                            userId: userId, token: newTokenagain)
                        .then((onOrderResponseForEmailFlag) async {
                      if (onOrderResponseForEmailFlag.statusCode == "100") {
                        setState(() {
                          errorMsg = onResponse.data.message;
                        });
                      }
                      if (onOrderResponseForEmailFlag.statusCode == "200") {
                        setState(() {
                          allOrders = onOrderResponseForEmailFlag;
                          for (var i = 0;
                              i < allOrders.data.orders.length;
                              i++) {
                            if ((allOrders.data.orders[i].isVendorAccepted ==
                                    "Y") &&
                                (allOrders.data.orders[i].isOrderCompleted ==
                                    "N")) {
                              alOrders.add(
                                  onOrderResponseForEmailFlag.data.orders[i]);
                            }
                          }
                        });
                      }
                    });
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
                        child: Text('RETRY',
                            style: TextStyle(color: primaryColor)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          getVendorList();
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
                        child: Text('RETRY',
                            style: TextStyle(color: primaryColor)),
                        onPressed: () {
                          Navigator.of(context).pop();
                          getVendorList();
                        },
                      ),
                    ],
                  ));
        }
      });
    }
  }
}
