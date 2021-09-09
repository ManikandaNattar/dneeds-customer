import 'dart:async';
import 'dart:io';

import 'package:daily_needs/api.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:geocoding/geocoding.dart';
import '../colors.dart';
import '../getAllCategoryService.dart';
import 'package:toast/toast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:daily_needs/save_storage/save_storage.dart';

class NewAddressForMap extends StatefulWidget {
  @override
  State createState() => NewAddressForMapState();
}

class NewAddressForMapState extends State<NewAddressForMap> {
  TextEditingController addresController = new TextEditingController();
  TextEditingController countryController = new TextEditingController();
  TextEditingController cityController = new TextEditingController();
  TextEditingController stateController = new TextEditingController();
  TextEditingController pincodeController = new TextEditingController();
  final Geolocator geolocator = Geolocator();
  StreamSubscription<Position> _lattiLongiStream;
  GlobalKey<AutoCompleteTextFieldState<String>> cityKeyAtLoc = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> stateKeyAtLoc = new GlobalKey();

  List<String> citiesList = [];
  List<String> stateList = [];
  GetAllCategoryServices getCategoryServicesForCities;
  String newaddLatitude;
  String newaddLongitude;
  String fullDetailedAddress;
  String newaddPincode;

  @override
  void initState() {
    super.initState();
    getCitiesAndStates();
  }

  @override
  void dispose() {
    super.dispose();
    if (_lattiLongiStream != null) {
      _lattiLongiStream.cancel();
    }
    newaddLatitude = null;
    newaddLongitude = null;
    fullDetailedAddress = null;
    newaddPincode = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New Address"),
        centerTitle: true,
        backgroundColor: primaryRedColor,
        automaticallyImplyLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 30.0,
            ),
            Container(
              child: TextField(
                controller: pincodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: "Enter Zipcode",
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey))),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              child: TextField(
                controller: addresController,
                decoration: InputDecoration(
                    hintText: "Enter Address",
                    hintStyle: TextStyle(color: Colors.grey),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey))),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: AutoCompleteTextField<String>(
                controller: cityController,
                key: cityKeyAtLoc,
                clearOnSubmit: false,
                suggestions: citiesList,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  hintText: "City",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                itemFilter: (item, query) {
                  return item.toLowerCase().startsWith(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.compareTo(b);
                },
                itemSubmitted: (item) {
                  setState(() {
                    cityController.text = item;
                  });
                },
                itemBuilder: (context, item) {
                  return row(item);
                },
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 0.0, right: 0.0),
              child: AutoCompleteTextField<String>(
                controller: stateController,
                key: stateKeyAtLoc,
                clearOnSubmit: false,
                suggestions: stateList,
                style: TextStyle(color: Colors.black, fontSize: 16.0),
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  hintText: "State",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                itemFilter: (item, query) {
                  return item.toLowerCase().startsWith(query.toLowerCase());
                },
                itemSorter: (a, b) {
                  return a.compareTo(b);
                },
                itemSubmitted: (item) {
                  setState(() {
                    stateController.text = item;
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
          ],
        ),
      ),
      bottomNavigationBar: MaterialButton(
        minWidth: double.infinity,
        height: 50.0,
        child: new Text(
          "Confirm Address",
          style: TextStyle(color: Colors.white),
        ),
        color: primaryRedColor,
        onPressed: () {
          if (!addresController.text.isEmpty &&
              !cityController.text.isEmpty &&
              !stateController.text.isEmpty &&
              !pincodeController.text.isEmpty) {
            getLatLongFromGivenAddress(
                addControl: addresController.text,
                cityControl: cityController.text,
                stateControl: stateController.text,
                pinControl: pincodeController.text);
          } else {
            Toast.show("Please fill all details", context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          }
        },
      ),
    );
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

  void getCitiesAndStates() async {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        print(onResponse.statusCode);

        setState(() {
          getCategoryServicesForCities = onResponse;
          for (var i = 0;
              i < getCategoryServicesForCities.data.cities.length;
              i++) {
            citiesList.add(getCategoryServicesForCities.data.cities[i].city);
          }
          for (var i = 0;
              i < getCategoryServicesForCities.data.states.length;
              i++) {
            stateList.add(getCategoryServicesForCities.data.states[i].state);
          }
        });
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
                        getCitiesAndStates();
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
                        getCitiesAndStates();
                      },
                    ),
                  ],
                ));
      }
    });
    ;
  }

  void getLatLongFromGivenAddress({
    String addControl,
    String cityControl,
    String stateControl,
    String pinControl,
  }) async {
    String newAddress = addControl.toString() +
        ',' +
        cityControl.toString() +
        '-' +
        pinControl.toString() +
        ',' +
        stateControl.toString() +
        '.';
    List<String> cities = [addControl, cityControl, stateControl, pinControl];
    String editAdderss = cities.join(",");
    var placemark = await locationFromAddress(editAdderss);
    print(placemark[0].longitude);
    print(placemark[0].latitude);
    save_string_prefs("newAddressLattitude", placemark[0].latitude.toString());
    save_string_prefs("newAddressLongitude", placemark[0].longitude.toString());
    save_string_prefs("detailedNewAddress", newAddress);
    save_string_prefs("newAddressPincode", pincodeController.text);
    print(newAddress);
    print(editAdderss);
    String testlat = await get_string_prefs("newAddressLattitude");
    String testlongi = await get_string_prefs("newAddressLongitude");
    String testaddress = await get_string_prefs("detailedNewAddress");
    String testPincode = await get_string_prefs("newAddressPincode");
    setState(() {
      newaddLatitude = testlat;
      newaddLongitude = testlongi;
      fullDetailedAddress = testaddress;
      newaddPincode = testPincode;
    });
    print("testlat=" + testlat);
    if (newaddLatitude != null &&
        newaddLongitude != null &&
        fullDetailedAddress != null &&
        newaddPincode != null) {
      Navigator.of(context).pop(true);
    }
  }
}
