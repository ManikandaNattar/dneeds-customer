import 'package:daily_needs/api.dart';
import 'package:daily_needs/book_service.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/otpscreen/otp_page.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/address.dart';
import 'package:toast/toast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:location/location.dart';

class Signup extends StatefulWidget {
  bool isFbActivated;
  String service_id;
  String service_issue;
  String sub_service_ids;
  String service_request_date;
  Map facebookProfile;
  String issue_imag_url;
  List<ServiceDatas> idList;
  List<String> priceList;

  Signup(
      {Key key,
      this.isFbActivated,
      this.service_id,
      this.service_issue,
      this.sub_service_ids,
      this.service_request_date,
      this.facebookProfile,
      this.issue_imag_url,
      this.idList,
      this.priceList})
      : super(key: key);

  @override
  SignupSetState createState() => SignupSetState();
}

class SignupSetState extends State<Signup> {
  TextEditingController mobileno = new TextEditingController();
  TextEditingController firstname = new TextEditingController();
  TextEditingController lastname = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController password = new TextEditingController();
  bool _fvalidate = false;
  bool _lvalidate = false;
  bool _mvalidate = false;
  bool _evalidate = false;
  bool _passvalidate = false;
  bool passwordVisible = true;
  bool passwordIconColorEnable = false;
  bool showSkipOnTop = false;
  String holder = "";
  String gender;
  bool isTapMale = false;
  bool isTapFemale = false;
  List<bool> isSelected = [false, false, false];
  String fbId;
  bool isHomeLogin = false;
  Location location = new Location();
  bool _serviceEnabled;
  LocationData _locationData;

  @override
  void initState() {
    super.initState();
    tryToGetLocationPermission();
    if (widget.isFbActivated == false) {
      firstname.text = widget.facebookProfile["firstName"] != null
          ? widget.facebookProfile["firstName"]
          : "  ";
      email.text = widget.facebookProfile["email"];
      print('FBID:${widget.facebookProfile["fbgoogleID"]}');
      fbId = widget.facebookProfile["fbgoogleID"];
      save_string_prefs("social_id", fbId);
      save_string_prefs("loginFlag", "social");
    }
    getMobileNo();
  }

