import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:daily_needs/Map/new_address_ui.dart';
import 'package:daily_needs/daily_homepage.dart';
import 'package:daily_needs/reusuable_widgets/common_loader.dart';
// import 'package:permission/permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/api_model_classes/booking_user_service.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'book_service.dart';
import 'login_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'package:rxdart/rxdart.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:daily_needs/Map/get_location.dart';
import 'package:daily_needs/colors.dart';
import 'model/Update_user_model.dart';
import 'package:toast/toast.dart';
import './../utils.dart' as utils;
import 'package:geocoding/geocoding.dart';

var vendor_web_chat_unique_id;
var vendor_web_chat_name;

class UserLocation extends StatefulWidget {
  String userId;
  String service_id;
  String service_issue;
  String sub_service_ids;
  List<ServiceDatas> sub_serv_ids;
  String service_request_date;
  String imageUrl;

  UserLocation(
      {this.userId,
      this.service_id,
      this.service_issue,
      this.sub_service_ids,
      this.service_request_date,
      this.sub_serv_ids,
      this.imageUrl})
      : super();

  @override
  UserLocationState createState() => UserLocationState();
}

class UserLocationState extends State<UserLocation>
    with TickerProviderStateMixin {
  int _radioValue1 = 0;
  GetDetailModel getUserDetailModel;
  String radioItem = '';
  TextEditingController addresController = new TextEditingController();
  TextEditingController countryController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController stateController = new TextEditingController();
  TextEditingController pincodeController = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> cityKeyAtLoc = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> stateKeyAtLoc = new GlobalKey();
  bool isAccepted = false;
  final firebasedatabase = FirebaseDatabase.instance.reference().child("user");
  bool isNewAddress = false;
  bool isCurrentLocation = false;
  bool isRegisteredAddress = false;
  final Geolocator geolocator = Geolocator();
  String _currentAddress;
  Position _currentPosition;
  String nation;
  String nation_state;
  String locality;
  String subAdministrativeArea;
  String number;
  String street;
  String subLocality;
  String pincode;
  String longi;
  String lati;
  double longi_double;
  double lati_double;
  String order_id;
  Map signUpUserAddress;
  Map loginUserAddress;
  String login_reg_address;
  String signup_reg_address;
  String customerName;
  StreamSubscription<Event> _onDatabaseAddedSubscription;
  StreamSubscription<Event> _onDatabaseChangedSubscription;
  Duration duration = Duration(minutes: 1);
  int levelClock = 180;
  Completer<GoogleMapController> _googleController = Completer();
  Completer<GoogleMapController> _regAddressGoogleController = Completer();
  Completer<GoogleMapController> _newAddressGoogleController = Completer();
  GoogleMapController _gmapController;
  GoogleMapController _gmapControllerForCurrent;
  GoogleMapController _gmapControllerForRegister;
  LatLng _currentTarget;
  LatLng _regTarget;
  LatLng _newTarget;
  static const LatLng _center = const LatLng(45.521563, -122.677433);
  final Set<Marker> _markers = {};
  final Set<Marker> _regMarkers = {};
  final Set<Marker> _newMarkers = {};
  String newAddresslongi;
  String newAddresslatti;
  String regAddresslongi;
  String regAddresslatti;
  String registerUserAddress;
  bool showLocationOptions = false;
  bool initialCurrentLocation = true;
  bool changedRegLocaton = false;
  bool changedNewLocation = false;
  List<String> citiesList = [];
  List<String> stateList = [];
  String citiesDropdownValue = '';
  String stateDropdownValue = '';
  String login_flag = '';
  String socialID = '';
  String detailedAddress;
  String detailedAddressPinCode;
  List<String> servicesID = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.sub_serv_ids.length; i++) {
      servicesID.add(widget.sub_serv_ids[i].parentServiceId);
    }
    servicesID = servicesID.toSet().toList();
    getUserAddress();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController mapController) {
    _googleController.complete(mapController);
  }

  void _regAddressOnMapCreated(GoogleMapController googleMapController) {
    _regAddressGoogleController.complete(googleMapController);
  }

  void _newAddressOnMapCreated(GoogleMapController _googleMapController) {
    _newAddressGoogleController.complete(_googleMapController);
  }

  @override
  void dispose() {
    super.dispose();
    addresController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Location"),
        centerTitle: true,
        backgroundColor: primaryRedColor,
        actions: <Widget>[
          Visibility(
            visible: initialCurrentLocation == false,
            child: IconButton(
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  initialCurrentLocation = true;
                  changedRegLocaton = false;
                  changedNewLocation = false;
                  radioItem = "";
                });
              },
            ),
          )
        ],
      ),
      body: longi == null && lati == null && _markers.length == 0
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            )
          : Stack(
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        SingleChildScrollView(
                          child: Column(
                            children: <Widget>[
                              Visibility(
                                visible: initialCurrentLocation,
                                child: new Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: (longi == null && lati == null)
                                      ? Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height,
                                          child: Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              left: 0.0, right: 0.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.6,
                                                child: GoogleMap(
                                                  myLocationEnabled: true,
                                                  onMapCreated:
                                                      (GoogleMapController
                                                          controller) {
                                                    _gmapControllerForCurrent =
                                                        controller;
                                                  },
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: _currentTarget,
                                                    zoom: 16.0,
                                                  ),
                                                  markers: _markers,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              Visibility(
                                visible: changedNewLocation,
                                child: _newTarget == null &&
                                        _newMarkers.length == 0
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child:
                                                new CircularProgressIndicator(),
                                          )
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            child: GoogleMap(
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                _gmapController = controller;
                                              },
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: _newTarget,
                                                zoom: 16.0,
                                              ),
                                              markers: _newMarkers,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              Visibility(
                                visible: changedRegLocaton,
                                child: _regTarget == null &&
                                        _regMarkers.length == 0
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Center(
                                            child:
                                                new CircularProgressIndicator(),
                                          )
                                        ],
                                      )
                                    : Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.6,
                                            child: GoogleMap(
                                              onMapCreated: (GoogleMapController
                                                  controller) {
                                                _gmapControllerForRegister =
                                                    controller;
                                              },
                                              initialCameraPosition:
                                                  CameraPosition(
                                                target: _regTarget,
                                                zoom: 16.0,
                                              ),
                                              markers: _regMarkers,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    new DraggableScrollableSheet(
                        initialChildSize: 0.4,
                        minChildSize: 0.25,
                        maxChildSize: 0.85,
                        builder: (BuildContext context, myscrollController) {
                          return Container(
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20.0),
                                      topLeft: Radius.circular(20.0)),
                                  color: Colors.white),
                              child: ListView(
                                controller: myscrollController,
                                children: <Widget>[
                                  new Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Icon(
                                            Icons.remove,
                                            color: Colors.grey,
                                          )
                                        ],
                                      ),
                                      new Padding(
                                        padding: EdgeInsets.only(
                                            right: 10.0, left: 10.0),
                                        child: new Text(
                                          "Your Location",
                                          style: TextStyle(
                                            color: textColor,
                                          ),
                                        ),
                                      ),
                                      new SizedBox(
                                        height: 10.0,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, right: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              children: <Widget>[
                                                Visibility(
                                                  visible:
                                                      initialCurrentLocation,
                                                  child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        _currentAddress == null
                                                            ? ""
                                                            : _currentAddress,
                                                        style: TextStyle(
                                                            color: textColor),
                                                      )),
                                                ),
                                                Visibility(
                                                  visible: changedRegLocaton,
                                                  child: new Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: new Text(
                                                      signup_reg_address ??
                                                          login_reg_address,
                                                      style: TextStyle(
                                                          color: textColor),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: changedNewLocation,
                                                  child: new Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6,
                                                    child: new Text(
                                                      detailedAddress == null
                                                          ? ""
                                                          : detailedAddress,
                                                      style: TextStyle(
                                                          color: textColor),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            new InkWell(
                                              child: new Text(
                                                "CHANGE",
                                                style: TextStyle(
                                                    color: primaryRedColor,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  showLocationOptions = true;
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                      new Divider()
                                    ],
                                  ),
                                  new Visibility(
                                    visible: showLocationOptions,
                                    child: new Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        RadioListTile(
                                          groupValue: radioItem,
                                          title: Text(
                                            'New Address',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          value: 'Item 1',
                                          onChanged: (val) {
                                            setState(() {
                                              radioItem = val;
                                              isNewAddress = true;
                                            });
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            NewAddressForMap()))
                                                .then((value) async {
                                              if (value != null) {
                                                if (value) {
                                                  print(
                                                      "value from new address=" +
                                                          value.toString());
                                                  String newLat =
                                                      await get_string_prefs(
                                                          "newAddressLattitude");
                                                  String newLongi =
                                                      await get_string_prefs(
                                                          "newAddressLongitude");
                                                  String addr =
                                                      await get_string_prefs(
                                                          "detailedNewAddress");
                                                  String pin =
                                                      await get_string_prefs(
                                                          "newAddressPincode");
                                                  String newLattitu =
                                                      newLat == ""
                                                          ? null
                                                          : newLat;
                                                  String newLongitu =
                                                      newLongi == ""
                                                          ? null
                                                          : newLongi;
                                                  String addres =
                                                      addr == "" ? null : addr;
                                                  String newpin =
                                                      pin == "" ? null : pin;
                                                  if (newLattitu != null &&
                                                      newLongitu != null) {
                                                    setState(() {
                                                      _newTarget = LatLng(
                                                          double.parse(
                                                              newLattitu),
                                                          double.parse(
                                                              newLongitu));
                                                      _newMarkers.add(Marker(
                                                        markerId: MarkerId(
                                                            _newTarget
                                                                .toString()),
                                                        position: _newTarget,
                                                        infoWindow: InfoWindow(
                                                          title:
                                                              'new address location',
                                                          snippet:
                                                              '5 Star Rating',
                                                        ),
                                                        icon: BitmapDescriptor
                                                            .defaultMarker,
                                                      ));
                                                      newAddresslatti =
                                                          newLattitu;
                                                      newAddresslongi =
                                                          newLongitu;
                                                      detailedAddress = addres;
                                                      detailedAddressPinCode =
                                                          newpin;
                                                      changedNewLocation = true;
                                                      changedRegLocaton = false;
                                                      initialCurrentLocation =
                                                          false;
                                                    });
                                                    print("new location lat =" +
                                                        newLattitu);
                                                    print(
                                                        "new location longi =" +
                                                            newLongitu);
                                                    print(
                                                        "changed new location =" +
                                                            changedNewLocation
                                                                .toString());
                                                    print(
                                                        "changed Reg location=" +
                                                            changedRegLocaton
                                                                .toString());
                                                    print("though initial Current location=" +
                                                        initialCurrentLocation
                                                            .toString());
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  radioItem = "";
                                                });
                                              }
                                            });
                                          },
                                          activeColor: primaryRedColor,
                                        ),
                                        RadioListTile(
                                          groupValue: radioItem,
                                          title: Text(
                                            'Registered Address',
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          value: 'Item 3',
                                          onChanged: (val) async {
                                            String st = await get_string_prefs(
                                                "signUpToken");
                                            String lt = await get_string_prefs(
                                                "loginToken");
                                            String signUpToken =
                                                st == "" ? null : st;
                                            String loginToken =
                                                lt == "" ? null : lt;
                                            getRegisteredLocation(
                                                userId:
                                                    widget.userId.toString(),
                                                token:
                                                    signUpToken ?? loginToken);
                                            setState(() {
                                              radioItem = val;
                                              isNewAddress = false;
                                              changedRegLocaton = true;
                                              initialCurrentLocation = false;
                                              changedNewLocation = false;
                                            });
                                          },
                                          activeColor: primaryRedColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                        }),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(left: 0.0, right: 0.0),
          child: MaterialButton(
            height: 50.0,
            color: primaryRedColor,
            minWidth: double.infinity,
            child: Text(
              "Book Now",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              if (initialCurrentLocation == true) {
                String st = await get_string_prefs("signUpToken");
                String lt = await get_string_prefs("loginToken");
                String signUpToken = st == "" ? null : st;
                String loginToken = lt == "" ? null : lt;
                String user_name = await get_string_prefs("user_name");
                setState(() {
                  customerName = user_name;
                });
                if (servicesID.length != 0) {
                  for (var i = 0; i < servicesID.length; i++) {
                    String subServiceIDs;
                    List<int> strArr = [];
                    strArr.add(i);
                    for (var j = 0; j < widget.sub_serv_ids.length; j++) {
                      print(j);
                      if (servicesID[i] ==
                          widget.sub_serv_ids[j].parentServiceId) {
                        if (subServiceIDs == null) {
                          subServiceIDs =
                              '${widget.sub_serv_ids[j].serviceIDs}';
                        } else {
                          subServiceIDs =
                              "${subServiceIDs},${widget.sub_serv_ids[j].serviceIDs}";
                        }
                      }
                    }
                    print('${servicesID[i]} -- > ${subServiceIDs}');
                    print(servicesID.length);
                    print(i);
                    if (i == (servicesID.length - 1)) {
                      _addUserServices(
                        userId: widget.userId.toString(),
                        zipcode: pincode.toString(),
                        issueDescription: widget.service_issue,
                        issueImgURL: widget.imageUrl,
                        service_request_date: widget.service_request_date,
                        serviceId: servicesID[i],
                        sub_ser_Id: subServiceIDs,
                        service_type: widget.service_issue,
                        address: _currentAddress,
                        lattitude: lati.toString(),
                        longitude: longi.toString(),
                        token: signUpToken ?? loginToken,
                      );
                    } else {
                      _addUserService(
                        userId: widget.userId.toString(),
                        zipcode: pincode.toString(),
                        issueDescription: widget.service_issue,
                        issueImgURL: widget.imageUrl,
                        service_request_date: widget.service_request_date,
                        serviceId: servicesID[i],
                        sub_ser_Id: subServiceIDs,
                        service_type: widget.service_issue,
                        address: _currentAddress,
                        lattitude: lati.toString(),
                        longitude: longi.toString(),
                        token: signUpToken ?? loginToken,
                      );
                    }
                  }
                }
              }
              if (changedNewLocation == true) {
                String address = addresController.text.toString();
                String st = await get_string_prefs("signUpToken");
                String lt = await get_string_prefs("loginToken");
                String signUpToken = st == "" ? null : st;
                String loginToken = lt == "" ? null : lt;
                String user_name = await get_string_prefs("user_name");
                setState(() {
                  customerName = user_name;
                });
                if (servicesID.length != 0) {
                  for (var i = 0; i < servicesID.length; i++) {
                    String subServiceIDs;
                    for (var j = 0; j < widget.sub_serv_ids.length; j++) {
                      if (servicesID[i] ==
                          widget.sub_serv_ids[j].parentServiceId) {
                        if (subServiceIDs == null) {
                          subServiceIDs =
                              '${widget.sub_serv_ids[j].serviceIDs}';
                        } else {
                          subServiceIDs =
                              "${subServiceIDs},${widget.sub_serv_ids[j].serviceIDs}";
                        }
                      }
                    }
                    print('${servicesID[i]} -- > ${subServiceIDs}');
                    _addUserService(
                      userId: widget.userId.toString(),
                      zipcode: detailedAddressPinCode,
                      issueDescription: widget.service_issue,
                      issueImgURL: widget.imageUrl,
                      service_request_date: widget.service_request_date,
                      serviceId: servicesID[i],
                      sub_ser_Id: subServiceIDs,
                      service_type: widget.service_issue,
                      address: detailedAddress,
                      lattitude: newAddresslatti,
                      longitude: newAddresslongi,
                      token: signUpToken ?? loginToken,
                    );
                  }
                }
              }
              if (changedRegLocaton == true) {
                String st = await get_string_prefs("signUpToken");
                String lt = await get_string_prefs("loginToken");
                String signUpToken = st == "" ? null : st;
                String loginToken = lt == "" ? null : lt;
                String user_name = await get_string_prefs("user_name");
                setState(() {
                  customerName = user_name;
                });

                if (servicesID.length != 0) {
                  for (var i = 0; i < servicesID.length; i++) {
                    String subServiceIDs;
                    for (var j = 0; j < widget.sub_serv_ids.length; j++) {
                      if (servicesID[i] ==
                          widget.sub_serv_ids[j].parentServiceId) {
                        if (subServiceIDs == null) {
                          subServiceIDs =
                              '${widget.sub_serv_ids[j].serviceIDs}';
                        } else {
                          subServiceIDs =
                              "${subServiceIDs},${widget.sub_serv_ids[j].serviceIDs}";
                        }
                      }
                    }
                    print('${servicesID[i]} -- > ${subServiceIDs}');
                    _addUserService(
                      userId: widget.userId.toString(),
                      longitude: regAddresslongi.toString(),
                      lattitude: regAddresslatti.toString(),
                      address: signUpUserAddress == null
                          ? loginUserAddress["data"]["user"][0]["address"]
                              .toString()
                          : signUpUserAddress["data"]["user_details"][0]
                                  ["address"]
                              .toString(),
                      zipcode: signUpUserAddress == null
                          ? loginUserAddress["data"]["user"][0]["zipcode"]
                              .toString()
                          : signUpUserAddress["data"]["user_details"][0]
                                  ["zipcode"]
                              .toString(),
                      service_type: widget.service_issue,
                      sub_ser_Id: subServiceIDs,
                      serviceId: servicesID[i],
                      service_request_date: widget.service_request_date,
                      issueImgURL: widget.imageUrl,
                      issueDescription: widget.service_issue,
                      token: signUpToken ?? loginToken,
                    );
                  }
                }
              }
            },
          )),
    );
  }

  _getCurrentLocation() async {
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
    // if (Platform.isAndroid) {
    //   var permissions =
    //       await Permission.getPermissionsStatus([PermissionName.Location]);
    //   print(permissions[0].permissionStatus.toString() +
    //       "this is the location code");
    //   if (permissions[0].permissionStatus == PermissionStatus.notAgain) {
    //     var askpermissions =
    //         await Permission.requestPermissions([PermissionName.Location]);
    //   }
    //   print("is you get permission " +
    //       geolocator.isLocationServiceEnabled().toString());
    //   print("i don't know what is this  " +
    //       geolocator
    //           .checkGeolocationPermissionStatus(
    //               locationPermission: GeolocationPermission.location)
    //           .toString());
    // } else {
    //   // await Permission.locationWhenInUse.isGranted;
    //   print('test by mani-${Platform.environment}');
    // }
    utils.checkPermission(Permission.locationWhenInUse).then((value) {
      if (value != null) {
        Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          forceAndroidLocationManager: true,
        ).then((Position position) {
          setState(() {
            _currentPosition = position;
            longi = _currentPosition.longitude.toString();
            lati = _currentPosition.latitude.toString();
            _currentTarget =
                LatLng(_currentPosition.latitude, _currentPosition.longitude);
            _markers.add(Marker(
              markerId: MarkerId(_currentTarget.toString()),
              position: _currentTarget,
              infoWindow: InfoWindow(
                title: 'current location',
              ),
              icon: BitmapDescriptor.defaultMarker,
            ));
          });
          print(_currentPosition.latitude);
          print(_currentPosition.longitude);
          getCurrentAddressFromLatLng();
        }).catchError((e) {
          print(e);
        });
      }
    });
  }

  getCurrentAddressFromLatLng() async {
    try {
      var p = await placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      var place = p[0];

      setState(() {
        nation = place.country;
        nation_state = place.administrativeArea;
        locality = place.locality;
        subAdministrativeArea = place.subAdministrativeArea;
        street = place.thoroughfare;
        number = place.subThoroughfare;
        subLocality = place.subLocality;
        pincode = place.postalCode;
        _currentAddress =
            "${number.isEmpty ? '' : number + ','}${street.isEmpty ? '' : street + ','}${locality.isEmpty ? '' : locality + ','}${subAdministrativeArea.isEmpty ? '' : subAdministrativeArea}${pincode.isEmpty ? '' : '-' + pincode + ','}${nation_state.isEmpty ? '' : nation_state + ','}${nation.isEmpty ? '' : nation}.";
      });
      print(_currentAddress);
    } catch (e) {
      print(e);
    }
  }

  void _addUserServices(
      {String userId,
      String serviceId,
      String service_type,
      String service_request_date,
      String issueDescription,
      String lattitude,
      String longitude,
      String address,
      String zipcode,
      String sub_ser_Id,
      String issueImgURL,
      String token}) {
    bookUserService(
            longitude: longitude,
            lattitude: lattitude,
            address: address,
            service_type: service_type,
            sub_ser_Id: sub_ser_Id,
            serviceId: serviceId,
            service_request_date: service_request_date,
            issueImgURL: issueImgURL,
            issueDescription: issueDescription,
            zipcode: zipcode,
            userId: userId,
            token: token)
        .then((onResponse) async {
      print(onResponse.toString());
      if (onResponse is BookUserService) {
        print(onResponse.data.message);
        if (onResponse.statusCode == "200") {
          order_id = onResponse.data.orderId.toString();
          vendor_web_chat_unique_id = onResponse.data.chatRoom;
          vendor_web_chat_name = onResponse.data.closestVendor.firstName;
          print(vendor_web_chat_unique_id);
          firebasedatabase.child(onResponse.data.orderId.toString()).set({
            "Latitude": onResponse.data.closestVendor.latitude,
            "Longitude": onResponse.data.closestVendor.longitude,
            "is_order_placed": "Y",
            "is_vendor_accepted": "N"
          });
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(onResponse.data.service_name),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: onResponse.data.message,
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                      ),
                    ],
                  ));
        } else {}

        if (onResponse.statusCode == "100") {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(onResponse.data.service_name),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: onResponse.data.message,
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                      ),
                    ],
                  ));
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
                _addUserServices(
                    token: newToken,
                    userId: userId,
                    zipcode: zipcode,
                    issueDescription: issueDescription,
                    issueImgURL: issueImgURL,
                    service_request_date: service_request_date,
                    serviceId: serviceId,
                    sub_ser_Id: sub_ser_Id,
                    service_type: service_type,
                    address: address,
                    lattitude: lattitude,
                    longitude: longitude);
                print("last token has expired and new token has added");
              }
            }
          }).catchError((onError) {
            Navigator.pop(context);

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
                            child: Text('RETRY',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                              _addUserServices(
                                  userId: userId,
                                  token: token,
                                  issueDescription: issueDescription,
                                  issueImgURL: issueImgURL,
                                  service_request_date: service_request_date,
                                  serviceId: serviceId,
                                  sub_ser_Id: sub_ser_Id,
                                  service_type: service_type,
                                  zipcode: zipcode,
                                  address: address,
                                  lattitude: lattitude,
                                  longitude: longitude);
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
                            child: Text('RETRY',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()));
                              _addUserServices(
                                  userId: userId,
                                  token: token,
                                  issueDescription: issueDescription,
                                  issueImgURL: issueImgURL,
                                  service_request_date: service_request_date,
                                  serviceId: serviceId,
                                  sub_ser_Id: sub_ser_Id,
                                  service_type: service_type,
                                  zipcode: zipcode,
                                  address: address,
                                  lattitude: lattitude,
                                  longitude: longitude);
                            },
                          ),
                        ],
                      ));
            }
          });
        }
      }
    }).catchError((onError) {
      Navigator.pop(context);
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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                        _addUserServices(
                            userId: userId,
                            token: token,
                            issueDescription: issueDescription,
                            issueImgURL: issueImgURL,
                            service_request_date: service_request_date,
                            serviceId: serviceId,
                            sub_ser_Id: sub_ser_Id,
                            service_type: service_type,
                            zipcode: zipcode,
                            address: address,
                            lattitude: lattitude,
                            longitude: longitude);
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
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                        _addUserServices(
                            userId: userId,
                            token: token,
                            issueDescription: issueDescription,
                            issueImgURL: issueImgURL,
                            service_request_date: service_request_date,
                            serviceId: serviceId,
                            sub_ser_Id: sub_ser_Id,
                            service_type: service_type,
                            zipcode: zipcode,
                            address: address,
                            lattitude: lattitude,
                            longitude: longitude);
                      },
                    ),
                  ],
                ));
      }
    });
  }

  void _addUserService(
      {String userId,
      String serviceId,
      String service_type,
      String service_request_date,
      String issueDescription,
      String lattitude,
      String longitude,
      String address,
      String zipcode,
      String sub_ser_Id,
      String issueImgURL,
      String token}) {
    bookUserService(
            longitude: longitude,
            lattitude: lattitude,
            address: address,
            service_type: service_type,
            sub_ser_Id: sub_ser_Id,
            serviceId: serviceId,
            service_request_date: service_request_date,
            issueImgURL: issueImgURL,
            issueDescription: issueDescription,
            zipcode: zipcode,
            userId: userId,
            token: token)
        .then((onResponse) async {
      if (onResponse is BookUserService) {
        if (onResponse.statusCode == "200") {
          order_id = onResponse.data.orderId.toString();
          vendor_web_chat_unique_id = onResponse.data.chatRoom;
          vendor_web_chat_name = onResponse.data.closestVendor.firstName;
          print(vendor_web_chat_unique_id);
          firebasedatabase.child(onResponse.data.orderId.toString()).set({
            "Latitude": onResponse.data.closestVendor.latitude,
            "Longitude": onResponse.data.closestVendor.longitude,
            "is_order_placed": "Y",
            "is_vendor_accepted": "N"
          });
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(onResponse.data.service_name),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: onResponse.data.message,
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomePage()));
                        },
                      ),
                    ],
                  ));
        } else {}

        if (onResponse.statusCode == "100") {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: new Text(onResponse.data.service_name),
                    content: new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CustomDialogue(
                          isSimpleDialogue: true,
                          message: onResponse.data.message,
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
                        },
                      ),
                    ],
                  ));
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
                _addUserService(
                    token: newToken,
                    userId: userId,
                    zipcode: zipcode,
                    issueDescription: issueDescription,
                    issueImgURL: issueImgURL,
                    service_request_date: service_request_date,
                    serviceId: serviceId,
                    sub_ser_Id: sub_ser_Id,
                    service_type: service_type,
                    address: address,
                    lattitude: lattitude,
                    longitude: longitude);
              }
            }
          }).catchError((onError) {
            Navigator.pop(context);

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
                            child: Text('RETRY',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _addUserService(
                                  userId: userId,
                                  token: token,
                                  issueDescription: issueDescription,
                                  issueImgURL: issueImgURL,
                                  service_request_date: service_request_date,
                                  serviceId: serviceId,
                                  sub_ser_Id: sub_ser_Id,
                                  service_type: service_type,
                                  zipcode: zipcode,
                                  address: address,
                                  lattitude: lattitude,
                                  longitude: longitude);
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
                            child: Text('RETRY',
                                style: TextStyle(color: primaryColor)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _addUserService(
                                  userId: userId,
                                  token: token,
                                  issueDescription: issueDescription,
                                  issueImgURL: issueImgURL,
                                  service_request_date: service_request_date,
                                  serviceId: serviceId,
                                  sub_ser_Id: sub_ser_Id,
                                  service_type: service_type,
                                  zipcode: zipcode,
                                  address: address,
                                  lattitude: lattitude,
                                  longitude: longitude);
                            },
                          ),
                        ],
                      ));
            }
          });
        }
      }
    }).catchError((onError) {
      Navigator.pop(context);
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
                        _addUserService(
                            userId: userId,
                            token: token,
                            issueDescription: issueDescription,
                            issueImgURL: issueImgURL,
                            service_request_date: service_request_date,
                            serviceId: serviceId,
                            sub_ser_Id: sub_ser_Id,
                            service_type: service_type,
                            zipcode: zipcode,
                            address: address,
                            lattitude: lattitude,
                            longitude: longitude);
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
                        _addUserService(
                            userId: userId,
                            token: token,
                            issueDescription: issueDescription,
                            issueImgURL: issueImgURL,
                            service_request_date: service_request_date,
                            serviceId: serviceId,
                            sub_ser_Id: sub_ser_Id,
                            service_type: service_type,
                            zipcode: zipcode,
                            address: address,
                            lattitude: lattitude,
                            longitude: longitude);
                      },
                    ),
                  ],
                ));
      }
    });
  }

  void getUserAddress() async {
    login_flag = await get_string_prefs("loginFlag");
    socialID = await get_string_prefs("social_id");
    String suseradd = await get_string_prefs("signupuser");
    String luseradd = await get_string_prefs("loginuser");
    String signUpUser = suseradd == "" ? null : suseradd;
    String logUser = luseradd == "" ? null : luseradd;
    citiesList = await get_stringList_pref("cities");
    stateList = await get_stringList_pref("state");

    if (signUpUser != null) {
      setState(() {
        signUpUserAddress = json.decode(signUpUser);
        signup_reg_address =
            signUpUserAddress["data"]["user_details"][0]["address"].toString();
        citiesDropdownValue = citiesList[198];
        stateDropdownValue = stateList[30];
      });
    }
    if (logUser != null) {
      setState(() {
        loginUserAddress = json.decode(logUser);
        login_reg_address = loginUserAddress["data"]["user"][0]["address"];
        citiesDropdownValue = citiesList[198];
        stateDropdownValue = stateList[30];
      });
    }
  }

  void getLongiLatti(
      {String addControl,
      String cityControl,
      String stateControl,
      String pinControl,
      String token,
      String flag}) async {
    String newAddress = addControl.toString() +
        cityControl.toString() +
        stateControl.toString() +
        pinControl.toString();
    List<String> cities = [addControl, cityControl, stateControl, pinControl];
    String editAdderss = cities.join(",");
    print(editAdderss);
    Geolocator.getPositionStream().listen((position) {});
    var placemark1 = await locationFromAddress(
        "3/57,Mettu Street,Kazhipattur,Kanchipuram,603103,Tamil Nadu");
    print(placemark1);
    print("check accurate longitude " + placemark1[0].longitude.toString());
    print("check accurate longitude " + placemark1[0].latitude.toString());
    var placemark = await locationFromAddress(editAdderss);
    _currentTarget =
        LatLng(_currentPosition.latitude, _currentPosition.longitude);

    setState(() {
      if (flag == "register") {
        _regTarget = LatLng(placemark[0].latitude, placemark[0].longitude);
        _regMarkers.add(Marker(
          markerId: MarkerId(_regTarget.toString()),
          position: _regTarget,
          infoWindow: InfoWindow(
            title: 'Registered location',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ));
      }
      if (flag == "register") {
        setState(() {
          regAddresslongi = placemark[0].longitude.toString();
          regAddresslatti = placemark[0].latitude.toString();
        });
      }
    });

    print("changed address longi and latti $newAddresslongi $newAddresslatti");
  }

  Future<void> getRegisteredLocation({String userId, String token}) async {
    getUserDetailsbyID(user_id: widget.userId.toString(), token: token)
        .then((onResult) async {
      if (onResult is GetDetailModel) {
        if (onResult.data.message == "User details is retrieved Successfully") {
          setState(() {
            getUserDetailModel = onResult;
            registerUserAddress =
                getUserDetailModel.data.userDetails[0].address2;
          });
          print(getUserDetailModel);
          getLongiLatti(
              token: token,
              pinControl: getUserDetailModel.data.userDetails[0].zipcode,
              stateControl: getUserDetailModel.data.userDetails[0].state,
              cityControl: getUserDetailModel.data.userDetails[0].city,
              addControl: getUserDetailModel.data.userDetails[0].address,
              flag: "register");
        }
      }
      if (onResult is int) {
        if (onResult == 401) {
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
                  getUserDetailsbyID(
                          token: newToken, user_id: widget.userId.toString())
                      .then((onResponseValue) {
                    if (onResponseValue is GetDetailModel) {
                      if (onResponseValue.data.message ==
                          "User details is retrieved Successfully") {
                        setState(() {
                          getUserDetailModel = onResponseValue;
                        });
                        print(getUserDetailModel);
                        getLongiLatti(
                            token: newToken,
                            pinControl:
                                getUserDetailModel.data.userDetails[0].zipcode,
                            stateControl:
                                getUserDetailModel.data.userDetails[0].state,
                            cityControl:
                                getUserDetailModel.data.userDetails[0].city,
                            addControl:
                                getUserDetailModel.data.userDetails[0].address,
                            flag: "register");
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
                .then((onValue) {
              if (onValue is LoginModel) {
                if (onValue.data.message == "Login Successfully") {
                  String loginDetails = json.encode(onValue);
                  Map getToken = json.decode(loginDetails);
                  String newToken = getToken["data"]["access_token"];
                  getUserDetailsbyID(
                          token: newToken, user_id: widget.userId.toString())
                      .then((onResponseValue) {
                    if (onResponseValue is GetDetailModel) {
                      if (onResponseValue.data.message ==
                          "User details is retrieved Successfully") {
                        setState(() {
                          getUserDetailModel = onResponseValue;
                        });
                        print(getUserDetailModel);
                        getLongiLatti(
                            token: newToken,
                            pinControl:
                                getUserDetailModel.data.userDetails[0].zipcode,
                            stateControl:
                                getUserDetailModel.data.userDetails[0].state,
                            cityControl:
                                getUserDetailModel.data.userDetails[0].city,
                            addControl:
                                getUserDetailModel.data.userDetails[0].address,
                            flag: "register");
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

class Countdown extends AnimatedWidget {
  Countdown({Key key, this.animation}) : super(key: key, listenable: animation);
  Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      "$timerText",
      style: TextStyle(
          fontSize: 15.0, color: Colors.grey, fontWeight: FontWeight.bold),
    );
  }
}
