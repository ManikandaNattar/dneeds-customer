import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:daily_needs/constants.dart';
import 'package:daily_needs/model/faq_model.dart';
import 'package:daily_needs/model/faq_model.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import '../api.dart';
import '../colors.dart';
import '../login_model.dart';
import 'package:toast/toast.dart';

class Faq extends StatefulWidget {
  @override
  _FaqState createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  List<FAQModel> faqModel = [];
  FAQ faq;
  FAQModel faqmodel;
  bool isExpand = false;

  @override
  void initState() {
    addFaq();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryRedColor,
          title: Text(
            "FAQ",
            style: new TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.w900),
          ),
          centerTitle: true,
        ),
        body: faqmodel == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: faqmodel.data.fAQ
                    .map((eachfaq) => Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 10.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding:
                                    new EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 2.0,
                                      spreadRadius: 2.0,
                                      offset: Offset(2.0, 2.0),
                                    )
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    GestureDetector(
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: new Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  new Text(
                                                    eachfaq.category,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 20.0,
                                                    ),
                                                  ),
                                                  new SizedBox(
                                                    height: 5.0,
                                                  ),
                                                  new Text(
                                                    eachfaq.faqQue,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15.0,
                                                    ),
                                                  ),
                                                  new SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  ExpansionTile(
                                                    title: Text(''),
                                                    children: <Widget>[
                                                      Container(
                                                          child: new Text(
                                                        eachfaq.faqAns,
                                                        style: TextStyle(
                                                            color:
                                                                Colors.black54),
                                                      )),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ))
                    .toList(),
              )));
  }

  void addFaq() async {
    String lt = await get_string_prefs("loginToken");
    String st = await get_string_prefs("signUpToken");
    String socialID = await get_string_prefs("social_id");
    String login_flag = await get_string_prefs("loginFlag");
    String logt = lt == "" ? null : lt;
    String sigt = st == "" ? null : st;
    String newtoken = logt ?? sigt;
    if (newtoken != null) {
      getFaq(
        token: newtoken,
      ).then((onResponse) async {
        if (onResponse is FAQModel) {
          if (onResponse.data.message == "FAQ is retrieved sucessfully") {
            setState(() {
              faqmodel = onResponse;
            });
          }
        } else {
          Toast.show(onResponse, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                    getFaq(
                      token: newToken,
                    );
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
                    getFaq(
                      token: newToken,
                    );
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
