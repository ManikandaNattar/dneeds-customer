import 'dart:convert';
import 'package:daily_needs/get_user_location.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/signup.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/add_to_cart/add_to_cart.dart';
import 'package:daily_needs/add_to_cart/reusuable_cart.dart';
import 'package:toast/toast.dart';

class BookServiceReusable extends StatefulWidget {
  SubServices subServices;
  String service_name;
  String service_id;
  String service_price;

  BookServiceReusable(
      {this.subServices,
      this.service_name,
      this.service_id,
      this.service_price})
      : super();

  @override
  BookServiceReusableState createState() => BookServiceReusableState();
}

class BookServiceReusableState extends State<BookServiceReusable> {
  GetAllCategoryServices getCategoryServices;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map checkUser;
  String signUpUser;
  String loginUser;
  int count = 0;
  String subServiceId;
  SubServices subServiceList;
  List<String> idList = [];
  List<ServiceData> servicedataList = [];
  List<SubServices> subServicesMappingList = [];
  bool isAddClick = false;
  Map buttonClick;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Card(
            elevation: 10.0,
            shadowColor: Colors.white70,
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      child: Image.asset(
                        "images/flight.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.subServices.subService,
                            style: TextStyle(fontSize: 15.0),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            widget.subServices.price,
                            style: TextStyle(
                                fontSize: 12.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(widget.subServices.description)
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 30.0, bottom: 5.0),
                      child: MaterialButton(
                        child: Text(
                          "ADD +",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.orange,
                        onPressed: () async {
                          setState(() {
                            if (!idList.contains(widget.subServices.id)) {
                              idList.add(widget.subServices.id);
                            }

                            subServicesMappingList.add(widget.subServices);
                            servicedataList.add(ServiceData(
                                service_Id: widget.service_id,
                                serviceName: widget.service_name,
                                subServiceIds: idList,
                                subServices: subServicesMappingList));
                            subServiceId = widget.subServices.id;
                            subServiceList = widget.subServices;
                            isAddClick = true;
                          });
                        },
                        minWidth: 40.0,
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
