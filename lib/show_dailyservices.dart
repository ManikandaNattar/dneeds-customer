import 'dart:async';
import 'dart:io';

import 'package:daily_needs/homepage_slider/home_slider.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/showservice.dart';
import 'package:daily_needs/sub_category/show_sub_category.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:daily_needs/searchbar/serach_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ShowDailyServices extends StatefulWidget {
  @override
  ShowDailyServicesSetState createState() => ShowDailyServicesSetState();
}

class ShowDailyServicesSetState extends State<ShowDailyServices> {
  Data data;
  Categories categories;
  Subcategories subcategories;
  Services services;
  SubServices subServices;
  SubServiceImages subServiceImages;
  GetAllCategoryServices getCategoryServices;
  List<Services> servicelist;
  List<SubServices> subservicelist;
  List<Subcategories> subcategorylist;
  bool isSelected = false;
  String selectedChoice = "";
  String selectedId = "";
  String cat_id;
  String sub_cat_id;
  String service_id;
  List<String> selectedChoiceslist = List();
  List<Categories> cat;
  TextEditingController _searchController;

  List<String> imgList = [];

  @override
  void initState() {
    super.initState();
    _searchController = new TextEditingController();
    getServices();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getCategoryServices == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Text("Loading..."),
                  )
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Container(
                      color: Colors.white,
                      child: new Padding(
                          padding: EdgeInsets.all(2.0),
                          child: CarouselWithIndicator(
                            sliderList: imgList,
                            enlargeCenterPage: true,
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 0.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(5.0),
                          color: Colors.white,
                        ),
                        child: new Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: getCategoryServices.data.categories
                              .map(
                                (eachcategory) => InkWell(
                                  highlightColor: Colors.red,
                                  splashColor: Colors.red,
                                  hoverColor: Colors.red,
                                  focusColor: Colors.red,
                                  child: Column(
                                    children: <Widget>[
                                      Material(
                                        child: InkWell(
                                          child: new Container(
                                            width: (MediaQuery.of(context)
                                                        .size
                                                        .width) /
                                                    3 -
                                                .0,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width) /
                                                      3 -
                                                  .0,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.25,
                                              decoration: BoxDecoration(
                                                  border: Border(
                                                      bottom: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.5),
                                                      right: BorderSide(
                                                          color: Colors.grey,
                                                          width: 0.5))),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: 10.0,
                                                  ),
                                                  CachedNetworkImage(
                                                      imageUrl: baseUrl +
                                                          eachcategory
                                                              .iconImage,
                                                      width: 70,
                                                      height: 70,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context,
                                                              url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget: (context,
                                                              url, error) =>
                                                          Image.asset(
                                                            "images/no_category.png",
                                                            width: 70,
                                                            height: 70,
                                                          )),
                                                  SizedBox(
                                                    height: 20.0,
                                                  ),
                                                  Text(
                                                    eachcategory.category,
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(
                                                    height: 10.0,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          onTap: () async {
                                            save_string_prefs(
                                                "categoryId", eachcategory.id);
                                            String iddd =
                                                await get_string_prefs(
                                                    "categoryId");
                                            print("category id=" + iddd);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ShowSubCategory(
                                                          category_Id:
                                                              eachcategory.id,
                                                        )));
                                          },
                                          splashColor: Colors.grey[300],
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {},
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }

  void getServices() {
    List<String> citiesList = [];
    List<String> stateList = [];
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        setState(() {
          getCategoryServices = onResponse;
          servicelist = getCategoryServices.data.services;
          subservicelist = getCategoryServices.data.subServices;
          subcategorylist = getCategoryServices.data.subcategories;
          for (var i = 0;
              i < getCategoryServices.data.homeBanners.length;
              i++) {
            imgList.add(getCategoryServices.data.homeBanners[i].imageUrl);
          }
          for (var i = 0; i < getCategoryServices.data.cities.length; i++) {
            citiesList.add(getCategoryServices.data.cities[i].city);
          }
          for (var i = 0; i < getCategoryServices.data.states.length; i++) {
            stateList.add(getCategoryServices.data.states[i].state);
          }

          save_stringList_pref("cities", citiesList);
          save_stringList_pref("state", stateList);
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
