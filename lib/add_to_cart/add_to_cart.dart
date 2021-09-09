import 'dart:async';
import 'dart:io';

import 'package:daily_needs/add_to_cart/promo_ui.dart';
import 'package:daily_needs/api_model_classes/promo_code_get.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/add_to_cart/reusuable_cart.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/get_user_location.dart';
import 'package:daily_needs/signup.dart';
import '../api.dart';
import 'package:daily_needs/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../book_service.dart';
import 'package:location/location.dart';

class AddToCart extends StatefulWidget {
  String service_name;
  String service_id;
  List<ServiceDatas> sub_serv_ids;
  List<String> priceList;

  AddToCart({
    this.service_name,
    this.service_id,
    this.sub_serv_ids,
    this.priceList,
  }) : super();

  @override
  AddToCartState createState() => AddToCartState();
}

class AddToCartState extends State<AddToCart> {
  GetAllCategoryServices getCategoryServices;
  String ids;
  String imageUrl;
  Map checkUser;
  String signUpUser;
  String loginUser;
  DateTime dateTime;
  String totalAmount;
  String cancelCount;
  int cancelCountInt;
  Location location = new Location();
  bool _serviceEnabled;
  LocationData _locationData;
  double discountPrice;

  @override
  void initState() {
    super.initState();
    print("sub services === =" + widget.sub_serv_ids.toString());
    tryToGetLocationPermission();
    getServices();
    getCancelCount();
    setState(() {
      for (var i = 0; i < widget.sub_serv_ids.length; i++) {
        if ((ids == null) && (imageUrl == null)) {
          ids = widget.sub_serv_ids[i].serviceIDs;
          imageUrl = widget.sub_serv_ids[i].subServicesImages.length == 0
              ? ""
              : widget.sub_serv_ids[i].subServicesImages[0].imageUrl;
        } else {
          ids = "${ids},${widget.sub_serv_ids[i].serviceIDs}";
        }
      }
      print(ids);
    });
  }

