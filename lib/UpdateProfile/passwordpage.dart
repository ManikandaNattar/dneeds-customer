import 'dart:convert';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../api.dart';
// import 'package:toast/toast.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../login_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePass extends StatefulWidget {
  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  TextEditingController _email = new TextEditingController();
  TextEditingController _newpass = new TextEditingController();
  TextEditingController _confirpass = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryRedColor,
          centerTitle: true,
          title: Text("Change Password",
              style: new TextStyle(
                  fontSize: 17.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _form,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: new TextFormField(
                          style: TextStyle(height: 2.0),
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: new InputDecoration(
                              hintText: 'Email',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Enter Email";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: new TextFormField(
                          obscureText: true,
                          controller: _newpass,
                          style: TextStyle(height: 2.0),
                          keyboardType: TextInputType.visiblePassword,
                          decoration: new InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey)),
                              hintText: 'New Password',
                              labelStyle: TextStyle(color: Colors.grey)),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'New Password';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, right: 30.0),
                      child: Container(
                        child: new TextFormField(
                          style: TextStyle(height: 2.0),
                          obscureText: true,
                          controller: _confirpass,
                          keyboardType: TextInputType.visiblePassword,
                          decoration: new InputDecoration(
                            hintText: 'Confirm Password',
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Enter Confirmpassword';
                            }
                            if (value != _newpass.text) {
                              return 'Not Match';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      width: 310,
                      height: 40,
                      child: RaisedButton(
                        onPressed: () {
                          if (_form.currentState.validate()) {
                            Map<String, dynamic> jsonMap = new Map();
                            jsonMap["email"] = _email.text.toString();
                            jsonMap["new_password"] = _newpass.text.toString();
                            jsonMap["password"] = _confirpass.text.toString();
                            PassWord(
                              email: _email.text.toString(),
                              new_password: _newpass.text.toString(),
                              password: _confirpass.text.toString(),
                            );
                          }
                        },
                        color: primaryRedColor,
                        child: Text(
                          "Change Password",
                          style: new TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ]),
            ),
          ),
        ));
  }

  PassWord(
      {String email,
      String new_password,
      String password,
      String token}) async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    String lt = await get_string_prefs("loginToken");
    String st = await get_string_prefs("signUpToken");
    String logt = lt == "" ? null : lt;
    String sigt = st == "" ? null : st;
    String newtoken = logt ?? sigt;
    if (newtoken != null) {
      Password(
              email: _email.text.toString(),
              password: _confirpass.text.toString(),
              new_password: _newpass.text.toString(),
              token: newtoken)
          .then((onResponse) async {
        print('res$onResponse');
        if (onResponse is ChangePass) {
          print(1);
        } else {
          print(onResponse.data.message);
          _email.text = '';
          _newpass.text = '';
          _confirpass.text = '';
          Fluttertoast.showToast(
            msg: onResponse.data.message,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: primaryRedColor,
            textColor: Colors.white,
            fontSize: 16.0,
          );

          await save_string_prefs("loginuser", null);
          save_string_prefs("signupuser", null);
          save_string_prefs("loginuserId", null);
          save_string_prefs("signUpUesrId", null);
          save_string_prefs("loginToken", null);
          save_string_prefs("signUpToken", null);
          save_string_prefs("emailPref", null);
          save_string_prefs("passwordPref", null);
          save_string_prefs("emailSignUpPref", null);
          save_string_prefs("passwordSignUpPref", null);
          clearPrefs();
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (context) => new HomePage()));
        }
        if (onResponse is int) {
          print(onResponse);
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
                    Password(
                      email: _email.text.toString(),
                      new_password: _newpass.text.toString(),
                      password: _confirpass.text.toString(),
                      token: newToken,
                    );
                    print("last token has expired and new token has added");
                  }
                }
              });
            } else {
              print('cp');
              loginDailyNeeds(
                      password: loginPassword,
                      email: loginMail,
                      login_flag: "email")
                  .then((onResponse) {
                if (onResponse is LoginModel) {
                  if (onResponse.data.message == "Login Successfully") {
                    String loginDetails = json.encode(onResponse);
                    Map getToken = json.decode(loginDetails);
                    String newToken = getToken["data"]["access_token"];
                    Password(
                      email: _email.text.toString(),
                      new_password: _newpass.text.toString(),
                      password: _confirpass.text.toString(),
                      token: newToken,
                    );
                    print("last token has expired and new token has added");
                  }
                }
              });
            }
          }
        }
      });
    } else {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: new Text("User Account Empty"),
                content: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    CustomDialogue(
                      isSimpleDialogue: true,
                      message: "Please Login",
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
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
    }
  }
}

mixin SharedPreferences {}
