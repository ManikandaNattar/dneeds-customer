import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_intent/android_intent.dart';
import 'package:daily_needs/Notification/notipage.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/chat/vendor_list.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/my_order.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/searchbar/serach_page.dart';
import 'package:daily_needs/show_dailyservices.dart';
import 'package:daily_needs/user_profile.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

import './colors.dart';
import './login_model.dart';
import 'About/aboutus.dart';
import 'ContactUs/contactus.dart';
import 'FAQ/feedback.dart';
import 'UpdateProfile/UpdateProfile.dart';
import 'login_model.dart';
import 'model/Update_user_model.dart';

//import 'package:flutter_twilio_voice/flutter_twilio_voice.dart';

class HomePage extends StatefulWidget {
  String user_Id;

  HomePage({
    this.user_Id,
  }) : super();

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TabController tabController;
  TextEditingController searchController;
  String userId;
  String userName;
  String userEmail;
  GetAllOrder allOrders;
  String errorMsg;
  List<Orders> alOrders = [];
  bool showSearchIcon = true;
  GetDetailModel getDetailModel;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  String _platformVersion = 'Unknown';
  DateTime currentBackPressTime = DateTime.now();
  String accessToken;
  // Timer getDataTimer;

  @override
  void initState() {
    super.initState();
    save_bool_prefs("isHomeLogin", false);
    tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
    getUserDetails();
    getnotifications();
    // getDataTimer = Timer.periodic(Duration(seconds: 30), (timer) async {

    // });
    test();
    tabController.addListener(() {
      // print(tabController.index);
      // getUserDetails();
    });
  }

  @override
  void dispose() {
    // getDataTimer.cancel();
    super.dispose();
  }

  final listenfirebasedatabase =
      FirebaseDatabase.instance.reference().child("user");