  @override
  void dispose() {
    super.dispose();
    widget.priceList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Booking Summary",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryRedColor,
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: getCategoryServices == null
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
                    new Container(
                      child: ListView(
                        children: <Widget>[
                          new Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: widget.sub_serv_ids
                                    .map(
                                      (eachIds) => Container(
                                        child: new Card(
                                          elevation: 10.0,
                                          shadowColor: Colors.grey[300],
                                          child: new Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    eachIds.subServicesImages
                                                                .length ==
                                                            0
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              left: 10.0,
                                                              right: 10.0,
                                                              top: 5.0,
                                                            ),
                                                            child: Container(
                                                              width: 100,
                                                              height: 100,
                                                              child:
                                                                  Image.asset(
                                                                "images/no_category.png",
                                                              ),
                                                            ),
                                                          )
                                                        : new Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceEvenly,
                                                            children: eachIds
                                                                .subServicesImages
                                                                .map(
                                                                  (eachImages) =>
                                                                      eachImages.imageUrl ==
                                                                              ""
                                                                          ? Container(
                                                                              width: 100,
                                                                              height: 100,
                                                                              child: Image.asset(
                                                                                "images/no_category.png",
                                                                                width: 80,
                                                                                height: 80,
                                                                              ),
                                                                            )
                                                                          : Padding(
                                                                              padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                                                                              child: Container(
                                                                                width: 100,
                                                                                height: 100,
                                                                                child: CachedNetworkImage(
                                                                                    imageUrl: baseUrl + eachImages.imageUrl,
                                                                                    fit: BoxFit.cover,
                                                                                    placeholder: (context, url) => CircularProgressIndicator(),
                                                                                    errorWidget: (context, url, error) => Image.asset(
                                                                                          "images/no_category.png",
                                                                                          width: 70,
                                                                                          height: 70,
                                                                                        )),
                                                                              ),
                                                                            ),
                                                                )
                                                                .toList(),
                                                          ),
                                                  ]),
                                              SizedBox(
                                                height: 10.0,
                                              ),
                                              new Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: getCategoryServices
                                                          .data.subServices
                                                          .map((each_sub_ser) =>
                                                              eachIds.serviceIDs ==
                                                                      each_sub_ser
                                                                          .id
                                                                  ? Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          left:
                                                                              10.0,
                                                                          right:
                                                                              10.0),
                                                                      child:
                                                                          new Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            widget.service_name,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 20.0,
                                                                              color: textColor,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5.0,
                                                                          ),
                                                                          Text(
                                                                            each_sub_ser.subService,
                                                                            style:
                                                                                TextStyle(fontSize: 15.0, color: textColor),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                5.0,
                                                                          ),
                                                                          Row(
                                                                            children: <Widget>[
                                                                              Text(
                                                                                "Price: ",
                                                                                style: TextStyle(color: textColor),
                                                                              ),
                                                                              Text(
                                                                                '\u{20B9}',
                                                                                style: TextStyle(color: Colors.green),
                                                                              ),
                                                                              Text(
                                                                                each_sub_ser.price,
                                                                                style: TextStyle(color: Colors.green),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          new SizedBox(
                                                                            height:
                                                                                5.0,
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : new Container())
                                                          .toList(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              new SizedBox(
                                height: 10.0,
                              ),
                              discountPrice == null
                                  ? InkWell(
                                      child: new Container(
                                        padding: EdgeInsets.all(10.0),
                                        color: Colors.red,
                                        child: new Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            new Text(
                                              "Apply Promo Code",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.0),
                                            ),
                                            new Icon(
                                              Icons.arrow_forward_ios,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        PromoScreen()))
                                            .then((onDiscount) {
                                          if (onDiscount is double) {
                                            print("discount price is=" +
                                                onDiscount.toString());
                                            setState(() {
                                              discountPrice = onDiscount;
                                            });
                                          }
                                        });
                                      },
                                    )
                                  : new Container(),
                              new SizedBox(
                                height: 20.0,
                              ),
                              new SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 10.0, right: 10.0),
                                child: new Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    new Text(
                                      "Total Price: ",
                                      style: TextStyle(
                                          color: discountPrice == null
                                              ? textColor
                                              : Colors.grey[300],
                                          fontSize: 20.0),
                                    ),
                                    Text(
                                      '\u{20B9}',
                                      style: TextStyle(
                                          color: discountPrice == null
                                              ? Colors.green
                                              : Colors.grey[300],
                                          fontSize: 16.0),
                                    ),
                                    new Text(
                                      _totalPrizeAmount(),
                                      style: TextStyle(
                                          color: discountPrice == null
                                              ? Colors.green
                                              : Colors.grey[300],
                                          fontSize: 20.0),
                                    )
                                  ],
                                ),
                              ),
                              new SizedBox(
                                height: 20.0,
                              ),
                              discountPrice == null
                                  ? new Container()
                                  : Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, right: 10.0),
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          new Text(
                                            "Grant Total: ",
                                            style: TextStyle(
                                                color: textColor,
                                                fontSize: 20.0),
                                          ),
                                          Text(
                                            '\u{20B9}',
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 16.0),
                                          ),
                                          new Text(
                                            calculateDiscountValue(),
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 20.0),
                                          )
                                        ],
                                      ),
                                    ),
                              new SizedBox(
                                height: 60.0,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 0.0, right: 0.0),
        child: MaterialButton(
          height: 50.0,
          color: primaryRedColor,
          child: Text(
            "Continue",
            style: TextStyle(
                color: Colors.white,
                fontSize: 17.0,
                fontWeight: FontWeight.w600),
          ),
          onPressed: () async {
            signUpUser = await get_string_prefs("signupuser");
            loginUser = await get_string_prefs("loginuser");
            print(signUpUser.toString());
            String logId = await get_string_prefs("loginuserId");
            String signId = await get_string_prefs("signUpUesrId");
            String loginId = logId == "" ? null : logId;
            String signupId = signId == "" ? null : signId;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserLocation(
                          service_request_date:
                              DateTime.now().toIso8601String(),
                          sub_service_ids: ids,
                          service_issue: widget.service_name,
                          service_id: widget.service_id,
                          sub_serv_ids: widget.sub_serv_ids,
                          userId: loginId ?? signupId,
                          imageUrl: imageUrl,
                        )));
          },
          minWidth: double.infinity,
          splashColor: Colors.white,
        ),
      ),
    );
  }

  void getCancelCount() async {
    cancelCount = await get_string_prefs("userCancelledOrder");
    if (cancelCount == "") {
      setState(() {
        cancelCountInt = 0;
      });
    } else {
      setState(() {
        cancelCountInt = int.parse(cancelCount);
      });
    }
    print("the cancellation string is" + cancelCount);
    print("the cancellation count is" + cancelCountInt.toString());
  }

  void getServices() {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        setState(() {
          getCategoryServices = onResponse;
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

  String _calculateTotalPrize(ServiceDatas serviceDatas) {
    List<double> price = new List();
    var res;
    price.add(double.parse(serviceDatas.subServicesPrices));
    for (int i = 0; i < price.length; i++) {
      var amt = price[i];
    }
    totalAmount = res.toString();
    return totalAmount;
  }

  String _totalPrizeAmount() {
    double total = 0;
    for (int i = 0; i < widget.priceList.length; i++) {
      double amt = double.parse(widget.priceList[i]);
      total = total + amt;
    }
    setState(() {
      totalAmount = total.toString();
    });

    if (cancelCountInt > 3) {
      var cancelletionCharges = 30.0;
      var actualAndCancelFee = total + cancelletionCharges;
      setState(() {
        totalAmount = actualAndCancelFee.toString();
      });
    }
    return totalAmount;
  }

  String calculateDiscountValue() {
    if (discountPrice != null) {
      double offer =
          (double.parse(totalAmount) * discountPrice / 100).toDouble();
      double finalPrice = double.parse(totalAmount).toDouble() - offer;
      return finalPrice.toString();
    }
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