  void getMobileNo() async {
    String mobile_no = await get_string_prefs("mobile");
    bool isViaMobile = await get_bool_prefs("isMobileAuth");
    if ((isViaMobile) && (mobile_no != null)) {
      if (mobile_no.isNotEmpty) {
        mobileno.text = mobile_no;
      }
    } else {
      mobileno.text = "";
    }

    if (isViaMobile) {
      setState(() {
        showSkipOnTop = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: 40.0),
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Visibility(
                      visible: showSkipOnTop,
                      child: new InkWell(
                          child: new Text(
                            "Skip for now",
                            style: TextStyle(
                                color: primaryRedColor, fontSize: 15.0),
                          ),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                                new MaterialPageRoute(
                                    builder: (context) => HomePage()));
                          }),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Visibility(
                visible: widget.isFbActivated,
                child: Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Container(
                    child: TextField(
                      controller: firstname,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          prefixIcon: Icon(
                            Icons.perm_identity,
                            color: Colors.grey,
                          ),
                          hintText: "First Name",
                          labelStyle: TextStyle(color: Colors.grey),
                          errorText: _fvalidate ? "Enter First Name" : null),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Visibility(
                visible: widget.isFbActivated,
                child: Padding(
                  padding: EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Container(
                    child: TextField(
                      controller: lastname,
                      decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey)),
                          prefixIcon: Icon(
                            Icons.perm_identity,
                            color: Colors.grey,
                          ),
                          hintText: "Last Name",
                          labelStyle: TextStyle(color: Colors.grey),
                          errorText: _lvalidate ? "Enter Last Name" : null),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Container(
                  child: TextField(
                    controller: mobileno,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      prefixIcon: Icon(
                        Icons.phone_iphone,
                        color: Colors.grey,
                      ),
                      hintText: "Mobile",
                      labelStyle: TextStyle(color: Colors.grey),
                      counterText: "",
                      errorText: _mvalidate ? "Enter Mobile Number" : null,
                    ),
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Container(
                  child: TextField(
                    controller: email,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey)),
                      prefixIcon: Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                      hintText: "Email",
                      labelStyle: TextStyle(color: Colors.grey),
                      errorText: _evalidate ? "Enter Email ID" : null,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Container(
                  child: TextField(
                    controller: password,
                    obscureText: passwordVisible,
                    decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.grey,
                        ),
                        hintText: "Password",
                        labelStyle: TextStyle(color: Colors.grey),
                        errorText: _passvalidate ? "Enter Password" : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: passwordIconColorEnable
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        )),
                    keyboardType: TextInputType.visiblePassword,
                    onTap: chooseColor(),
                  ),
                ),
              ),
              SizedBox(height: 50.0),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Container(
                    child: MaterialButton(
                  color: primaryRedColor,
                  minWidth: double.infinity,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    setState(() {
                      firstname.text.isEmpty
                          ? _fvalidate = true
                          : lastname.text.isEmpty
                              ? _lvalidate = true
                              : mobileno.text.isEmpty
                                  ? _mvalidate = true
                                  : email.text.isEmpty
                                      ? _evalidate = true
                                      : password.text.isEmpty
                                          ? _passvalidate = true
                                          : _passvalidate = false;
                    });
                    if (widget.isFbActivated == true) {
                      if ((!firstname.text.isEmpty &&
                              !lastname.text.isEmpty &&
                              !mobileno.text.isEmpty &&
                              !email.text.isEmpty) &&
                          mobileno.text.length == 10) {
                        Map<String, dynamic> jsonMap = new Map();
                        jsonMap["usertype_id"] = 1.toString();
                        jsonMap["email"] = email.text.toString();
                        jsonMap["password"] = password.text.toString();
                        jsonMap["mobile_no"] = mobileno.text.toString();
                        jsonMap["first_name"] = firstname.text.toString();
                        jsonMap["last_name"] = lastname.text.toString();
                        jsonMap["address"] = "erode";
                        jsonMap["address2"] = "erode";
                        jsonMap["city"] = "city";
                        jsonMap["state"] = "tamilnadu";
                        jsonMap["zipcode"] = "638007";
                        jsonMap["is_social_user"] = 0.toString();
                        jsonMap["user_paid_type"] = 1.toString();
                        jsonMap["is_licence"] = 1.toString();
                        jsonMap["is_approved"] = 1.toString();
                        jsonMap["user_org_legal"] = 1.toString();
                        jsonMap["rating"] = 3.toString();
                        jsonMap["country_code"] = 91.toString();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserAddress(
                                      email: email.text.toString(),
                                      password: password.text.toString(),
                                      firstname: firstname.text.toString(),
                                      lastname: lastname.text.toString(),
                                      mobleNumber: mobileno.text.toString(),
                                      service_id: widget.service_id.toString(),
                                      service_issue:
                                          widget.service_issue.toString(),
                                      sub_service_ids:
                                          widget.sub_service_ids.toString(),
                                      service_request_date: widget
                                          .service_request_date
                                          .toString(),
                                      is_social_user: 0.toString(),
                                      issue_imag_url: widget.issue_imag_url,
                                      idList: widget.idList,
                                      priceList: widget.priceList,
                                    )));
                      } else {
                        Toast.show("Please Enter All Details", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    } else {
                      if (!mobileno.text.isEmpty &&
                          !email.text.isEmpty &&
                          mobileno.text.length == 10) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserAddress(
                                      email: email.text.toString(),
                                      password: password.text.toString(),
                                      firstname: firstname.text.toString(),
                                      lastname: lastname.text.toString(),
                                      mobleNumber: mobileno.text.toString(),
                                      service_id: widget.service_id.toString(),
                                      service_issue:
                                          widget.service_issue.toString(),
                                      sub_service_ids:
                                          widget.sub_service_ids.toString(),
                                      service_request_date: widget
                                          .service_request_date
                                          .toString(),
                                      is_social_user: 1.toString(),
                                      social_media_id: fbId,
                                      issue_imag_url: widget.issue_imag_url,
                                      idList: widget.idList,
                                      priceList: widget.priceList,
                                    )));
                      } else {
                        Toast.show("Please Enter All Details", context,
                            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                      }
                    }
                  },
                )),
              ),
              new Padding(
                padding: EdgeInsets.only(top: 20.0, left: 20, right: 20),
                child: new GestureDetector(
                  child: new Center(
                    child: new Text(
                      "I HAVE AN ACCOUNT",
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                          color: primaryRedColor),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => new Login(
                                  service_id: widget.service_id,
                                  service_issue: widget.service_issue,
                                  sub_service_ids: widget.sub_service_ids,
                                  service_request_date:
                                      widget.service_request_date,
                                  issue_imag_url: widget.issue_imag_url,
                                  idList: widget.idList,
                                  priceList: widget.priceList,
                                )));
                  },
                ),
              ),
            ],
          ),
        ));
  }

  chooseColor() {
    setState(() {
      passwordIconColorEnable = true;
    });
  }

  void signUp(
      {String usertype_id,
      String email,
      String password,
      String mobile_no,
      String first_name,
      String address,
      String address2,
      String city,
      String state,
      String zipcode,
      String is_social_user,
      String user_paid_type,
      String is_licence,
      String is_approved,
      String user_org_legal,
      String rating,
      String country_code}) {
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
    ).then((onResponse) {
      print(onResponse);
    });
  }

  void tryToGetLocationPermission() async {
    _serviceEnabled = await location.serviceEnabled();
    print("is location activated=" + _serviceEnabled.toString());
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        tryToGetLocationPermission();
      }
    }

    var _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        tryToGetLocationPermission();
      }
    }

    _locationData = await location.getLocation();
  }
}
