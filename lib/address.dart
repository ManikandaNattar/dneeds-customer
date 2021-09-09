import 'dart:convert';
import 'package:daily_needs/add_to_cart/add_to_cart.dart';
import 'package:daily_needs/book_service.dart';
import 'package:daily_needs/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';

import 'package:geolocator/geolocator.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/signup_model.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/otpscreen/otp_page.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'daily_homepage.dart';
import 'getAllCategoryService.dart';
import './../utils.dart' as utils;
import 'package:geocoding/geocoding.dart';

class UserAddress extends StatefulWidget {
  String firstname;
  String lastname;
  String mobleNumber;
  String email;
  String password;
  String service_id;
  String service_issue;
  String sub_service_ids;
  String service_request_date;
  String is_social_user;
  String social_media_id;
  List<ServiceDatas> idList;
  String issue_imag_url;
  List<String> priceList;

  UserAddress(
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
      this.is_social_user,
      this.social_media_id,
      this.issue_imag_url,
      this.idList,
      this.priceList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UserAddress();
  }
}

class _UserAddress extends State<UserAddress> {
  TextEditingController country = new TextEditingController();
  TextEditingController state = new TextEditingController();
  TextEditingController city = new TextEditingController();
  TextEditingController newcity = new TextEditingController();
  TextEditingController number = new TextEditingController();
  TextEditingController street = new TextEditingController();
  TextEditingController subadministrativeArea = new TextEditingController();
  TextEditingController zipcode = new TextEditingController();

  final Geolocator geolocator = Geolocator();
  final FirebaseMessaging _notificationmessaging = FirebaseMessaging();
  GlobalKey<AutoCompleteTextFieldState<String>> cityKey = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> stateKey = new GlobalKey();
  String _currentAddress;
  Position _currentPosition;
  GetAllCategoryServices getCategoryServicesForCities;
  String nation;
  String nation_state;
  String locality;
  String dNumber;
  String streetName;
  String postalcode;
  String district;
  Map checkUser;
  bool isLoading;
  bool isgetting = true;
  List<String> listOfStates = [];
  List<String> listOfCities = [];