  void test() async {
    accessToken = await get_string_prefs("token");
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
            if (value.data.orders.length >= 1) {
              for (var i = 0; i < value.data?.orders?.length; i++) {
                if (value.data.orders[i].isOrderCompleted == "Y") {
                  alOrders.add(value.data.orders[i]);
                }
              }
              checkFirebaseDatabase(alOrders);
            }
          }
        }
      });
    }
  }

  void checkFirebaseDatabase(alOrders) async {
    for (var i = 0; i < alOrders.length; i++) {
      listenfirebasedatabase.onValue.listen((event) async {
        var fullOrder = alOrders[i].id;
        var snapshotts = event.snapshot;
        if (snapshotts.value[fullOrder.toString()]["shownPopup"] == "0") {
          final temp = listenfirebasedatabase
              .child(snapshotts.value[fullOrder.toString()]["order_id"]);
          temp.child("shownPopup").set("1");
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
                          message: "Order completed",
                        )
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
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
                    ],
                  ));
        } else {
          print('out');
          // getDataTimer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: onWillPop,
        child: Theme(
          data: ThemeData(
              primaryIconTheme: IconThemeData(color: Colors.white),
              fontFamily: 'VAG'),
          child: Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    "DNeeds",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0),
                  ),
                  new Text(
                    "A friend in need",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0),
                  ),
                ],
              ),
              centerTitle: false,
              backgroundColor: primaryRedColor,
              actions: <Widget>[
                Visibility(
                  visible: showSearchIcon,
                  child: new IconButton(
                      icon: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchBarService()));
                      }),
                ),
                IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Noti()));
                  },
                ),
              ],
            ),
            drawer: drawer(),
            bottomNavigationBar: bottomMenu(),
            body: TabBarView(
              controller: tabController,
              children: <Widget>[
                ShowDailyServices(),
                VendorListPage(
                  newUserId: userId,
                ),
                MyOrder(
                  newUserId: userId,
                ),
                UserProfile(),
              ],
            ),
          ),
        ));
  }

  Widget drawer() {
    return new Drawer(
      child: new Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: MediaQuery.of(context).size.width / 1.3,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(children: <Widget>[
                userId != null
                    ? new UserAccountsDrawerHeader(
                        accountName: new Text(getDetailModel == null
                            ? ""
                            : getDetailModel.data.userDetails[0].firstName),
                        accountEmail: new Text(getDetailModel == null
                            ? ""
                            : getDetailModel.data.userDetails[0].email),
                        decoration: BoxDecoration(
                          color: primaryRedColor,
                        ),
                        onDetailsPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateProfile(
                                        newid: userId,
                                      )));
                        },
                        arrowColor: Colors.white,
                      )
                    : new Container(
                        width: MediaQuery.of(context).size.width,
                        //height: 50.0,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        margin: EdgeInsets.symmetric(vertical: 0.0),
                        color: primaryRedColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 50.0,
                            ),
                            Text(
                              "DNeeds",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                new ListTile(
                  leading: Icon(
                    Icons.star_border,
                    color: primaryRedColor,
                  ),
                  title: new Text(
                    "Rating",
                    style: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                  onTap: () {
                    if (Platform.isAndroid) {
                      AndroidIntent intent = AndroidIntent(
                          action: "action_view",
                          data:
                              "https://play.google.com/store/apps/details?id=com.dailyneeds.dneeds");
                      intent.launch();
                    }
                  },
                ),
                new ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    color: primaryRedColor,
                  ),
                  title: new Text(
                    "About Us",
                    style: TextStyle(color: Colors.grey, fontSize: 15.0),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => About()));
                  },
                ),
                new ListTile(
                  leading: Icon(
                    Icons.contact_phone,
                    color: primaryRedColor,
                  ),
                  title: new Text("Contact Us",
                      style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Contact()));
                  },
                ),
                new ListTile(
                  leading: Icon(
                    Icons.feedback,
                    color: primaryRedColor,
                  ),
                  title: new Text(
                    "FAQ",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15.0,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Faq(),
                        ));
                  },
                ),
                new ListTile(
                  leading: userId != null
                      ? Icon(
                          Icons.exit_to_app,
                          color: primaryRedColor,
                        )
                      : Icon(
                          Icons.account_circle,
                          color: primaryRedColor,
                        ),
                  title: userId != null
                      ? new Text("Logout",
                          style: TextStyle(color: Colors.grey, fontSize: 15.0))
                      : new Text("Login",
                          style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                  onTap: () async {
                    Navigator.pop(context);
                    if (userId != null) {
                      showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                title: new Text("Logout"),
                                content: new Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CustomDialogue(
                                      isSimpleDialogue: true,
                                      message:
                                          "Are you sure you want to logout ?",
                                    )
                                  ],
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    splashColor: primaryColor.withOpacity(0.5),
                                    child: Text(
                                      'CANCEL',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  FlatButton(
                                    splashColor: primaryColor.withOpacity(0.5),
                                    child: Text(
                                      'OK',
                                      style: TextStyle(color: primaryColor),
                                    ),
                                    onPressed: () async {
                                      userId = null;
                                      SharedPreferences sharedPreferences =
                                          await SharedPreferences.getInstance();
                                      String log = await save_string_prefs(
                                          "loginuser", null);
                                      save_string_prefs("signupuser", null);
                                      save_string_prefs("loginuserId", null);
                                      save_string_prefs("signUpUesrId", null);
                                      save_string_prefs("loginToken", null);
                                      save_string_prefs("signUpToken", null);
                                      save_string_prefs("emailPref", null);
                                      save_string_prefs("passwordPref", null);
                                      save_string_prefs(
                                          "emailSignUpPref", null);
                                      save_string_prefs(
                                          "passwordSignUpPref", null);
                                      clearPrefs();
                                      Navigator.of(context).pop();
                                      Navigator.of(context).pushReplacement(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  new HomePage()));
                                    },
                                  ),
                                ],
                              ));
                    } else {
                      save_bool_prefs("isHomeLogin", true);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Login()));
                    }
                  },
                ),
              ]),
            ),
            Container(
                child: Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: new Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          new GestureDetector(
                            child: Image.asset(
                              'images/facebook.png',
                              color: primaryRedColor,
                              scale: 15,
                            ),
                            onTap: () {
                              if (Platform.isAndroid) {
                                AndroidIntent intent = AndroidIntent(
                                    action: "action_view",
                                    data: "https://www.facebook.com/dneedsIND");
                                intent.launch();
                              }
                            },
                          ),
                          new GestureDetector(
                            child: Image.asset(
                              'images/Twitter.png',
                              color: primaryRedColor,
                              scale: 15,
                            ),
                            onTap: () {
                              if (Platform.isAndroid) {
                                AndroidIntent intent = AndroidIntent(
                                    action: "action_view",
                                    data: "https://twitter.com/DNeedsIND");
                                intent.launch();
                              }
                            },
                          ),
                          new GestureDetector(
                            child: Image.asset(
                              'images/Instagram.png',
                              color: primaryRedColor,
                              scale: 15,
                            ),
                            onTap: () {
                              if (Platform.isAndroid) {
                                AndroidIntent intent = AndroidIntent(
                                    action: "action_view",
                                    data:
                                        "https://www.instagram.com/dneedsind/");
                                intent.launch();
                              }
                            },
                          ),
                        ],
                      ),
                    ))),
          ],
        ),
      ),
    );
  }

  Widget bottomMenu() {
    return Stack(
      alignment: Alignment.center,
      overflow: Overflow.visible,
      children: <Widget>[
        Container(
          height: 40.0,
          color: Colors.white,
          child: TabBar(
            controller: tabController,
            labelColor: primaryRedColor,
            unselectedLabelColor: Colors.black54,
            indicatorSize: TabBarIndicatorSize.tab,
            onTap: _tabTab,
            //indicatorPadding: EdgeInsets.all(5.0),
            indicatorColor: primaryRedColor,
            labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
            tabs: [
              Tab(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.home,
                    // size: 30.0,
                  ),
                  Text(
                    "Home",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              Tab(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.chat,
                    // size: 30.0,
                  ),
                  Text(
                    "Chat",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              Tab(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.pin_drop,
                    // size: 35.0,
                  ),
                  Text(
                    "My Orders",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
              Tab(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(Icons.person_pin),
                  Text(
                    "Profile",
                    style:
                        TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }

  void getUserDetails() async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    print("is the flag " + login_flag);
    if (login_flag == null || login_flag == "") {
      login_flag = "email";
    }
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String newtoken = loginId ?? signupId;
    String ulogemai = await get_string_prefs("emailPref");
    String usignupemai = await get_string_prefs("emailSignUpPref");
    String loginMailID = ulogemai == "" ? null : ulogemai;
    String signUpMailId = usignupemai == "" ? null : usignupemai;
    String userEmailID = loginMailID ?? signUpMailId;
    String uname = await get_string_prefs("user_name");
    setState(() {
      userEmail = userEmailID;
      userName = uname;
    });
    bool viaMobile = await get_bool_prefs("isViaMobileWay");
    print("via mobile" + viaMobile.toString());
    //String newtoken = loginToken ?? signUpToken
    userId = newtoken;
    if (userId != null) {
      getUserDetailsbyID(token: newtoken, user_id: userId)
          .then((onResponse) async {
        if (onResponse is GetDetailModel) {
          if (onResponse.data.message ==
              "User details is retrieved Successfully") {
            setState(() {
              getDetailModel = onResponse;
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
                    String newTokenagain = getToken["data"]["access_token"];
                    save_string_prefs("token", newTokenagain);
                    getUserDetailsbyID(token: newTokenagain, user_id: userId)
                        .then((onResponseValue) {
                      if (onResponseValue is GetDetailModel) {
                        if (onResponseValue.data.message ==
                            "User details is retrieved Successfully") {
                          setState(() {
                            getDetailModel = onResponseValue;
                            save_string_prefs("user_name",
                                getDetailModel.data.userDetails[0].firstName);
                            save_string_prefs(
                                "userCancelledOrder",
                                getDetailModel
                                    .data.userDetails[0].userCancelCount);
                          });
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
                                      splashColor:
                                          primaryColor.withOpacity(0.5),
                                      child: Text('RETRY',
                                          style:
                                              TextStyle(color: primaryColor)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        getUserDetails();
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
                                      splashColor:
                                          primaryColor.withOpacity(0.5),
                                      child: Text('RETRY',
                                          style:
                                              TextStyle(color: primaryColor)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        getUserDetails();
                                      },
                                    ),
                                  ],
                                ));
                      }
                    });
                    ;
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
                    getUserDetailsbyID(token: newTokenagain, user_id: userId)
                        .then((onResponseValue) {
                      if (onResponseValue is GetDetailModel) {
                        if (onResponseValue.data.message ==
                            "User details is retrieved Successfully") {
                          setState(() {
                            getDetailModel = onResponseValue;
                            save_string_prefs("user_name",
                                getDetailModel.data.userDetails[0].firstName);
                            save_string_prefs(
                                "userCancelledOrder",
                                getDetailModel
                                    .data.userDetails[0].userCancelCount);
                          });
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
                                      splashColor:
                                          primaryColor.withOpacity(0.5),
                                      child: Text('RETRY',
                                          style:
                                              TextStyle(color: primaryColor)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        getUserDetails();
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
                                      splashColor:
                                          primaryColor.withOpacity(0.5),
                                      child: Text('RETRY',
                                          style:
                                              TextStyle(color: primaryColor)),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        getUserDetails();
                                      },
                                    ),
                                  ],
                                ));
                      }
                    });
                    ;
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
                          getUserDetails();
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
                          getUserDetails();
                        },
                      ),
                    ],
                  ));
        }
      });
    }
  }

  void getnotifications() {
    _messaging.getToken().then((token) {
      print(token);
    });
  }

  Future<bool> onWillPop() async {
    DateTime now = DateTime.now();
    if (now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Toast.show("Again Tab to exit", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return Future.value(false);
    }
    exit(0);
    return Future.value(true);
  }

  void _tabTab(int value) {
    if (value != 0) {
      setState(() {
        showSearchIcon = false;
      });
    } else {
      setState(() {
        showSearchIcon = true;
      });
      getUserDetails();
    }
  }
}
