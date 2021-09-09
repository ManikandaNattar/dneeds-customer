import 'dart:async';
import 'dart:convert';
import 'package:daily_needs/add_to_cart/add_to_cart.dart';
import 'package:daily_needs/book_service.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/signup.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/services.dart';
import '../signup_model.dart';
import 'package:toast/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class Otp extends StatefulWidget {
  String firstname;
  String lastname;
  String mobleNumber;
  String email;
  String password;
  String service_id;
  String service_issue;
  String sub_service_ids;
  String service_request_date;
  String country;
  String state;
  String city;
  String street;
  String number;
  String subAdministrativeArea;
  String zipcode;
  String is_social_user;
  String social_media_id;
  bool isMobileEntry = false;
  String issue_imag_url;
  List<ServiceDatas> idList;
  List<String> priceList;

  Otp(
      {Key key,
      this.password,
      this.email,
      this.firstname,
      this.lastname,
      this.mobleNumber,
      this.service_id,
      this.sub_service_ids,
      this.service_issue,
      this.service_request_date,
      this.country,
      this.number,
      this.zipcode,
      this.subAdministrativeArea,
      this.street,
      this.state,
      this.city,
      this.is_social_user,
      this.social_media_id,
      this.isMobileEntry,
      this.issue_imag_url,
      this.idList,
      this.priceList})
      : super(key: key);

  @override
  OtpSetState createState() => OtpSetState();
}

class OtpSetState extends State<Otp> {
  TextEditingController otp = new TextEditingController();
  bool _otpValidate = false;
  Map userDetails;
  int _counter = 30;
  Timer _timer;
  bool visible;
  String phoneNo;
  String smsCode;
  String verificationId;
  Map checkUser;
  var status = "";
  var isLoading = false;
  final FirebaseMessaging _notificationmessaging = FirebaseMessaging.instance;