  @override
  void initState() {
    _getCurrentLocation();
    getCitiesAndStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading && isgetting
          ? Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      controller: number,
                      decoration: InputDecoration(
                        hintText: "Door Number",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      controller: street,
                      decoration: InputDecoration(
                        hintText: "Enter Street",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      controller: city,
                      decoration: InputDecoration(
                        hintText: "Area",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: AutoCompleteTextField<String>(
                      controller: subadministrativeArea,
                      key: cityKey,
                      clearOnSubmit: false,
                      suggestions: listOfCities,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: "City",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      itemFilter: (item, query) {
                        return item
                            .toLowerCase()
                            .startsWith(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.compareTo(b);
                      },
                      itemSubmitted: (item) {
                        setState(() {
                          subadministrativeArea.text = item;
                        });
                      },
                      itemBuilder: (context, item) {
                        return row(item);
                      },
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      controller: zipcode,
                      decoration: InputDecoration(
                        hintText: "postal code",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: AutoCompleteTextField<String>(
                      controller: state,
                      key: stateKey,
                      clearOnSubmit: false,
                      suggestions: listOfStates,
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                        hintText: "State",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      itemFilter: (item, query) {
                        return item
                            .toLowerCase()
                            .startsWith(query.toLowerCase());
                      },
                      itemSorter: (a, b) {
                        return a.compareTo(b);
                      },
                      itemSubmitted: (item) {
                        setState(() {
                          state.text = item;
                        });
                      },
                      itemBuilder: (context, item) {
                        return row(item);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0, right: 20.0),
                    child: TextField(
                      controller: country,
                      decoration: InputDecoration(
                        hintText: "Country",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  ),
                  isgetting == true
                      ? new Padding(
                          padding: new EdgeInsets.only(
                              left: 20.0, top: 50.0, right: 20.0),
                          child: new Text(
                            'Detecting address..',
                            style: new TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15.0),
                          ),
                        )
                      : new Container(),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(left: 0.0, right: 0.0),
          child: MaterialButton(
            height: 50,
            child: Text(
              "Done",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600),
            ),
            minWidth: double.infinity,
            color: primaryRedColor,
            onPressed: () async {
              if (!country.text.isEmpty &&
                  !state.text.isEmpty &&
                  !zipcode.text.isEmpty &&
                  !subadministrativeArea.text.isEmpty &&
                  !number.text.isEmpty &&
                  !street.text.isEmpty) {
                String mobile_no = await get_string_prefs("mobile");
                bool isMobileAuth = await get_bool_prefs("isMobileAuth");
                bool isHomeLogin = await get_bool_prefs("isHomeLogin");
                if (isHomeLogin) {
                  if (isMobileAuth) {
                    if (mobile_no == widget.mobleNumber) {
                      signUp(
                        zipcode: zipcode.text,
                        user_paid_type: 1.toString(),
                        user_org_legal: 1.toString(),
                        state: state.text,
                        rating: 3.toString(),
                        mobile_no: widget.mobleNumber,
                        is_social_user: widget.is_social_user,
                        is_licence: 1.toString(),
                        is_approved: 1.toString(),
                        first_name: widget.firstname.toString(),
                        country_code: 91.toString(),
                        city: city.text,
                        address2: _formatAddress(),
                        address: _formatAddress(),
                        email: widget.email.toString(),
                        password: widget.password.toString(),
                        usertype_id: 1.toString(),
                        social_media_id: widget.social_media_id,
                      );
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Otp(
                                    mobleNumber: widget.mobleNumber,
                                    service_id: widget.service_id,
                                    service_issue: widget.service_issue,
                                    sub_service_ids: widget.sub_service_ids,
                                    service_request_date:
                                        widget.service_request_date,
                                    firstname: widget.firstname,
                                    lastname: widget.lastname,
                                    password: widget.password,
                                    email: widget.email,
                                    city: subadministrativeArea.text.toString(),
                                    country: country.text,
                                    number: number.text,
                                    street: street.text,
                                    state: state.text,
                                    zipcode: zipcode.text,
                                    subAdministrativeArea:
                                        subadministrativeArea.text,
                                    is_social_user: widget.is_social_user,
                                    social_media_id: widget.social_media_id,
                                    isMobileEntry: false,
                                    issue_imag_url: widget.issue_imag_url,
                                    idList: widget.idList,
                                    priceList: widget.priceList,
                                  )));
                    }
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Otp(
                                  mobleNumber: widget.mobleNumber,
                                  service_id: widget.service_id,
                                  service_issue: widget.service_issue,
                                  sub_service_ids: widget.sub_service_ids,
                                  service_request_date:
                                      widget.service_request_date,
                                  firstname: widget.firstname,
                                  lastname: widget.lastname,
                                  password: widget.password,
                                  email: widget.email,
                                  city: subadministrativeArea.text.toString(),
                                  country: country.text,
                                  number: number.text,
                                  street: street.text,
                                  state: state.text,
                                  zipcode: zipcode.text,
                                  subAdministrativeArea:
                                      subadministrativeArea.text,
                                  is_social_user: widget.is_social_user,
                                  social_media_id: widget.social_media_id,
                                  isMobileEntry: false,
                                  issue_imag_url: widget.issue_imag_url,
                                  priceList: widget.priceList,
                                  idList: widget.idList,
                                )));
                  }
                } else {
                  if (isMobileAuth) {
                    if (mobile_no == widget.mobleNumber) {
                      signUp(
                        zipcode: zipcode.text,
                        user_paid_type: 1.toString(),
                        user_org_legal: 1.toString(),
                        state: state.text,
                        rating: 3.toString(),
                        mobile_no: widget.mobleNumber,
                        is_social_user: widget.is_social_user,
                        is_licence: 1.toString(),
                        is_approved: 1.toString(),
                        first_name: widget.firstname.toString(),
                        country_code: 91.toString(),
                        city: city.text,
                        address2: _formatAddress(),
                        address: _formatAddress(),
                        email: widget.email.toString(),
                        password: widget.password.toString(),
                        usertype_id: 1.toString(),
                        social_media_id: widget.social_media_id,
                      );
                    } else {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Otp(
                                    mobleNumber: widget.mobleNumber,
                                    service_id: widget.service_id,
                                    service_issue: widget.service_issue,
                                    sub_service_ids: widget.sub_service_ids,
                                    service_request_date:
                                        widget.service_request_date,
                                    firstname: widget.firstname,
                                    lastname: widget.lastname,
                                    password: widget.password,
                                    email: widget.email,
                                    city: subadministrativeArea.text.toString(),
                                    country: country.text,
                                    number: number.text,
                                    street: street.text,
                                    state: state.text,
                                    zipcode: zipcode.text,
                                    subAdministrativeArea:
                                        subadministrativeArea.text,
                                    is_social_user: widget.is_social_user,
                                    social_media_id: widget.social_media_id,
                                    isMobileEntry: false,
                                    issue_imag_url: widget.issue_imag_url,
                                    idList: widget.idList,
                                    priceList: widget.priceList,
                                  )));
                    }
                  } else {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Otp(
                                  mobleNumber: widget.mobleNumber,
                                  service_id: widget.service_id,
                                  service_issue: widget.service_issue,
                                  sub_service_ids: widget.sub_service_ids,
                                  service_request_date:
                                      widget.service_request_date,
                                  firstname: widget.firstname,
                                  lastname: widget.lastname,
                                  password: widget.password,
                                  email: widget.email,
                                  city: subadministrativeArea.text.toString(),
                                  country: country.text,
                                  number: number.text,
                                  street: street.text,
                                  state: state.text,
                                  zipcode: zipcode.text,
                                  subAdministrativeArea:
                                      subadministrativeArea.text,
                                  is_social_user: widget.is_social_user,
                                  social_media_id: widget.social_media_id,
                                  isMobileEntry: false,
                                  issue_imag_url: widget.issue_imag_url,
                                  priceList: widget.priceList,
                                  idList: widget.idList,
                                )));
                  }
                }
              } else {
                Toast.show("Please Enter All Details", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }
            },
          )),
    );
  }

  String _formatAddress() {
    String addr = number.text +
        ',' +
        street.text +
        ',' +
        city.text +
        ',' +
        subadministrativeArea.text +
        '-' +
        zipcode.text +
        ',' +
        state.text +
        '.';
    print(addr);
    return addr;
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
          checkUser = json.decode(userDetails);
          String signUpUserId = checkUser["data"]["user_details"][0]["id"];
          String signToken = checkUser["data"]["access_token"];
          save_string_prefs("signUpUesrId", signUpUserId);
          save_string_prefs("signUpToken", signToken);
          save_string_prefs("emailSignUpPref", email);
          save_string_prefs("passwordSignUpPref", password);
          getNotification();

          bool viaMobile = await get_bool_prefs("isMobileAuth");
          if (viaMobile) {
            save_bool_prefs("isMobileAuth", false);
            save_string_prefs("mobile", "");
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          } else {
            Navigator.pop(context);
            /* Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserLocation(
                          userId: signUpUserId,
                          service_request_date: widget.service_request_date,
                          sub_service_ids: widget.sub_service_ids,
                          service_issue: widget.service_issue,
                          service_id: widget.service_id,
                        )));*/
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
        } else if (onResponse.data.message ==
            "Email address already registered!") {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        } else if (onResponse.statusCode == "100") {
          Toast.show(onResponse.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
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

  _getCurrentLocation() async {
    isLoading = true;
    // Map<Permission, PermissionStatus> statuses = {};
    // PermissionStatus _permissionStatus;
    // print('iOs-chk');
    // _permissionStatus = await Permission.locationWhenInUse.status;
    // print('iOs-chk-2');
    // if (_permissionStatus.isUndetermined || _permissionStatus.isDenied) {
    //   statuses = await [
    //     Permission.locationWhenInUse,
    //   ].request();
    //   _permissionStatus = statuses[Permission.locationWhenInUse];
    // }
    // var permissions =
    //     await Permission.getPermissionsStatus([PermissionName.Location]);
    // if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
    //   var askpermissions =
    //       await Permission.requestPermissions([PermissionName.Location]);
    // }
    utils.checkPermission(Permission.locationWhenInUse).then((value) {
      if (value != null) {
        Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true,
        ).then((Position position) {
          setState(() {
            _currentPosition = position;
          });
          getAddressFromLatLng();
        }).catchError((e) {
          isLoading = false;
          print(e);
        });
      }
    });
  }

  getAddressFromLatLng() async {
    try {
      var p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      var place = p.first;
      print(place);
      setState(() {
        number.text = place.name;
        street.text = place.thoroughfare;
        city.text = place.locality;
        subadministrativeArea.text = place.subAdministrativeArea;
        zipcode.text = place.postalCode;
        state.text = place.administrativeArea;
        country.text = place.country;
        isLoading = false;
        _currentAddress =
            "${place.subThoroughfare.isEmpty ? '' : place.subThoroughfare + ','}${place.thoroughfare.isEmpty ? '' : place.thoroughfare + ','}${locality.isEmpty ? '' : locality + ','}${place.subAdministrativeArea.isEmpty ? '' : place.subAdministrativeArea}${place.postalCode.isEmpty ? '' : '-' + place.postalCode + ','}${nation_state.isEmpty ? '' : nation_state + ','}${nation.isEmpty ? '' : nation}.";
      });
      print(_currentAddress);
      print("room is " + place.name);
      print("i dont know exact" + place.subLocality);
      print("i think door number" + place.subThoroughfare);
      print("i think its Street" + place.thoroughfare);
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  void getCitiesAndStates() async {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        print(onResponse.statusCode);

        setState(() {
          getCategoryServicesForCities = onResponse;
          print(getCategoryServicesForCities.data.states.length);
          print(getCategoryServicesForCities.data.cities.length);
          for (var i = 0;
              i < getCategoryServicesForCities.data.cities.length;
              i++) {
            listOfCities.add(getCategoryServicesForCities.data.cities[i].city);
          }
          for (var i = 0;
              i < getCategoryServicesForCities.data.states.length;
              i++) {
            listOfStates.add(getCategoryServicesForCities.data.states[i].state);
          }
          isgetting = false;
        });
      }

      print(listOfStates);
    });
  }

  Widget row(String item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            item,
            style: TextStyle(fontSize: 16.0, color: textColor),
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }
}
