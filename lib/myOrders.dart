import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:daily_needs/Notification/notipage.dart';
import 'package:daily_needs/UpdateProfile/UpdateProfile.dart';
import 'package:daily_needs/api_model_classes/cancel_order.dart';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'package:daily_needs/chat/vendor_list.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/model/Update_user_model.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/show_dailyservices.dart';
import 'package:daily_needs/user_profile.dart';
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
import 'package:android_intent/android_intent.dart';
import 'About/aboutus.dart';
import 'ContactUs/contactus.dart';
import 'FAQ/feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyOrders extends StatefulWidget {
  String newUserId;
  String order_id;
  String userLat;
  String userLongi;
  String vendor_chat_id;

  MyOrders(
      {Key key,
      this.newUserId,
      this.order_id,
      this.userLat,
      this.userLongi,
      this.vendor_chat_id})
      : super();

  @override
  MyOrdersState createState() => MyOrdersState();
}

class MyOrdersState extends State<MyOrders>
    with WidgetsBindingObserver, TickerProviderStateMixin {
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

  DateTime currentBackPressTime = DateTime.now();
  TabController tabController;
  GetDetailModel getDetailModel;
  String userId;
  bool showSearchIcon = true;
  String userName;
  String userEmail;

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3));
    super.initState();
    checkFirebaseDatabase();
    errorMsg = "Loading...";
    getUserId();
    tabController = new TabController(length: 4, vsync: this, initialIndex: 2);
    getUserDetails();
    tabController.addListener(() {});
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
            print(time.isActive);
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
          print("Vendor Accepted Status = = = NEW REJECTION ");
          //time.cancel();
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
            print("is order accepted ==== ===N");
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
                user == null
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
                UserProfile()
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
                /*new ListTile(
                    leading: Icon(
                      Icons.contacts,
                      color: primaryRedColor,
                    ),
                    title: new Text("Blog",
                        style: TextStyle(color: Colors.grey, fontSize: 15.0)),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BLogPage(title: "BLog"),
                          ));
                    },
                  ),*/
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
                      print("HHHHHHHHHHHomeLogin");
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
                                                                            // Icon(Icons.directions_car),
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
                                                                  //new Text(widget.orders.orderId)
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
                                                    if (eachorder
                                                            .vendorMobile !=
                                                        null) {
                                                      callNative(eachorder
                                                          .vendorMobile);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TwilioPhoneCall(
                                                              bookedService:
                                                                  eachorder
                                                                      .subServices[
                                                                          0]
                                                                      .service,
                                                              bookedServiceMobileNmber:
                                                                  eachorder
                                                                      .vendorMobile,
                                                            ),
                                                          ));
                                                      print(eachorder.vendorId);
                                                    } else {
                                                      Toast.show(
                                                          "Unable To Call Vendor Now",
                                                          context,
                                                          duration:
                                                              Toast.LENGTH_LONG,
                                                          gravity:
                                                              Toast.BOTTOM);
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
          listenfirebasedatabase.child(ord_ID.toString())
              //.push()
              .set({
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
                  print(
                      "changing vendor token has expired and new token has added");
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
                  print("last token has expired and new token has added");
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
                    print(
                        "changing vendor token has expired and new token has added");
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
          print(myOrders);
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
                  print("last token has expired and new token has added");
                  // getOrders(userId: userId,token: newToken);
                  // getAllOrderWithTrackingById(userId: userId, token: newToken);
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
                  print("last token has expired and new token has added");
                  // getOrders(userId: userId,token: newToken);
                  // getAllOrderWithTrackingById(userId: userId, token: newToken);
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
      setState(() {
        // chatStringMap=json.decode(chatIds);
      });
      print(chatStringMap);
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
    print(_eventMessage);
  }
}
