import 'dart:async';

import 'package:daily_needs/add_to_cart/add_to_cart.dart';
import 'package:daily_needs/book_service.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/signup.dart';
import 'package:daily_needs/api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as JSON;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:daily_needs/login_model.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/get_user_location.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'login_model.dart';
import 'package:daily_needs/forgot_page.dart';

class Login extends StatefulWidget {
  String service_id;
  String service_issue;
  String sub_service_ids;
  String service_request_date;
  String issue_imag_url;
  List<ServiceDatas> idList;
  List<String> priceList;

  Login(
      {Key key,
      this.service_id,
      this.service_issue,
      this.sub_service_ids,
      this.service_request_date,
      this.issue_imag_url,
      this.idList,
      this.priceList})
      : super();

  @override
  LoginSetState createState() => LoginSetState();
}

class LoginSetState extends State<Login> {
  TextEditingController emailId = new TextEditingController();
  TextEditingController passwordd = new TextEditingController();
  bool _validate = false;
  bool _mvalidate = false;
  bool _evalidate = false;
  bool isLoading = false;
  bool isFbActivated = true;
  bool passwordVisible = true;
  final facebookLogin = FacebookLogin();
  GoogleSignInAccount _currentUser;
  bool iconColorEnable = false;
  bool emailIconColorEnable = false;
  Map loginUserDetails;
  String passwordForPref;
  String emailForPref;
  Map userDetails;
  String details;
  String facebookId;
  String gmailId;
  Map<String, dynamic> fblogin;
  bool isMobileLogin = false;
  final FirebaseMessaging _messaging = FirebaseMessaging();
  Map<String, dynamic> profileMap;
  Map useData;
  int userIdConstant;
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  void checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    facebookId = prefs.getString("facebookID");
    GoogleSignInAccount _currentUser;
    gmailId = prefs.get("gmailID");
    details = prefs.getString("USER_DETAILS");
    if (details != null) {
      setState(() {
        userDetails = JSON.jsonDecode(prefs.getString("USER_DETAILS"));
      });
    }
    if (prefs.getString("key") == null) {
      prefs.setString("key", "one");
    }
    await new Future.delayed(const Duration(seconds: 1));
    if (prefs.getInt("USER_ID") != null) {
      userIdConstant = prefs.getInt("USER_ID");
      useData = JSON.jsonDecode(prefs.getString("USER_DETAILS"));
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    userDetails = new Map();

    profileMap = new Map();
    fblogin = new Map();

    checkFirstSeen();
    facebookLogin.loginBehavior = FacebookLoginBehavior.webViewOnly;

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {}
    });
    _googleSignIn.signInSilently();
    if (Platform.isIOS) {}
  }

  initLogin() {
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount account) async {
      setState(() {
        _currentUser = account;
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      profileMap.clear();
      print(prefs.getString("googleID"));
      profileMap["firstName"] = account.displayName;
      profileMap["lastName"] = "  ";
      profileMap["email"] = account.email;
      profileMap["fbgoogleID"] = account.id;
      profileMap["password"] = account.id;
      gmailCheck(account.id);
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> _handleSignIn() async {
    try {
      _handleSignOut();
      initLogin();
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(color: buttonColor),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: isLoading
          ? new Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.center,
                  overflow: Overflow.visible,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 0.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 40.0, right: 40.0),
                              child: Container(
                                child: TextField(
                                  controller: emailId,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey)),
                                      prefixIcon: Icon(
                                        Icons.email,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Enter Email/Phone",
                                      counterText: "",
                                      errorText: _validate
                                          ? "Please enter valid Email Id"
                                          : _mvalidate
                                              ? "Please enter valid mobile number"
                                              : null),
                                  style: TextStyle(height: 2.0),
                                  onTap: _chooseColorEmail(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 40.0, right: 40.0),
                              child: Container(
                                child: TextField(
                                  controller: passwordd,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: passwordVisible,
                                  decoration: InputDecoration(
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.grey)),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.grey,
                                      ),
                                      hintText: "Enter Password",
                                      counterText: "",
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          passwordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            passwordVisible = !passwordVisible;
                                          });
                                        },
                                      ),
                                      errorText: _evalidate
                                          ? "Please enter password"
                                          : null),
                                  onTap: _chooseColor(),
                                  style: TextStyle(height: 2.0),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0, right: 40.0),
                              child: Container(
                                alignment: Alignment.topRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.of(context).pushReplacement(
                                        new MaterialPageRoute(
                                            builder: (context) =>
                                                new ForgotPasswordPage()));
                                  },
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                        color: primaryRedColor,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 40.0, right: 40.0),
                              child: new MaterialButton(
                                minWidth: double.infinity,
                                color: primaryRedColor,
                                textColor: Colors.white,
                                child: new Text(
                                  "Sign In",
                                  style: new TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                                onPressed: () async {
                                  setState(() {
                                    emailId.text.isEmpty
                                        ? _validate = true
                                        : _validate = false;
                                    passwordd.text.isEmpty
                                        ? _evalidate = true
                                        : _evalidate = false;
                                    bool isEmailId =
                                        validateEmail(emailId.text);
                                    if (isEmailId) {
                                      _validate = true;
                                    } else {
                                      emailId.text.length == 10
                                          ? _mvalidate = false
                                          : _mvalidate = true;
                                    }
                                  });

                                  if (!emailId.text.isEmpty &&
                                      !passwordd.text.isEmpty) {
                                    Map<String, dynamic> jsonMap = new Map();
                                    jsonMap["email"] = emailId.text;
                                    jsonMap["password"] = passwordd.text;
                                    jsonMap["login_flag"] = "email";
                                    if (!_mvalidate && !_validate) {
                                      save_string_prefs("loginFlag", "mobile");
                                      login(
                                          email: emailId.text,
                                          password: passwordd.text,
                                          login_flag: "mobile");
                                    } else {
                                      save_string_prefs("loginFlag", "email");
                                      login(
                                          email: emailId.text,
                                          password: passwordd.text,
                                          login_flag: "email");
                                    }
                                  }
                                },
                                splashColor: splashColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -15,
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              width: 1.0,
                              color: Colors.black26,
                            )),
                        child: Center(
                          child: Text(
                            "or",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(fontSize: 10.0, color: Colors.grey),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 25.0,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 40.0, right: 40.0),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        splashColor: splashColor,
                        padding: EdgeInsets.only(right: 10.0, left: 10.0),
                        textColor: Colors.black,
                        color: Colors.white,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              "images/newgoogle.png",
                              width: 25.0,
                              height: 40.0,
                            ),
                            Text(
                              "Continue with Google",
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.black54),
                            )
                          ],
                        ),
                        onPressed: () async {
                          isFbActivated = false;
                          if (gmailId != null && userDetails.length != 0) {
                            fblogin["userName"] = userDetails["mobileNumber"];
                          } else {
                            _handleSignIn();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 40.0, left: 40.0),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        splashColor: splashColor,
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset(
                              "images/fb.png",
                              width: 25.0,
                              height: 40.0,
                            ),
                            Text(
                              " Continue with Facebook",
                              style: TextStyle(fontSize: 15.0),
                            ),
                          ],
                        ),
                        textColor: Colors.black54,
                        color: Colors.white,
                        onPressed: () async {
                          setState(() {
                            isFbActivated = false;
                          });
                          try {
                            final result = await facebookLogin.logIn(['email']);
                            final token = result.accessToken.token;
                            final graphResponse = await http.get(
                                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
                            final profile = JSON.jsonDecode(graphResponse.body);
                            String fbid = profile["id"];
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            profileMap.clear();
                            prefs.setString("facebookID", fbid);
                            print(prefs.getString("facebookID"));
                            profileMap["firstName"] = profile["first_name"];
                            profileMap["lastName"] = profile["last_name"];
                            profileMap["email"] = profile["email"];
                            profileMap["facebookId"] = profile["id"];
                            profileMap["password"] = profile["id"];
                            print(profile["first_name"]);
                            print(profile["id"]);
                            fbChecker(profile["id"]);
                            facebookLogin.logOut();
                          } catch (e) {
                            facebookLogin.logOut();
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          "Don't have an account? ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                        GestureDetector(
                          child: Text(
                            'Sign Up Now',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: primaryRedColor,
                                decoration: TextDecoration.underline),
                          ),
                          onTap: () async {
                            bool homelogin =
                                await get_bool_prefs("isHomeLogin");
                            if (homelogin) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signup(
                                            isFbActivated: true,
                                          ))).then((onValue) {
                                if (onValue != null) {}
                              });
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Signup(
                                            issue_imag_url:
                                                widget.issue_imag_url,
                                            service_id: widget.service_id,
                                            service_request_date:
                                                widget.service_request_date,
                                            sub_service_ids:
                                                widget.sub_service_ids,
                                            service_issue: widget.service_issue,
                                            isFbActivated: true,
                                            idList: widget.idList,
                                            priceList: widget.priceList,
                                          )));
                            }
                          },
                        ),
                      ],
                    )
                  ],
                )
              ],
            )),
    );
  }

  bool validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return false;
    else
      return true;
  }

  Future<void> fbChecker(String Fid) async {
    await fbCheck(Fid).then((onResponse) async {
      if (onResponse is LoginModel) {
        if (onResponse.data.message == "User not Exist!") {
          isFbActivated = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Signup(
                        facebookProfile: profileMap,
                        isFbActivated: isFbActivated,
                      )));
        } else {
          print(onResponse.data.message);
          if (onResponse.data.message == "Login Successfully") {
            save_string_prefs("social_id", Fid);
            save_string_prefs("loginFlag", "social");
            save_string_prefs("passwordPref", profileMap["password"]);
            save_string_prefs("emailPref", profileMap["email"]);
            save_string_prefs("loginuser", JSON.json.encode(onResponse));
            String userDetails = await get_string_prefs("loginuser");
            loginUserDetails = JSON.json.decode(userDetails);
            String token = loginUserDetails["data"]["access_token"];
            save_string_prefs("loginToken", token);
            String loginUserName = loginUserDetails["data"]["user"][0]["email"];
            String loginUserId = loginUserDetails["data"]["user"][0]["id"];
            save_string_prefs("loginuserId", loginUserId);
            print(userDetails);
            print(loginUserName);
            getNotification();
            Navigator.pop(context);
            bool isHomeLogin = await get_bool_prefs("isHomeLogin");
            if (isHomeLogin) {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => HomePage()));
            } else {
              print("subb  service  iddd =" + widget.idList.toString());
              print("service price   iddd =" + widget.priceList.toString());
              print("service sub service   iddd =" +
                  widget.sub_service_ids.toString());
              print("service  iddd =" + widget.service_id);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddToCart(
                            priceList: widget.priceList,
                            service_id: widget.service_id,
                            service_name: widget.service_issue,
                            sub_serv_ids: widget.idList,
                          )));
            }
          }
        }
      }
    }).catchError((onError) {
      isFbActivated = false;
      print(onError);
    });
  }

  Future<void> gmailCheck(String gid) async {
    await googleCall(gid).then((onResponse) async {
      if (onResponse is LoginModel) {
        _handleSignOut();
        if (onResponse.statusCode == "200") {
          save_string_prefs("social_id", gid);
          save_string_prefs("loginFlag", "social");
          save_string_prefs("passwordPref", profileMap["password"]);
          save_string_prefs("emailPref", profileMap["email"]);
          save_string_prefs("loginuser", JSON.json.encode(onResponse));
          String userDetails = await get_string_prefs("loginuser");
          loginUserDetails = JSON.json.decode(userDetails);
          String token = loginUserDetails["data"]["access_token"];
          print(token);
          save_string_prefs("loginToken", token);
          String loginUserName = loginUserDetails["data"]["user"][0]["email"];
          String loginUserId = loginUserDetails["data"]["user"][0]["id"];
          print(loginUserId);
          save_string_prefs("loginuserId", loginUserId);
          print(userDetails);
          print(loginUserName);
          getNotification();
          Navigator.pop(context);
          bool isHomeLogin = await get_bool_prefs("isHomeLogin");
          if (isHomeLogin) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            print("subb  service  iddd =" + widget.idList.toString());
            print("service price   iddd =" + widget.priceList.toString());
            print("service sub service   iddd =" +
                widget.sub_service_ids.toString());
            print("service  iddd =" + widget.service_id);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddToCart(
                          sub_serv_ids: widget.idList,
                          service_name: widget.service_issue,
                          service_id: widget.service_id,
                          priceList: widget.priceList,
                        )));
          }
        } else {
          isFbActivated = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Signup(
                        facebookProfile: profileMap,
                        isFbActivated: isFbActivated,
                      )));
        }
      }
    }).catchError((onError) {
      isFbActivated = false;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Signup(
                    facebookProfile: profileMap,
                    isFbActivated: isFbActivated,
                  )));

      print(onError);
    });
  }

  void login({String email, String password, String login_flag}) async {
    setState(() {
      isLoading = true;
    });
    loginDailyNeeds(email: email, password: password, login_flag: login_flag)
        .then((onResponse) async {
      if (onResponse is LoginModel) {
        setState(() {
          isLoading = false;
        });
        if (onResponse.statusCode == "100") {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }

        if (onResponse.data.message == "Login Successfully") {
          save_string_prefs("passwordPref", password);
          save_string_prefs("emailPref", email);
          save_string_prefs("loginuser", JSON.json.encode(onResponse));
          String userDetails = await get_string_prefs("loginuser");
          loginUserDetails = JSON.json.decode(userDetails);
          String token = loginUserDetails["data"]["access_token"];
          print(token);
          save_string_prefs("loginToken", token);
          String loginUserName = loginUserDetails["data"]["user"][0]["email"];
          String loginUserId = loginUserDetails["data"]["user"][0]["id"];
          String loginUserNamee =
              loginUserDetails["data"]["user"][0]["first_name"];
          save_string_prefs("user_name", loginUserNamee);
          print(loginUserId);
          save_string_prefs("loginuserId", loginUserId);
          print(userDetails);
          print(loginUserName);
          getNotification();
          bool isHomeLogin = await get_bool_prefs("isHomeLogin");
          if (isHomeLogin) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            print("subb  service  iddd =" + widget.idList.toString());
            print("service price   iddd =" + widget.priceList.toString());
            print("service sub service   iddd =" +
                widget.sub_service_ids.toString());
            print("service  iddd =" + widget.service_id);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => AddToCart(
                          priceList: widget.priceList,
                          service_id: widget.service_id,
                          service_name: widget.service_issue,
                          sub_serv_ids: widget.idList,
                        )));
          }
        } else {
          Toast.show("Email id and Password do no match.", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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
                        login(
                            email: email,
                            password: password,
                            login_flag: login_flag);
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
                        login(
                            email: email,
                            password: password,
                            login_flag: login_flag);
                      },
                    ),
                  ],
                ));
      }
    });
  }

  _chooseColor() {
    setState(() {
      iconColorEnable = true;
    });
  }

  _chooseColorEmail() {
    setState(() {
      emailIconColorEnable = true;
    });
  }

  void getNotification() {
    String loginUserId = loginUserDetails["data"]["user"][0]["id"];
    String newtoken = loginUserDetails["data"]["access_token"];

    _messaging.getToken().then((token) {
      print(token);
      if (token != null) {
        pushNotification(
            device_token: token.toString(),
            imei_no: token.toString(),
            user_id: loginUserId,
            token: newtoken);
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
                        getNotification();
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
                        getNotification();
                      },
                    ),
                  ],
                ));
      }
    });
  }
}
