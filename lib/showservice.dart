import 'package:daily_needs/service_reusablewidget.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/api.dart';
import 'package:daily_needs/getAllCategoryService.dart';

class ShowServices extends StatefulWidget {
  String cat_id;
  String sub_cat_id;

  ShowServices({this.cat_id, this.sub_cat_id}) : super();

  @override
  ShowServicesState createState() => ShowServicesState();
}

class ShowServicesState extends State<ShowServices> {
  GetAllCategoryServices getCategoryServices;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Services",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: primaryRedColor,
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: getCategoryServices != null
            ? SingleChildScrollView(
                child: Container(
                  child: getCategoryServices.data.services.length != 0
                      ? Wrap(
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: getCategoryServices.data.services
                              .map((eachservice) =>
                                  eachservice.subCatId == widget.sub_cat_id
                                      ? ReusuableWidget(
                                          services: eachservice,
                                          sub_categ_id: widget.sub_cat_id,
                                        )
                                      : Container())
                              .toList(),
                        )
                      : Container(
                          child: Center(
                            child: Text(
                              "Loading...",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: Text("Loading...."),
                    ),
                  )
                ],
              ));
  }

  void getServices() {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        setState(() {
          getCategoryServices = onResponse;
        });
      }
    });
  }
}
