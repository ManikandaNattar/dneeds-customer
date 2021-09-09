import 'package:daily_needs/forgot_password_model.dart';
import 'package:daily_needs/reusuable_widgets/common_loader.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/api.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'api_model_classes/check_mobile.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController mobileController = new TextEditingController();
  TextEditingController newPassword = new TextEditingController();
  TextEditingController confirmNewPassword = new TextEditingController();
  TextEditingController otpController = new TextEditingController();
  bool _validate = false;
  bool _mvalidate = false;
  bool emailIconColorEnable = false;
  bool passwordVisible = true;
  bool _evalidate = false;
  bool iconColorEnable = false;
  bool isLoading = false;
  String flag = '';
  bool otpbool = false, mobilehidebool = true, passwordbool = false;
  String verificationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Forgot Password'),
          backgroundColor: primaryRedColor,
          centerTitle: true,
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Login())),
          ),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _forgotPassword());
  }

  Widget _forgotPassword() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: 20.0,
          ),
          mobilehidebool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                      child: TextField(
                    controller: mobileController,
                    keyboardType: TextInputType.number,
                    maxLength: 10,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        prefixIcon: Icon(
                          Icons.call,
                          color: Colors.grey,
                        ),
                        hintText: "Enter your registered mobile number",
                        counterText: "",
                        errorText: _mvalidate
                            ? "Please enter valid mobile number"
                            : null),
                    style: TextStyle(height: 2.0),
                    onTap: _chooseColorEmail(),
                  )))
              : new Container(),
          SizedBox(
            height: 20.0,
          ),
          otpbool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                    child: TextField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          prefixIcon: Icon(
                            Icons.edit,
                            color: Colors.grey,
                          ),
                          hintText: "Enter your OTP",
                          counterText: "",
                          errorText: _evalidate
                              ? "Please enter your valid OTP !!!"
                              : null),
                      onTap: _chooseColor(),
                      style: TextStyle(height: 2.0),
                    ),
                  ),
                )
              : new Container(),
          passwordbool
              ? SizedBox(
                  height: 20.0,
                )
              : new Container(),
          passwordbool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                    child: TextField(
                      controller: newPassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                          hintText: "Enter new password",
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
                          errorText:
                              _evalidate ? "Please enter password" : null),
                      onTap: _chooseColor(),
                      style: TextStyle(height: 2.0),
                    ),
                  ),
                )
              : new Container(),
          passwordbool
              ? SizedBox(
                  height: 20.0,
                )
              : new Container(),
          passwordbool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: Container(
                    child: TextField(
                      controller: confirmNewPassword,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: passwordVisible,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.grey,
                          ),
                          hintText: "Confirm new password",
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
                          errorText: _evalidate ? "Please new password" : null),
                      onTap: _chooseColor(),
                      style: TextStyle(height: 2.0),
                    ),
                  ),
                )
              : new Container(),
          SizedBox(height: 30.0),
          mobilehidebool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: new MaterialButton(
                    minWidth: double.infinity,
                    color: primaryRedColor,
                    textColor: Colors.white,
                    child: new Text(
                      "Send OTP",
                      style: new TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        mobileController.text.isEmpty
                            ? _validate = true
                            : _validate = false;
                        bool isEmailId = validateEmail(mobileController.text);
                        if (isEmailId) {
                          flag = 'email';
                        } else {
                          flag = 'mobile';
                          mobileController.text.length == 10
                              ? _mvalidate = false
                              : _mvalidate = true;
                        }
                      });
                      if (!_mvalidate) {
                        calLoaderPage(context: context);
                        checktheMobilenumberIsRegistered(mobileController.text);
                      }

                      /* if (!mobileController.text.isEmpty &&
                    !newPassword.text.isEmpty) {
                  forgotPasswordServiceCall(
                      email: mobileController.text,
                      password: newPassword.text,
                      flag: flag);
                }*/
                    },
                    splashColor: splashColor,
                  ),
                )
              : new Container(),
          SizedBox(height: 30.0),
          otpbool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: new MaterialButton(
                    minWidth: double.infinity,
                    color: primaryRedColor,
                    textColor: Colors.white,
                    child: new Text(
                      "Verify OTP",
                      style: new TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () async {
                      calLoaderPage(context: context);
                      String smsCode = otpController.text;
                      if (otpController.text.isNotEmpty) {
                        signInWithOTP(smsCode, verificationId);
                      } else {
                        Toast.show("Enter valid OTP !!", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    },
                    splashColor: splashColor,
                  ),
                )
              : new Container(),
          passwordbool
              ? Padding(
                  padding: EdgeInsets.only(left: 40.0, right: 40.0),
                  child: new MaterialButton(
                    minWidth: double.infinity,
                    color: primaryRedColor,
                    textColor: Colors.white,
                    child: new Text(
                      "Reset Password",
                      style: new TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                    onPressed: () async {
                      if (newPassword.text.isNotEmpty &&
                          confirmNewPassword.text.isNotEmpty &&
                          newPassword.text == confirmNewPassword.text) {
                        forgotPasswordServiceCall(
                            email: mobileController.text,
                            password: newPassword.text,
                            flag: "mobile");
                      } else {
                        Toast.show("Enter correct password !!", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    },
                    splashColor: splashColor,
                  ),
                )
              : new Container()
        ],
      ),
    );
  }

  @override
  void initState() {
    save_bool_prefs("isHomeLogin", true);
    super.initState();
  }

  void forgotPasswordServiceCall(
      {String email, String password, String flag}) async {
    setState(() {
      isLoading = true;
    });
    forgotPassword(email: email, newPassword: password, flag: flag)
        .then((onResponse) async {
      if (onResponse is ForgotPasswordModel) {
        setState(() {
          isLoading = false;
        });
        if (onResponse.statusCode == "200") {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Login()));
        } else {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
    });
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

  void checktheMobilenumberIsRegistered(String mobile) {
    checkMobileNumber(mobileNumber: mobile).then((onResponse) {
      if (onResponse is Check_MobileNumber) {
        print("mobile number registered??   " + onResponse.data.message);
        if (onResponse.data.message == "Mobile number not exist.") {
          Navigator.pop(context);
          Toast.show("Mobile number is not Registered !!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (onResponse.data.message == "Mobile number already exist.") {
          sendOtp("+91" + mobile);
        }
      }
    });
  }

  Future<void> sendOtp(String mobleNumber) async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneVerificationFailed verificationFail =
        (AuthException authException) {
      print('verificationFail::${authException.message}');
      Navigator.pop(context);
      Toast.show("${authException.message}!!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    };

    final PhoneVerificationCompleted verificationComp =
        (FirebaseUser phoneAuthCredential) async {
      print("verificationComp::${phoneAuthCredential}");
      print(phoneAuthCredential.providerId);
      print(phoneAuthCredential);
    };

    final PhoneCodeSent smsOTPSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;
      setState(() {
        otpbool = true;
        mobilehidebool = false;
        Navigator.pop(context);
      });
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: mobleNumber,
        timeout: const Duration(seconds: 10),
        verificationCompleted: verificationComp,
        verificationFailed: verificationFail,
        codeSent: smsOTPSent,
        codeAutoRetrievalTimeout: autoRetrieve);
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
          setState(() {
            passwordbool = true;
            otpbool = false;
            isLoading = false;
          });
          Navigator.pop(context);
        }
      }).catchError((onError) {
        if (onError is PlatformException) {
          Navigator.pop(context);
          passwordbool = false;
          otpbool = true;
          setState(() {
            isLoading = false;
          });
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
}
