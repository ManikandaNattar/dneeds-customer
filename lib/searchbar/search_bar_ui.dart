import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:daily_needs/colors.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import '../api.dart';
import 'package:daily_needs/book_service.dart';

class SearchBarService extends StatefulWidget {
  @override
  SearchBarState createState() => SearchBarState();
}

class SearchBarState extends State<SearchBarService> {
  TextEditingController _serviceController;
  AutoCompleteTextField searchTextField;
  GetAllCategoryServices getCategoryServices_for_search;
  Categories categories_for_search;
  Subcategories subcategories_for_search;
  Services services_for_search;
  List<Services> servicelist;
  var servicing = [];
  SubServices subServices_for_search;
  SubServiceImages subServiceImages_for_search;
  final SearchBarController _searchBarController = SearchBarController();

  @override
  void initState() {
    super.initState();
    _serviceController = new TextEditingController();
    getAllServicesForSearch();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: getCategoryServices_for_search == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              )
            : SafeArea(
                child: Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: SearchBar(
                    scrollDirection: Axis.vertical,
                    onSearch: _search,
                    minimumChars: 5,
                    hintText: "Search Service here",
                    onItemFound: (Services ser, int index) {
                      return ListTile(
                        title: Text(ser.service.toString()),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: getCategoryServices_for_search
                              .data.subcategories
                              .map((eachsub) => eachsub.id == ser.subCatId
                                  ? Text(eachsub.subCategory)
                                  : Container())
                              .toList(),
                        ),
                        onTap: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BookService(
                                        subCategory_iD: ser.subCatId,
                                      )));
                        },
                      );
                    },
                    loader: new Center(
                      child: CircularProgressIndicator(),
                    ),
                    emptyWidget: Center(
                      child: Text("Empty"),
                    ),
                    onError: (error) {
                      return Center(
                        child: Text("Error occurred : $error"),
                      );
                    },
                    placeHolder: ListView(
                      children: getCategoryServices_for_search.data.services
                          .map((eachser) => ListTile(
                                title: new Text(eachser.service.toString()),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: getCategoryServices_for_search
                                      .data.subcategories
                                      .map((eachsub) =>
                                          eachsub.id == eachser.subCatId
                                              ? Text(eachsub.subCategory)
                                              : Container())
                                      .toList(),
                                ),
                                onTap: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BookService(
                                                subCategory_iD:
                                                    eachser.subCatId,
                                              )));
                                },
                              ))
                          .toList(),
                    )),
              )));
  }

  void getAllServicesForSearch() async {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        setState(() {
          getCategoryServices_for_search = onResponse;
          servicelist = getCategoryServices_for_search.data.services;
          servicing = getCategoryServices_for_search.data.services;
        });
        print(getCategoryServices_for_search);
      }
    });
  }

  Future<List<Services>> _search(String text) async {
    print(servicelist
        .any((element) => element.service.toLowerCase().contains(text)));
    return List.generate(1, (index) {
      return servicelist.firstWhere(
          (element) => element.service.toLowerCase().contains(text));
    });
  }
}
