import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/showservice.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/api.dart';
import 'package:flutter/widgets.dart';
import 'package:daily_needs/book_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReusuableWidget extends StatefulWidget {
  Services services;
  String sub_categ_id;

  ReusuableWidget({this.services, this.sub_categ_id}) : super();

  @override
  ReusuableState createState() => ReusuableState();
}

class ReusuableState extends State<ReusuableWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      width: MediaQuery.of(context).size.width * 0.5,
      height: 260,
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border.all(color: Colors.black26, width: 0.5),
          color: Colors.white),
      child: GestureDetector(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Card(
              child: CachedNetworkImage(
                imageUrl:
                    "https://dneeds.in/dailyneeds/${widget.services.iconImage}",
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Image.asset(
                  "images/car_worker.png",
                  fit: BoxFit.cover,
                ),
              ),
              elevation: 6.0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 5.0),
              child: Text(
                widget.services.service,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
        onTap: () {
          print(widget.services.service);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => BookService(
                        subCategory_iD: widget.sub_categ_id,
                      )));
        },
      ),
    ));
  }
}
