import 'dart:convert';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/model/query_model.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:toast/toast.dart';

import '../login_model.dart';

class Contact extends StatefulWidget {
  String userId;
  String newToken;

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  TextEditingController _query = new TextEditingController();
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        title: Text(
          "Support",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17.0),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 70.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(width: 3.0, color: Colors.black54),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Form(
                  key: _form,
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: TextFormField(
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Enter the query";
                        }
                        return null;
                      },
                      controller: _query,
                      textAlign: TextAlign.start,
                      keyboardType: TextInputType.text,
                      decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Your Query",
                      ),
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[400]),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 40.0,
          ),
          Container(
            width: 310,
            height: 60,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: primaryRedColor)),
              color: primaryRedColor,
              onPressed: () {
                _form.currentState.validate();
                if (!(_query.text.isEmpty)) {
                  Map<String, dynamic> jsonmap = new Map();
                  jsonmap["user_id"] = 6156.toString();
                  jsonmap["query"] = _query.text.toString();
                  addquery(
                    user_id: widget.userId.toString(),
                    query: _query.text.toString(),
                  );
                }
              },
              child: Text(
                "SEND",
                style: new TextStyle(color: Colors.white, fontSize: 15.0),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0, left: 20.0),
            child: Row(
              children: <Widget>[
                Padding(
                  child: new Text(
                    "For any other support issues,",
                    style: new TextStyle(
                        color: Colors.black,
                        fontSize: 17.0,
                        fontWeight: FontWeight.w600),
                  ),
                  padding: EdgeInsets.all(5.0),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  child: new Text(
                    "please contact us",
                    style: new TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 17.0),
                  ),
                  padding: EdgeInsets.all(5.0),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  void addquery({String user_id, String query}) async {
    String login_flag = await get_string_prefs("loginFlag");
    String socialID = await get_string_prefs("social_id");
    String lt = await get_string_prefs("loginToken");
    String st = await get_string_prefs("signUpToken");
    String logt = lt == "" ? null : lt;
    String sigt = st == "" ? null : st;
    String newtoken = logt ?? sigt;
    if (newtoken != null) {
      getQuery(
        user_id: 6156.toString(),
        query: _query.text.toString(),
        token: newtoken,
      ).then((onResponse) async {
        if (onResponse is Query) {
          if (onResponse.data.message == "Query is retrieved sucessfully") {}
        } else {}
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
                    getQuery(
                      user_id: widget.userId.toString(),
                      query: _query.text.toString(),
                      token: newToken,
                    );
                    print("last token has expired and new token has added");
                  }
                }
              });
            } else {
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
                    getQuery(
                      user_id: widget.userId.toString(),
                      query: _query.text.toString(),
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