  void _startTimer() {
    _counter = 30;
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        visible = true;
        if (_counter > 0) {
          _counter--;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timer.cancel();
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    phoneNo = "+91" + widget.mobleNumber;
    sendOtp(phoneNo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 5.0, right: 10.0),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0),
                    Text(
                      "Authenticate your account",
                      style: TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.0),
                    Column(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 30.0, right: 30.0),
                          child: TextField(
                            controller: otp,
                            keyboardType: TextInputType.numberWithOptions(),
                            decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                                hintText: "OTP",
                                errorText: _otpValidate ? "Enter OTP" : null),
                          ),
                        ),
                        Visibility(
                          visible: _counter > 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                "Seconds remaining",
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.grey),
                              ),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text(
                                (_counter >= 10)
                                    ? "00:"
                                        '$_counter'
                                    : "00:0" '$_counter',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        (_counter > 0)
                            ? Text("")
                            : Container(
                                padding:
                                    EdgeInsets.only(left: 30.0, right: 30.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "I did not receive a code",
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.grey),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: 20.0,
                                    ),
                                    GestureDetector(
                                      child: Text(
                                        "RESEND",
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: primaryRedColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onTap: () {
                                        sendOtp(phoneNo);
                                        _startTimer();
                                      },
                                    )
                                  ],
                                ),
                              ),
                        SizedBox(height: 20.0),
                        Container(
                          padding: EdgeInsets.only(right: 30.0, left: 30.0),
                          child: MaterialButton(
                              color: primaryRedColor,
                              minWidth: double.infinity,
                              child: Text(
                                "Verify",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () async {
                                setState(() {
                                  _timer.cancel();
                                  otp.text.isEmpty
                                      ? _otpValidate = true
                                      : _otpValidate = false;
                                });
                                if (!otp.text.isEmpty) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  signInWithOTP(otp.text, verificationId);
                                }
                              }),
                        ),
                        SizedBox(
                          height: 30.0,
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Text(
                              "We would like to verify your contact no.as information we may share will be personalized and secure",
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            )),
                      ],
                    )
                  ],
                ),
              ));
  }

  Future<void> sendOtp(String mobleNumber) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneVerificationFailed verificationFail =
        (AuthException authException) {
      print('verificationFail::${authException.message}');
    };

    final PhoneVerificationCompleted verificationComp =
        (FirebaseUser phoneAuthCredential) {
      print("verificationComp::${phoneAuthCredential}");
      print(phoneAuthCredential.providerId);
      print(phoneAuthCredential);
    };

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      print("sms send to that number");
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobleNumber,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verificationComp,
        verificationFailed: verificationFail,
        codeSent: smsOTPSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }

  Future<bool> smsOTPDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter sms Code'),
            content: TextField(
              onChanged: (value) {
                this.smsCode = value;
              },
            ),
            contentPadding: EdgeInsets.all(10.0),
            actions: <Widget>[
              new FlatButton(
                child: Text('Done'),
                onPressed: () {
                  FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                    } else {
                      Navigator.of(context).pop();
                      signInWithOTP(smsCode, verificationId);
                    }
                  });
                },
              )
            ],
          );
        });
  }

  signInWithOTP(smsCode, verId) async {
    FirebaseUser authCreds = await FirebaseAuth.instance
        .signInWithPhoneNumber(verificationId: verId, smsCode: smsCode);
    signIn(authCreds);
  }

  void signIn(FirebaseUser phoneAuthCredential) async {
    try {
      FirebaseAuth.instance
          .signInWithCustomToken(
              token: await phoneAuthCredential.getIdToken(refresh: true))
          .then((user) {
        if (user != null) {
          if (widget.isMobileEntry) {
            widget.isMobileEntry = false;
            save_string_prefs("mobile", widget.mobleNumber);
            save_bool_prefs("isMobileAuth", true);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => Signup(
                          isFbActivated: true,
                        )));
          } else {
            signUp(
              zipcode: widget.zipcode,
              user_paid_type: 1.toString(),
              user_org_legal: 1.toString(),
              state: widget.state,
              rating: 3.toString(),
              mobile_no: widget.mobleNumber.toString(),
              is_social_user: widget.is_social_user,
              is_licence: 1.toString(),
              is_approved: 1.toString(),
              first_name: widget.firstname.toString(),
              country_code: 91.toString(),
              city: widget.subAdministrativeArea,
              address2: _formatAddress(),
              address: _formatAddress(),
              email: widget.email.toString(),
              password: widget.password.toString(),
              usertype_id: 1.toString(),
              social_media_id: widget.social_media_id,
            );
          }
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return new AlertDialog(
                  title: Text(
                    "Error",
                    style: TextStyle(color: primaryRedColor),
                  ),
                  content: Text(
                    "Invalid Otp",
                    style: TextStyle(color: primaryRedColor),
                  ),
                  contentPadding: EdgeInsets.all(10.0),
                  actions: <Widget>[
                    new FlatButton(
                      child: Text('ok'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                );
              });
        }
        print(onError.toString());
      });
    } catch (e) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return new AlertDialog(
              title: Text("Error"),
              content: Text(e.toString()),
              contentPadding: EdgeInsets.all(10.0),
              actions: <Widget>[
                new FlatButton(
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
    }
    setState(() {
      isLoading = false;
    });
  }

  void signUp(
      {String zipcode,
      String user_paid_type,
      String user_org_legal,
      String state,
      String rating,
      String mobile_no,
      String is_social_user,
      String is_licence,
      String is_approved,
      String first_name,
      String country_code,
      String city,
      String address2,
      String address,
      String email,
      String password,
      String usertype_id,
      String social_media_id}) async {
    signupDailyNeeds(
      usertype_id: usertype_id,
      password: password,
      email: email,
      address: address,
      address2: address2,
      city: city,
      country_code: country_code,
      first_name: first_name,
      is_approved: is_approved,
      is_licence: is_licence,
      is_social_user: is_social_user,
      mobile_no: mobile_no,
      rating: rating,
      state: state,
      user_org_legal: user_org_legal,
      user_paid_type: user_paid_type,
      zipcode: zipcode,
      social_media_id: social_media_id,
    ).then((onResponse) async {
      if (onResponse is SignUpModel) {
        if (onResponse.data.message == "User Registered Successfully") {
          save_string_prefs("signupuser", json.encode(onResponse));
          String userDetails = await get_string_prefs("signupuser");
          print(userDetails);
          checkUser = json.decode(userDetails);
          String signUpUserId = checkUser["data"]["user_details"][0]["id"];
          String signToken = checkUser["data"]["access_token"];
          save_string_prefs("signUpUesrId", signUpUserId);
          save_string_prefs("signUpToken", signToken);
          save_string_prefs("emailSignUpPref", email);
          save_string_prefs("passwordSignUpPref", password);
          getNotification();
          Navigator.pop(context);
          bool isHomeLogin = await get_bool_prefs("isHomeLogin");
          if (isHomeLogin) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserLocation(
                          userId: signUpUserId,
                          service_request_date: widget.service_request_date,
                          sub_service_ids: widget.sub_service_ids,
                          service_issue: widget.service_issue,
                          service_id: widget.service_id,
                          imageUrl: widget.issue_imag_url,
                        )));*/
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
        } else if (onResponse.data.message ==
            "Email address already registered!") {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
      print(onResponse);
    });
  }

  void getNotification() {
    String loginUserId = checkUser["data"]["user_details"][0]["id"];
    String newtoken = checkUser["data"]["access_token"];

    _notificationmessaging.getToken().then((token) {
      if (token != null) {
        pushNotification(
            device_token: token.toString(),
            imei_no: token.toString(),
            user_id: loginUserId,
            token: newtoken);
      }
    });
  }

  String _formatAddress() {
    String addr = widget.number +
        ',' +
        widget.street +
        ',' +
        widget.city +
        ',' +
        widget.subAdministrativeArea +
        '-' +
        widget.zipcode +
        ',' +
        widget.state +
        '.';
    print(addr);
    return addr;
  }
}
