import 'package:daily_needs/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/showservice.dart';
import 'package:daily_needs/book_service.dart';

class SubCategoryResusuable extends StatefulWidget {
  Subcategories sub_gategories;
  String cat_id;

  SubCategoryResusuable({this.sub_gategories, this.cat_id}) : super();

  @override
  SubCategoryResusuableState createState() => SubCategoryResusuableState();
}

class SubCategoryResusuableState extends State<SubCategoryResusuable> {
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
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
                right: BorderSide(color: Colors.grey, width: 0.5))),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 0.0, right: 0.0, bottom: 5.0, top: 5.0),
              child: Wrap(
                direction: Axis.vertical,
                children: <Widget>[
                  Material(
                    child: InkWell(
                      splashColor: Colors.grey[300],
                      onTap: () {
                        print("tapped");
                      },
                      child: Container(
                        child: new Container(
                          width: 120 - .0,
                          height: 180 - .0,
                          child: new GestureDetector(
                            child: new Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new SizedBox(
                                  height: 10.0,
                                ),
                                widget.sub_gategories.iconImage != null
                                    ? Image.network(
                                        baseUrl +
                                            widget.sub_gategories.iconImage,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "images/car_worker.png",
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.cover,
                                      ),
                                new SizedBox(
                                  height: 10.0,
                                ),
                                new Text(
                                  widget.sub_gategories.subCategory,
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                new SizedBox(
                                  height: 5.0,
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BookService(
                                            subCategory_iD:
                                                widget.sub_gategories.id,
                                          )));
                            },
                          ),
                        ),
                        width: 119 - .0,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
