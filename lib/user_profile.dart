import 'dart:convert';
import 'dart:io';
import 'package:daily_needs/UpdateProfile/RateUs.dart';
import 'package:daily_needs/colors.dart';

import 'About/aboutus.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'PrivacyPolicy/privacy_policy.dart';
import 'ContactUs/contactus.dart';

import 'package:daily_needs/Language/modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Notification/notipage.dart';
import 'UpdateProfile/UpdateProfile.dart';
import 'package:toast/toast.dart';
import 'api.dart';
import 'login_model.dart';
import 'model/Update_user_model.dart';
import 'model/User_detail_model.dart';
import 'package:android_intent/android_intent.dart';

class UserProfile extends StatefulWidget {
  String userId;

  UserProfile({this.userId}) : super();

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  UpdatedDetails updatedDetails;
  String phoneNumber = '';

  Modal modal = new Modal();
  UserDetail userDetail;
  Map signUpUserAddress;
  Map loginUserAddress;
  String user;
  GetDetailModel getDetailModel;

  @override
  void initState() {
    super.initState();
    getUserId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: user == null
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text("Please login to see Profile"),
                )
              ],
            )
          : getDetailModel == null
              ? new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Divider(
                        height: 0.5,
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: new Container(
                                              height: 40.0,
                                              width: 40.0,
                                              padding: EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: primaryRedColor),
                                              child: new Center(
                                                child: Text(
                                                  getDetailModel
                                                      .data
                                                      .userDetails[0]
                                                      .firstName[0]
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20.0),
                                                ),
                                              ),
                                            )),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              getDetailModel.data.userDetails[0]
                                                  .firstName,
                                              style: TextStyle(
                                                fontSize: 15.0,
                                                color: textColor,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              getDetailModel
                                                  .data.userDetails[0].email,
                                              style: TextStyle(
                                                  fontSize: 12.0,
                                                  color: textColor),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: textColor,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    UpdateProfile(
                                                      newid: user,
                                                    )));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => UpdateProfile(
                                        newid: user,
                                      )));
                        },
                      ),
                      Divider(
                        height: 2.0,
                      ),
                      SizedBox(
                        height: 60.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 40.0, left: 8.0),
                              child: Text(
                                "PREFERENCES",
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15.0,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      Divider(
                        height: 2.0,
                      ),
                      GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Noti()));
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  decoration:
                                      BoxDecoration(color: Colors.white),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Notifications",
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: textColor),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.arrow_forward_ios,
                                          color: textColor,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Noti()));
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      Divider(
                        height: 1.0,
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Language",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: textColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "English",
                                          style: TextStyle(
                                              fontSize: 15.0, color: textColor),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.arrow_forward_ios,
                                            color: textColor,
                                          ),
                                          onPressed: () {
                                            modal.mainBottomSheet(context);
                                          },
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          modal.mainBottomSheet(context);
                        },
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      SizedBox(
                        height: 30.0,
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => About()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "About",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: textColor,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => About()));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Privacy Policy",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: textColor,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Privacy()));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Privacy()));
                        },
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Rate us on Play Store",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: textColor,
                                      ),
                                      onPressed: () {
                                        if (Platform.isAndroid) {
                                          AndroidIntent intent = AndroidIntent(
                                              action: "action_view",
                                              data:
                                                  "https://play.google.com/store/apps/details?id=com.dailyneeds.dneeds");
                                          intent.launch();
                                        }
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                      Divider(
                        height: 1.0,
                      ),
                      GestureDetector(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5.0, bottom: 5.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(color: Colors.white),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        "Contact & Support",
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: textColor),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.arrow_forward_ios,
                                        color: textColor,
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Contact()));
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Contact()));
                        },
                      ),
                      Divider(
                        height: 1.0,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                ),
    );
  }

  void getUserId() async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    if (login_flag == null) {
      login_flag = "email";
    }
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    setState(() {
      user = userId;
    });
    String st = await get_string_prefs("signUpToken");
    String lt = await get_string_prefs("loginToken");
    String signUpToken = st == "" ? null : st;
    String loginToken = lt == "" ? null : lt;
    String newtoken = loginToken ?? signUpToken;
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
                    getUserDetailsbyID(token: newTokenagain, user_id: userId)
                        .then((onResponseValue) {
                      if (onResponseValue is GetDetailModel) {
                        if (onResponseValue.data.message ==
                            "User details is retrieved Successfully") {
                          setState(() {
                            getDetailModel = onResponseValue;
                          });
                        }
                      }
                    });
                  }
                }
              });
            } else {
              loginDailyNeeds(
                      login_flag: "email",
                      email: loginMail,
                      password: loginPassword)
                  .then((onResponse) {
                if (onResponse is LoginModel) {
                  if (onResponse.data.message == "Login Successfully") {
                    String loginDetails = json.encode(onResponse);
                    Map getToken = json.decode(loginDetails);
                    String newTokenagain = getToken["data"]["access_token"];
                    getUserDetailsbyID(token: newTokenagain, user_id: userId)
                        .then((onResponseValue) {
                      if (onResponseValue is GetDetailModel) {
                        if (onResponseValue.data.message ==
                            "User details is retrieved Successfully") {
                          setState(() {
                            getDetailModel = onResponseValue;
                          });
                        }
                      }
                    });
                  }
                }
              });
            }
          }
        }
      });
    }
  }
}
