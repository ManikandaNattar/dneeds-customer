import 'dart:convert';

import 'package:daily_needs/api.dart';
import 'package:daily_needs/chat_screen/chat_page.dart';
import 'package:daily_needs/constants.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/myOrders.dart';
import 'package:daily_needs/my_order.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/intropage.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:flutter/material.dart';

void main() {
  // Crashlytics.instance.enableInDevMode = true;
  // FlutterError.onError = Crashlytics.instance.recordFlutterError;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Daily Needs',
        theme: ThemeData(
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'VAG'),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  String chatId;

  MyHomePage({
    this.chatId,
  }) : super();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String user;
  bool isLoading;
  String phoneNumber;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String accessToken;
  String userId;
  String user_name;

  @override
  void initState() {
    super.initState();
    isLoading = true;
    checkUser();
    FirebaseMessaging.onMessage.listen((message) async {
      print(message);
      String jsonAuthorStr = message.data['view_id'];
      Map<String, dynamic> temp = json.decode(jsonAuthorStr);
      user_name = await get_string_prefs("user_name");
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatPage(
                    chatId: temp['chatID'],
                    service_id: temp['order_id'],
                    user_name: user_name,
                    order_id: temp['order_id'],
                    user_id: temp['user_id'],
                    vendor_id: temp['from_user_id'],
                  )));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      String jsonAuthorStr = message.data['view_id'];
      Map<String, dynamic> temp = json.decode(jsonAuthorStr);
      user_name = await get_string_prefs("user_name");
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatPage(
                    chatId: temp['chatID'],
                    service_id: temp['order_id'],
                    user_name: user_name,
                    order_id: temp['order_id'],
                    user_id: temp['user_id'],
                    vendor_id: temp['from_user_id'],
                  )));
    });
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) async {
      print('getInitialMessage data: ${message.data}');
      String jsonAuthorStr = message.data['view_id'];
      Map<String, dynamic> temp = json.decode(jsonAuthorStr);
      user_name = await get_string_prefs("user_name");
      Navigator.push(
          context,
          CupertinoPageRoute(
              builder: (context) => ChatPage(
                    chatId: temp['chatID'],
                    service_id: temp['order_id'],
                    user_name: user_name,
                    order_id: temp['order_id'],
                    user_id: temp['user_id'],
                    vendor_id: temp['from_user_id'],
                  )));
    });
    // _firebaseMessaging.configure(
    //   onMessage: (Map<String, dynamic> message) async {
    //     print(message);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print(message);
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print(message);
    //     String jsonAuthorStr = message['data']['view_id'];
    //     Map<String, dynamic> temp = json.decode(jsonAuthorStr);
    //     user_name = await get_string_prefs("user_name");
    //     Navigator.push(
    //         context,
    //         CupertinoPageRoute(
    //             builder: (context) => ChatPage(
    //                   chatId: temp['chatID'],
    //                   service_id: temp['order_id'],
    //                   user_name: user_name,
    //                   order_id: temp['order_id'],
    //                   user_id: temp['user_id'],
    //                   vendor_id: temp['from_user_id'],
    //                 )));
    //   },
    // );
  }

  @override
  void dispose() {
    user = null;
    super.dispose();
  }

  void checkUser() async {
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    String phone = await get_string_prefs("mobile");
    String phoneNo = phone == "" ? null : phone.toString();
    setState(() {
      user = userId;
      isLoading = false;
      phoneNumber = phoneNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: Text("Loading..."),
            )
          : user != null || phoneNumber != null
              ? HomePage(
                  user_Id: user,
                )
              : Intro(),
    );
  }
}

/*import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';



void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

// App states
class _MyAppState extends State<MyApp> {
  bool _joined = false;
  int _remoteUid = null;
  bool _switch = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Initialize the app
  Future<void> initPlatformState() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );

    // Create RTC client instance
    RtcEngineConfig config = RtcEngineConfig(APP_ID);
    var engine = await RtcEngine.createWithConfig(config);
    // Define event handling
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print('joinChannelSuccess ${channel} ${uid}');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = null;
      });
    }));
    // Enable video
    await engine.enableAudio();
    // Join channel 123
    await engine.joinChannel(Token, 'DNeeds', null, 0);
  }


  // Create UI with local view and remote view
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter example app'),
        ),
        body: Stack(
          children: [
            Center(
              child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _switch = !_switch;
                    });
                  },
                  child: Center(
                    child:
                    _switch ? _renderLocalPreview() : _renderRemoteVideo(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generate local preview
  Widget _renderLocalPreview() {
    if (_joined) {
      return RtcLocalView.SurfaceView();
    } else {
      return Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Generate remote preview
  Widget _renderRemoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(uid: _remoteUid);
    } else {
      return Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }
}*/

// import 'package:flutter/material.dart';
//
// import './Agora/index.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: IndexPage(),
//     );
//   }
// }
