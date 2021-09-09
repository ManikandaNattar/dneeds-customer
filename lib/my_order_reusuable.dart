import 'package:daily_needs/colors.dart';
import 'package:daily_needs/phone_call/phone_call_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/Map/show_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:daily_needs/chat_screen/chat_page.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';

class MyOrderReusuable extends StatefulWidget {
  Orders orders;

  MyOrderReusuable({
    this.orders,
  }) : super();

  @override
  MyOrderReusuableState createState() => MyOrderReusuableState();
}

class MyOrderReusuableState extends State<MyOrderReusuable> {
  GetAllCategoryServices getCategoryServices;
  String user_name;
  String _eventMessage;
  static const platform = const MethodChannel("TwilioChannel");

  @override
  void initState() {
    super.initState();
    getUserName();
  }

  getUserName() async {
    user_name = await get_string_prefs("user_name");
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          new Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Padding(
                  padding: EdgeInsets.only(left: 0.0, right: 0.0),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: widget.orders.subServices
                        .map((eachServiceItem) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 0.0, right: 0.0),
                              child: Card(
                                elevation: 10.0,
                                shadowColor: Colors.grey[100],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              eachServiceItem.service,
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: textColor,
                                              ),
                                            ),
                                            new SizedBox(
                                              height: 5.0,
                                            ),
                                            Column(
                                              children: <Widget>[
                                                SizedBox(
                                                  height: 5.0,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 4.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Container(
                                                        child: widget.orders
                                                                    .issueImageUrl !=
                                                                ""
                                                            ? CachedNetworkImage(
                                                                imageUrl: baseUrl +
                                                                    widget
                                                                        .orders
                                                                        .issueImageUrl,
                                                                width: 70,
                                                                height: 70,
                                                                fit: BoxFit
                                                                    .cover,
                                                                placeholder: (context,
                                                                        url) =>
                                                                    CircularProgressIndicator(),
                                                                errorWidget: (context,
                                                                        url,
                                                                        error) =>
                                                                    Image.asset(
                                                                      "images/no_category.png",
                                                                      width: 70,
                                                                      height:
                                                                          70,
                                                                    ))
                                                            : Image.asset(
                                                                "images/no_category.png",
                                                                width: 70,
                                                                height: 70,
                                                              ),
                                                        height: 100.0,
                                                        width: 100.0,
                                                      ),
                                                      SizedBox(
                                                        width: 20.0,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            eachServiceItem
                                                                .subService,
                                                            style:
                                                                new TextStyle(
                                                              fontSize: 20.0,
                                                              color: textColor,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 6.0,
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              Text(
                                                                "Price: ",
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor),
                                                              ),
                                                              Text(
                                                                '\u{20B9}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                              Text(
                                                                eachServiceItem
                                                                    .price,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .green),
                                                              ),
                                                            ],
                                                          ),
                                                          new SizedBox(
                                                            height: 6.0,
                                                          ),
                                                          Row(
                                                            children: <Widget>[
                                                              new Text(
                                                                "Date: ",
                                                                style: TextStyle(
                                                                    color:
                                                                        textColor),
                                                              ),
                                                              Text(
                                                                widget.orders
                                                                    .serviceRequestDate,
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                widget.orders
                                                            .isOrderCompleted ==
                                                        "Y"
                                                    ? new Text(
                                                        "Service Completed Successfully")
                                                    : widget.orders.isVendorAccepted ==
                                                                "Y" &&
                                                            widget.orders
                                                                    .isOrderCompleted ==
                                                                "N"
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 5.0,
                                                                    bottom:
                                                                        10.0),
                                                            child: new Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: <
                                                                  Widget>[
                                                                new InkWell(
                                                                  child: Container(
                                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.0), border: Border.all(color: primaryRedColor)),
                                                                      child: new Padding(
                                                                          padding: EdgeInsets.all(7.0),
                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                                                                            new Icon(
                                                                              Icons.my_location,
                                                                              color: primaryRedColor,
                                                                            ),
                                                                            new SizedBox(
                                                                              width: 10.0,
                                                                            ),
                                                                            new Text(
                                                                              "Track",
                                                                              style: TextStyle(color: primaryRedColor),
                                                                            )
                                                                          ]))),
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => ShowMap(
                                                                                  initialLat: widget.orders.lat,
                                                                                  initialLong: widget.orders.long,
                                                                                  orderId: widget.orders.orderId,
                                                                                )));
                                                                  },
                                                                ),
                                                                new InkWell(
                                                                  child: new Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                          border: Border.all(
                                                                            color:
                                                                                primaryRedColor,
                                                                          )),
                                                                      child: new Padding(
                                                                          padding: EdgeInsets.all(7.0),
                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                                                                            new Icon(
                                                                              Icons.call,
                                                                              color: primaryRedColor,
                                                                            ),
                                                                            new SizedBox(
                                                                              width: 10.0,
                                                                            ),
                                                                            new Text(
                                                                              "Call",
                                                                              style: TextStyle(color: primaryRedColor),
                                                                            )
                                                                          ]))),
                                                                  onTap: () {
                                                                    callNative();
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              TwilioPhoneCall(
                                                                            bookedService:
                                                                                eachServiceItem.service,
                                                                            bookedServiceMobileNmber:
                                                                                "+919962437567",
                                                                          ),
                                                                        ));
                                                                    print(widget
                                                                        .orders
                                                                        .vendorId);
                                                                  },
                                                                ),
                                                                new InkWell(
                                                                  child: new Container(
                                                                      decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                          border: Border.all(
                                                                            color:
                                                                                primaryRedColor,
                                                                          )),
                                                                      child: new Padding(
                                                                          padding: EdgeInsets.all(7.0),
                                                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                                                                            new Icon(
                                                                              Icons.message,
                                                                              color: primaryRedColor,
                                                                            ),
                                                                            new SizedBox(
                                                                              width: 10.0,
                                                                            ),
                                                                            new Text(
                                                                              "Chat",
                                                                              style: TextStyle(color: primaryRedColor),
                                                                            )
                                                                          ]))),
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) => ChatPage(
                                                                                  chatId: widget.orders.chatRoomId,
                                                                                  user_name: user_name,
                                                                                  order_id: widget.orders.orderId,
                                                                                  user_id: widget.orders.userId,
                                                                                  vendor_id: widget.orders.vendorId,
                                                                                  service_id: widget.orders.orderId,
                                                                                )));
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : new Text("Submitted"),
                                              ],
                                            ),
                                            new SizedBox(
                                              height: 10.0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> callNative() async {
    try {
      String messageFromNative = await platform.invokeMethod("twilio_call");
      _eventMessage = messageFromNative;
    } on PlatformException catch (e) {
      _eventMessage = "Failed to Invoke: '${e.message}'.";
    }
  }
}
