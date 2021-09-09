import 'dart:async';
import 'dart:io';

import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/showservice.dart';
import 'package:daily_needs/sub_category/sub_category_reusuable.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/book_service.dart';

import '../daily_homepage.dart';

class ShowSubCategory extends StatefulWidget {
  String category_Id;

  ShowSubCategory({this.category_Id}) : super();

  @override
  ShowSubCategoryState createState() => ShowSubCategoryState();
}

class ShowSubCategoryState extends State<ShowSubCategory> {
  List<Subcategories> subcategories;
  Data data;
  GetAllCategoryServices getCategoryServices;

  @override
  void initState() {
    super.initState();
    subcategories = [];
    getServices();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              "SubCategory",
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()))
              },
            ),
            backgroundColor: primaryRedColor,
          ),
          body: getCategoryServices == null
              ? new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(child: CircularProgressIndicator())
                  ],
                )
              : ListView.builder(
                  itemCount: subcategories.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: textColor, width: 0.5)),
                      ),
                      child: ListTile(
                        title: subcategories[index].subCategory != null
                            ? Text(
                                subcategories[index].subCategory,
                                style: TextStyle(color: textColor),
                              )
                            : Text(""),
                        leading: new Container(
                          child: Image.network(
                            baseUrl + subcategories[index].iconImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: textColor,
                        ),
                        onTap: () {
                          print('SUB CAT ID - ${subcategories[index].id}');
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookService(
                                        subCategory_iD: subcategories[index].id,
                                      )));
                        },
                        contentPadding: EdgeInsets.all(8.0),
                      ),
                    );
                  },
                ),
        ),
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          return true;
        });
  }

  void getServices() {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        if (onResponse.statusCode == "200") {
          setState(() {
            getCategoryServices = onResponse;
            for (var i = 0;
                i < getCategoryServices.data.subcategories.length;
                i++) {
              if (getCategoryServices.data.subcategories[i].catId ==
                  widget.category_Id) {
                subcategories.add(getCategoryServices.data.subcategories[i]);
              }
            }
          });
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
                        getServices();
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
                        getServices();
                      },
                    ),
                  ],
                ));
      }
    });
  }
}
