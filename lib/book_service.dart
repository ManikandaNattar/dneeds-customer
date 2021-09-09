import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'package:daily_needs/get_user_location.dart';
import 'package:daily_needs/reusuable_widgets/custom_dialogue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/signup.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/add_to_cart/add_to_cart.dart';
import 'package:daily_needs/add_to_cart/reusuable_cart.dart';
import 'package:toast/toast.dart';
import 'package:daily_needs/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookService extends StatefulWidget {
  String subCategory_iD;
  String id;

  BookService({this.subCategory_iD, this.id}) : super();

  @override
  BookServiceState createState() => BookServiceState();
}

class BookServiceState extends State<BookService> {
  GetAllCategoryServices getCategoryServices;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map checkUser;
  String signUpUser;
  String loginUser;
  var allow_multi_service = "";
  int count = 0;
  bool isChipSelected = false;
  String chipSelectedServiceId;
  String subServiceId;
  SubServices subServiceList;
  List<ServiceDatas> idList = [];
  List<ServiceData> servicedataList = [];
  List<SubServices> subServicesMappingList = [];
  List<String> selectedOptions = [];
  List<String> listForPrice = [];
  bool isAddClick = false;
  bool isRemoveItems = true;
  List<int> selectedItemList = [];
  List<int> chipSelectedIndexList = [];
  String chipServiceName;
  String chipServicePrice;
  FocusNode f1 = FocusNode();
  ScrollController controller = new ScrollController();
  Map<String, String> buttonClick = new Map();
  bool isBack = false;
  List<Services> tempServiceList = [];

  @override
  void initState() {
    super.initState();
    getServices();
  }

  @override
  void dispose() {
    super.dispose();
    isAddClick = false;
    idList.clear();
    selectedItemList.clear();
  }

