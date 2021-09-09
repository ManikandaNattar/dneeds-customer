import 'dart:convert';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/model/Update_user_model.dart';
import 'package:daily_needs/model/User_detail_model.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:toast/toast.dart';
import '../api.dart';
import '../login_model.dart';
import 'passwordpage.dart';
import 'profilepage.dart';

class UpdateProfile extends StatefulWidget {
  String newid;
  String mobileno;

  UpdateProfile({
    this.newid,
    this.mobileno,
  }) : super();

  @override
  _UpdatePropfileState createState() => _UpdatePropfileState();
}

class _UpdatePropfileState extends State<UpdateProfile> {
  Map userdata;
  String email;
  String mobile_no;
  String first_name;
  String address;
  String state;
  String zipcode;
  String user;
  GetDetailModel getDetailModel;
  List<String> listOfStates;
  List<String> listOfCities;

  @override
  void initState() {
    super.initState();
    getdetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        centerTitle: true,
        title: Text(
          "Profile",
          style: new TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17.0),
        ),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              if (getDetailModel != null) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(
                              getDetailModel: getDetailModel,
                            )));
              }
            },
            child: Text(
              "Edit",
              style: new TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: getDetailModel == null
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "PERSONAL INFORMATION",
                          style: new TextStyle(
                              fontSize: 15.0,
                              color: primaryRedColor,
                              fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            child: Text(
                              "Name",
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                            padding: EdgeInsets.all(0.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: new Text(
                              getDetailModel.data.userDetails[0].lastName
                                      .toString()
                                      .isEmpty
                                  ? getDetailModel.data.userDetails[0].firstName
                                      .toString()
                                  : getDetailModel.data.userDetails[0].firstName
                                          .toString() +
                                      ' ${getDetailModel.data.userDetails[0].lastName.toString()}',
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Table(
                        children: [
                          TableRow(
                            children: [
                              Text(
                                "Address",
                                style: new TextStyle(
                                    fontSize: 17.0,
                                    color: textColor,
                                    fontWeight: FontWeight.w500),
                              ),
                              new Text(
                                getDetailModel.data.userDetails[0].address,
                                style: new TextStyle(
                                    fontSize: 17.0,
                                    color: textColor,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "City",
                            style: new TextStyle(
                                fontSize: 17.0,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: new Text(
                              getDetailModel.data.userDetails[0].city,
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "State",
                            style: new TextStyle(
                                fontSize: 17.0,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: new Text(
                              getDetailModel.data.userDetails[0].state,
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Pincode",
                            style: new TextStyle(
                                fontSize: 17.0,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: new Text(
                              getDetailModel.data.userDetails[0].zipcode,
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "CONTACT INFORMATION",
                          style: new TextStyle(
                              fontSize: 15.0,
                              color: primaryRedColor,
                              fontWeight: FontWeight.w300),
                        )
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Email",
                            style: new TextStyle(
                                fontSize: 17.0,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: new Text(
                              getDetailModel.data.userDetails[0].email,
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15.0,
                        horizontal: 10.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Mobile No",
                            style: new TextStyle(
                                fontSize: 17.0,
                                color: textColor,
                                fontWeight: FontWeight.w500),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: Text(
                              getDetailModel.data.userDetails[0].mobileNo !=
                                      null
                                  ? getDetailModel.data.userDetails[0].mobileNo
                                  : "",
                              style: new TextStyle(
                                  fontSize: 17.0,
                                  color: textColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          // new SizedBox(
                          //   width: 1.0,
                          // )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 10.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "PASSWORD",
                          style: new TextStyle(
                              fontSize: 15.0,
                              color: primaryRedColor,
                              fontWeight: FontWeight.w300),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  GestureDetector(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15.0,
                              horizontal: 10.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Text(
                                  "Change Password",
                                  style: new TextStyle(
                                      fontSize: 17.0,
                                      color: textColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: 150,
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
                                                ChangePass()));
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangePass(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }

  void getdetails() async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    String lt = await get_string_prefs("loginToken");
    String st = await get_string_prefs("signUpToken");
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    var citiesList = await get_stringList_pref("cities");
    var stateList = await get_stringList_pref("state");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    String userId = loginId ?? signupId;
    String logt = lt == "" ? null : lt;
    String sigt = st == "" ? null : st;
    String newtoken = logt ?? sigt;
    String userId1 = loginId ?? signupId;
    getUserDetailsbyID(token: newtoken, user_id: widget.newid)
        .then((onResponse) async {
      if (onResponse is GetDetailModel) {
        if (onResponse.data.message ==
            "User details is retrieved Successfully") {
          setState(() {
            getDetailModel = onResponse;
            user = userId1;
            listOfCities = citiesList.toList();
            listOfStates = stateList.toList();
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
