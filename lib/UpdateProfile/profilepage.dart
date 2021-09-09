import 'package:daily_needs/model/User_detail_model.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../api.dart';
import 'package:daily_needs/model/Update_user_model.dart';
import 'package:daily_needs/colors.dart';
import 'package:toast/toast.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

import '../daily_homepage.dart';

class ProfilePage extends StatefulWidget {
  String userId;
  String lastname;
  String country;
  String usertypeId;
  GetDetailModel getDetailModel;

  ProfilePage({this.getDetailModel}) : super();

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<ProfilePage> {
  TextEditingController _email = new TextEditingController();
  TextEditingController _name = new TextEditingController();
  TextEditingController _address = new TextEditingController();
  TextEditingController _mobileno = new TextEditingController();
  TextEditingController _city = new TextEditingController();
  TextEditingController _state = new TextEditingController();
  TextEditingController _pincode = new TextEditingController();
  AutoCompleteTextField searchTextField;
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  GlobalKey<AutoCompleteTextFieldState<String>> stateKey = new GlobalKey();
  bool _evalidate = false;
  bool _mvalidate = false;
  bool _avalidate = false;
  bool _nvalidate = false;
  bool _cvalidate = false;
  bool _svalidate = false;
  bool _pvalidate = false;
  var isLoading = false;
  String citiesDropDownValues = "";
  String statesDropDownValues = "";
  List<String> listOfStates = [];
  List<String> listOfCities = [];

  @override
  void initState() {
    _name.text = widget.getDetailModel.data.userDetails[0].firstName;
    _email.text = widget.getDetailModel.data.userDetails[0].email;
    _mobileno.text = widget.getDetailModel.data.userDetails[0].mobileNo != null
        ? widget.getDetailModel.data.userDetails[0].mobileNo
        : "";
    _address.text = widget.getDetailModel.data.userDetails[0].address;
    _city.text = widget.getDetailModel.data.userDetails[0].city;
    _state.text = widget.getDetailModel.data.userDetails[0].state;
    _pincode.text = widget.getDetailModel.data.userDetails[0].zipcode;
    getCitiesAndStates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        centerTitle: true,
        title: Text("Update Profile",
            style: new TextStyle(
                fontSize: 17.0,
                color: Colors.white,
                fontWeight: FontWeight.w900)),
      ),
      body: listOfCities.length == 0 && listOfStates.length == 0
          ? CircularProgressIndicator()
          : isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  backgroundColor: primaryRedColor,
                ))
              : Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 5.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: new TextFormField(
                                controller: _name,
                                style: TextStyle(height: 2.0),
                                keyboardType: TextInputType.text,
                                decoration: new InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    errorText: _nvalidate ? "Enter Name" : null,
                                    hintText: 'Name',
                                    labelStyle: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: new TextField(
                                controller: _email,
                                style: TextStyle(height: 2.0),
                                keyboardType: TextInputType.emailAddress,
                                decoration: new InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey)),
                                  hintText: 'Email',
                                  labelStyle: TextStyle(color: Colors.grey),
                                  errorText: _evalidate ? "Enter Email" : null,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: new TextField(
                                style: TextStyle(height: 2.0),
                                controller: _mobileno,
                                keyboardType: TextInputType.number,
                                decoration: new InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                    errorText: _mvalidate
                                        ? "Enter MobileNumber"
                                        : null,
                                    hintText: 'Mobile Number',
                                    counterText: "",
                                    labelStyle: TextStyle(color: Colors.grey)),
                                maxLength: 10,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: new TextFormField(
                                style: TextStyle(height: 2.0),
                                controller: _address,
                                keyboardType: TextInputType.text,
                                decoration: new InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    errorText:
                                        _avalidate ? "Enter Address" : null,
                                    hintText: ' Address',
                                    labelStyle: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: AutoCompleteTextField<String>(
                              controller: _city,
                              key: key,
                              clearOnSubmit: false,
                              suggestions: listOfCities,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
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
                                  _city.text = item;
                                });
                              },
                              itemBuilder: (context, item) {
                                return row(item);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, right: 30.0),
                            child: Container(
                              child: new TextFormField(
                                controller: _pincode,
                                style: TextStyle(height: 2.0),
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                decoration: new InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    counterText: "",
                                    errorText:
                                        _pvalidate ? "Enter Pincode" : null,
                                    hintText: 'Pincode',
                                    labelStyle: TextStyle(color: Colors.grey)),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 30.0, right: 30.0),
                            child: AutoCompleteTextField<String>(
                              controller: _state,
                              key: stateKey,
                              clearOnSubmit: false,
                              suggestions: listOfStates,
                              style: TextStyle(
                                  color: Colors.black, fontSize: 16.0),
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
                                  _state.text = item;
                                });
                              },
                              itemBuilder: (context, item) {
                                return row(item);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 150.0,
                          ),
                        ]),
                  ),
                ),
      bottomNavigationBar: MaterialButton(
        minWidth: double.infinity,
        height: 50.0,
        onPressed: () {
          setState(() {
            _email.text.isEmpty ? _evalidate = true : null;
            _mobileno.text.isEmpty ? _mvalidate = true : null;
            _address.text.isEmpty ? _avalidate = true : null;
            _name.text.isEmpty ? _nvalidate = true : null;
            _pincode.text.isEmpty ? _pvalidate = true : null;
          });
          if (!(_email.text.isEmpty &&
                  _name.text.isEmpty &&
                  _address.text.isEmpty &&
                  _mobileno.text.isEmpty &&
                  _state.text.isEmpty &&
                  _city.text.isEmpty &&
                  _pincode.text.isEmpty) &&
              _mobileno.text.length == 10) {
            setState(() {
              isLoading = true;
            });
            Profile(
                id: widget.getDetailModel.data.userDetails[0].id,
                usertype_id:
                    widget.getDetailModel.data.userDetails[0].usertypeId,
                email: _email.text.toString(),
                mobileno: _mobileno.text,
                first_name: _name.text,
                last_name: widget.getDetailModel.data.userDetails[0].lastName,
                address: _address.text,
                city: _city.text,
                state: _state.text,
                zipcode: _pincode.text,
                country: widget.getDetailModel.data.userDetails[0].country);
          }
        },
        color: primaryRedColor,
        child: Text(
          "Update Profile",
          style: new TextStyle(color: Colors.white, fontSize: 20.0),
        ),
        splashColor: Colors.white,
      ),
    );
  }

  void Profile(
      {String id,
      String usertype_id,
      String email,
      String mobileno,
      String first_name,
      String last_name,
      String address,
      String city,
      String state,
      String zipcode,
      String country}) {
    Userdetail(
            id: id,
            usertype_id: usertype_id,
            email: email,
            mobileno: mobileno,
            first_name: first_name,
            last_name: last_name,
            address: address,
            city: city,
            state: state,
            zipcode: zipcode,
            country: country)
        .then((onResponse) {
      setState(() {
        isLoading = false;
      });
      print(onResponse);
      if (onResponse is UserDetail) {
        if (onResponse.data.message == "User details updated Successfully") {
          setState(() {
            Toast.show(onResponse.data.message, context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
          });
        } else {
          setState(() {
            Toast.show(onResponse.data.message, context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          });
        }
      }
    });
  }

  void getCitiesAndStates() async {
    var citiesList = await get_stringList_pref("cities");
    var stateList = await get_stringList_pref("state");
    setState(() {
      listOfCities.addAll(citiesList);
      listOfStates.addAll(stateList);
      if (listOfCities
          .contains(widget.getDetailModel.data.userDetails[0].city)) {
        int ind = listOfCities
            .indexOf(widget.getDetailModel.data.userDetails[0].city);
        citiesDropDownValues = listOfCities.elementAt(ind);
      } else {
        listOfCities.add(widget.getDetailModel.data.userDetails[0].city);
        citiesDropDownValues = listOfCities.last;
      }
      if (widget.getDetailModel.data.userDetails[0].state == "Tamilnadu" ||
          widget.getDetailModel.data.userDetails[0].state == "Tamil Nadu") {
        widget.getDetailModel.data.userDetails[0].state = "Tamil Nadu";
      }
      int indexes =
          listOfStates.indexOf(widget.getDetailModel.data.userDetails[0].state);
      statesDropDownValues = listOfStates.elementAt(indexes);
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