  refresh() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Book Service",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: primaryRedColor,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: getCategoryServices == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Center(
                    child: new CircularProgressIndicator(),
                  ),
                )
              ],
            )
          : getCategoryServices.data.subServices
                  .where(
                      (element) => element.serviceId == chipSelectedServiceId)
                  .isEmpty
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          'Service not available for this category...',
                        ),
                      )
                    ],
                  ),
                )
              : Stack(
                  children: <Widget>[
                    ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: new SingleChildScrollView(
                            controller: controller,
                            scrollDirection: Axis.horizontal,
                            child: new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: getCategoryServices.data.services
                                  .asMap()
                                  .map((serviceIndex, eachService) => widget
                                              .subCategory_iD ==
                                          eachService.subCatId
                                      ? MapEntry(
                                          serviceIndex,
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: GestureDetector(
                                              child: new Container(
                                                padding: EdgeInsets.all(10.0),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                    color: chipSelectedIndexList
                                                            .contains(
                                                                serviceIndex)
                                                        ? primaryRedColor
                                                        : Colors.white,
                                                    border: Border.all(
                                                        color:
                                                            primaryRedColor)),
                                                child: new Center(
                                                  child: new Text(
                                                    eachService.service
                                                        .toString(),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        color: chipSelectedIndexList
                                                                .contains(
                                                                    serviceIndex)
                                                            ? Colors.white
                                                            : primaryRedColor),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                setState(() {
                                                  if (chipSelectedIndexList
                                                      .contains(serviceIndex)) {
                                                    for (var i = 0;
                                                        i <
                                                            chipSelectedIndexList
                                                                .length;
                                                        i++) {
                                                      if (chipSelectedIndexList[
                                                              i] ==
                                                          serviceIndex) {}
                                                    }
                                                  } else {
                                                    chipSelectedIndexList
                                                        .add(serviceIndex);
                                                    allow_multi_service =
                                                        eachService
                                                            .allowMultiService;
                                                    print(chipSelectedIndexList
                                                        .length);
                                                    if (chipSelectedIndexList
                                                            .length >
                                                        1) {
                                                      chipSelectedIndexList
                                                          .removeAt(0);
                                                    }
                                                  }
                                                  chipSelectedServiceId =
                                                      eachService.id;
                                                  chipServiceName =
                                                      eachService.service;
                                                  chipServicePrice =
                                                      eachService.price;
                                                });
                                                print(serviceIndex.toString() +
                                                    "is the service index");
                                              },
                                            ),
                                          ),
                                        )
                                      : MapEntry(serviceIndex, new Container()))
                                  .values
                                  .toList(),
                            ),
                          ),
                        ),
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                child: Padding(
                                  padding:
                                      EdgeInsets.only(left: 0.0, right: 0.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children:
                                        getCategoryServices.data.subServices
                                            .asMap()
                                            .map(
                                              (ind, eachsubservice) =>
                                                  chipSelectedServiceId ==
                                                          eachsubservice
                                                              .serviceId
                                                      ? MapEntry(
                                                          ind,
                                                          new Card(
                                                            elevation: 10.0,
                                                            shadowColor: Colors
                                                                .grey[300],
                                                            child: new Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                new Padding(
                                                                  padding: EdgeInsets.only(
                                                                      top: 5.0,
                                                                      bottom:
                                                                          5.0),
                                                                  child: eachsubservice
                                                                              .subServiceImages
                                                                              .length ==
                                                                          0
                                                                      ? Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 10.0,
                                                                              right: 10.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                100,
                                                                            height:
                                                                                100,
                                                                            child:
                                                                                Image.asset(
                                                                              "images/no_category.png",
                                                                              width: 80,
                                                                              height: 80,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : new Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: eachsubservice
                                                                              .subServiceImages
                                                                              .map(
                                                                                (eachImages) => eachImages.imageUrl == null
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
                                                                ),
                                                                Table(
                                                                  columnWidths: {
                                                                    0: FlexColumnWidth(
                                                                        4),
                                                                    1: FlexColumnWidth(
                                                                        2),
                                                                  },
                                                                  children: [
                                                                    TableRow(
                                                                      children: [
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.0,
                                                                            vertical:
                                                                                0.0,
                                                                          ),
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Text(
                                                                                eachsubservice.subService,
                                                                                style: TextStyle(fontSize: 16.0, color: textColor),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 5.0,
                                                                              ),
                                                                              Row(
                                                                                children: <Widget>[
                                                                                  Text(
                                                                                    '\u{20B9}',
                                                                                    style: TextStyle(color: Colors.green),
                                                                                  ),
                                                                                  Text(
                                                                                    eachsubservice.price,
                                                                                    style: TextStyle(fontSize: 16.0, color: Colors.green),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                10.0,
                                                                            vertical:
                                                                                0.0,
                                                                          ),
                                                                          child:
                                                                              MaterialButton(
                                                                            child: selectedItemList.contains(ind)
                                                                                ? Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        "Remove",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                      ),
                                                                                      Icon(
                                                                                        Icons.delete_outline,
                                                                                        color: Colors.white,
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                : Text(
                                                                                    "ADD +",
                                                                                    style: TextStyle(color: Colors.white),
                                                                                  ),
                                                                            color: selectedItemList.contains(ind)
                                                                                ? primaryRedColor
                                                                                : Colors.orange,
                                                                            onPressed:
                                                                                () async {
                                                                              print('Current Item Selected:${ind}');
                                                                              String key = chipServiceName.toLowerCase().trim().replaceAll(" ", "");
                                                                              if (buttonClick[key] != null) {
                                                                                selectedOptions = buttonClick[key].split(",").toList();
                                                                              }
                                                                              if (selectedOptions.contains(eachsubservice.subService)) {
                                                                                selectedOptions = selectedOptions.where((selectedElementInList) => selectedElementInList != eachsubservice.subService).toList();
                                                                              } else {
                                                                                selectedOptions.add(eachsubservice.subService);
                                                                              }
                                                                              buttonClick[key] = selectedOptions.join(",");
                                                                              if (buttonClick[key] == "") {
                                                                                buttonClick[key] = null;
                                                                              }
                                                                              setState(() {
                                                                                if (selectedItemList.contains(ind)) {
                                                                                  for (var i = 0; i < selectedItemList.length; i++) {
                                                                                    if (selectedItemList[i] == ind) {
                                                                                      selectedItemList.removeAt(i);
                                                                                    }
                                                                                  }
                                                                                } else {
                                                                                  selectedItemList.add(ind);
                                                                                }
                                                                                var isContain = false;
                                                                                for (var i = 0; i < idList.length; i++) {
                                                                                  if (idList[i].serviceIDs == eachsubservice.id) {
                                                                                    idList.removeAt(i);
                                                                                    listForPrice.removeAt(i);
                                                                                    isContain = true;
                                                                                    break;
                                                                                  }
                                                                                }
                                                                                if (!isContain) {
                                                                                  idList.add(ServiceDatas(subServicesPrices: eachsubservice.price, serviceIDs: eachsubservice.id, subServicesImages: eachsubservice.subServiceImages, parentServiceId: eachsubservice.serviceId));
                                                                                  listForPrice.add(eachsubservice.price);
                                                                                }
                                                                                subServicesMappingList.add(eachsubservice);
                                                                                subServiceId = eachsubservice.id;
                                                                                subServiceList = eachsubservice;
                                                                                isAddClick = true;
                                                                              });
                                                                            },
                                                                            // minWidth:
                                                                            //     40.0,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                                // new Row(
                                                                //   mainAxisAlignment:
                                                                //       MainAxisAlignment
                                                                //           .spaceBetween,
                                                                //   children: <
                                                                //       Widget>[],
                                                                // ),
                                                                new Divider(),
                                                                Padding(
                                                                  padding: EdgeInsets.only(
                                                                      left:
                                                                          10.0,
                                                                      right:
                                                                          10.0,
                                                                      bottom:
                                                                          10.0),
                                                                  child:
                                                                      new Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        eachsubservice
                                                                            .description,
                                                                        style: TextStyle(
                                                                            color:
                                                                                textColor),
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : MapEntry(
                                                          ind, Container()),
                                            )
                                            .values
                                            .toList(),
                                  ),
                                ),
                              ),
                              new SizedBox(
                                height: 50.0,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      bottomNavigationBar: new Visibility(
        visible: selectedItemList.length != 0,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 0.0,
            right: 0.0,
          ),
          child: MaterialButton(
            onPressed: () async {
              print(idList.length);
              print(selectedItemList.length);
              if (idList.length != 0) {
                bool checkServiceId = idList.every((element) =>
                    element.parentServiceId == chipSelectedServiceId);
                String ids;
                String imageUrl;
                for (var i = 0; i < idList.length; i++) {
                  if ((ids == null) && (imageUrl == null)) {
                    ids = idList[i].serviceIDs;
                    imageUrl = idList[i].subServicesImages.length == 0
                        ? ""
                        : idList[i].subServicesImages[0].imageUrl;
                  } else {
                    ids = "${ids},${idList[i].serviceIDs}";
                  }
                }
                print("id list length  === " + idList.length.toString());
                print("ID List parent service  id ==    " +
                    idList[0].parentServiceId);
                save_stringList_pref("pricelist", listForPrice);
                signUpUser = await get_string_prefs("signupuser");
                loginUser = await get_string_prefs("loginuser");
                String logId = await get_string_prefs("loginuserId");
                String signId = await get_string_prefs("signUpUesrId");
                String loginId = logId == "" ? null : logId;
                String signupId = signId == "" ? null : signId;
                if (loginId == null && signupId == null) {
                  save_bool_prefs("isHomeLogin", false);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Signup(
                                isFbActivated: true,
                                service_issue: chipServiceName,
                                sub_service_ids: ids,
                                service_request_date:
                                    DateTime.now().toIso8601String(),
                                service_id: chipSelectedServiceId,
                                issue_imag_url: imageUrl,
                                priceList: listForPrice,
                                idList: idList,
                              ))).then((value) {
                    setState(() {
                      selectedItemList.clear();
                    });
                  });
                } else {
                  print("service price   iddd =" + listForPrice.toString());
                  print("service sub service   iddd =" + idList.toString());
                  print("service  iddd =" + chipSelectedServiceId);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddToCart(
                                service_id: chipSelectedServiceId,
                                service_name: chipServiceName,
                                sub_serv_ids: idList,
                                priceList: listForPrice,
                              ))).then((value) {
                    setState(() {
                      idList.clear();
                      selectedItemList.clear();
                    });
                  });
                }
              } else {
                Toast.show("Select Service", context,
                    duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    selectedItemList.length == 0
                        ? ""
                        : selectedItemList.length.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white,
                      )
                    ],
                  )
                ],
              ),
            ),
            color: primaryRedColor,
            minWidth: double.infinity,
            height: 50.0,
          ),
        ),
      ),
    );
  }

  void getServices() {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        var initial;
        setState(() {
          getCategoryServices = onResponse;
          tempServiceList = getCategoryServices.data.services
              .where((element) => element.subCatId == widget.subCategory_iD)
              .toList();
          List<Services> getIndexList = new List();
          getIndexList.addAll(getCategoryServices.data.services);
          if (tempServiceList.isNotEmpty &&
              (widget.id == null) &&
              (widget.subCategory_iD != null)) {
            print(tempServiceList.length);
            chipSelectedServiceId = tempServiceList[0].id;
            chipServiceName = tempServiceList[0].service;
            chipServicePrice = tempServiceList[0].price;
            allow_multi_service = tempServiceList[0].allowMultiService;
            var initial = getIndexList
                .indexWhere((element) => chipSelectedServiceId == element.id);
            chipSelectedIndexList.add(initial);
          } else {
            for (var i = 0; i < getCategoryServices.data.services.length; i++) {
              if ((widget.id == getCategoryServices.data.services[i].id) &&
                  (widget.subCategory_iD ==
                      getCategoryServices.data.services[i].subCatId)) {
                chipSelectedServiceId = getCategoryServices.data.services[i].id;
                chipServiceName = getCategoryServices.data.services[i].service;
                chipServicePrice = getCategoryServices.data.services[i].price;
                allow_multi_service =
                    getCategoryServices.data.services[i].allowMultiService;
                initial = getIndexList.indexWhere(
                    (element) => chipSelectedServiceId == element.id);
                chipSelectedIndexList.add(initial);
                if (controller.hasClients) {
                  controller.animateTo(initial.toDouble(),
                      duration: Duration(seconds: 2), curve: Curves.ease);
                }
                break;
              }
            }
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

  Color selectColor(
      String value, MaterialColor inactive, MaterialColor active, String key) {
    return buttonClick[key.toLowerCase().trim().replaceAll(" ", "")] != null
        ? buttonClick[key.toLowerCase().trim().replaceAll(" ", "")]
                .toLowerCase()
                .contains(value.toLowerCase())
            ? inactive
            : active
        : active;
  }
}

class ServiceDatas {
  String serviceIDs;
  String parentServiceId;
  String serviceName;
  List<SubServiceImages> subServicesImages;
  String subServicesPrices;

  ServiceDatas(
      {this.serviceIDs,
      this.subServicesImages,
      this.subServicesPrices,
      this.parentServiceId,
      this.serviceName});
}
