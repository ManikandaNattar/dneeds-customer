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
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarService> {
  List<Services> _searchServiceResult = [];
  List<Services> _serviceList = [];
  List<SubServices> _subServiceList = [];
  List<Categories> _categoriesList = [];
  List<Subcategories> _subCategoriesList = [];
  // List<Services> _searchServiceList = [];
  List<SubServices> _searchSubServiceList = [];
  List<Categories> _searchCategoriesList = [];
  List<Subcategories> _searchSubCategoriesList = [];
  GetAllCategoryServices getCategoryServices_for_search;
  TextEditingController controller = new TextEditingController();

  void getAllServicesForSearch() async {
    getAllCategoryServices().then((onResponse) {
      if (onResponse is GetAllCategoryServices) {
        setState(() {
          getCategoryServices_for_search = onResponse;
          _serviceList = onResponse.data.services;
          _subServiceList = onResponse.data.subServices;
          _categoriesList = onResponse.data.categories;
          _subCategoriesList = onResponse.data.subcategories;
        });
        print(onResponse.data.services);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getAllServicesForSearch();
  }

  Widget _buildSearchResults() {
    return new ListView.builder(
      itemCount: _searchServiceResult.length,
      itemBuilder: (context, i) {
        return new Card(
          child: new ListTile(
            leading: Container(
              width: 50.0,
              height: 50.0,
              decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
                image: new DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                    baseUrl + _searchServiceResult[i].iconImage,
                  ),
                ),
              ),
            ),
            title: _searchServiceResult[i].service != null
                ? new Text(_searchServiceResult[i].service)
                : new Text(""),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getCategoryServices_for_search.data.subcategories
                  .map((eachsub) =>
                      eachsub.id == _searchServiceResult[i].subCatId
                          ? Text(eachsub.subCategory)
                          : Container())
                  .toList(),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BookService(
                    subCategory_iD: _searchServiceResult[i].subCatId,
                    id: _searchServiceResult[i].id,
                  ),
                ),
              );
            },
          ),
          margin: const EdgeInsets.all(0.0),
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Card(
        child: new ListTile(
          leading: new Icon(Icons.search),
          title: new TextField(
            controller: controller,
            textCapitalization: TextCapitalization.sentences,
            decoration: new InputDecoration(
              hintText: 'Search here',
              border: InputBorder.none,
            ),
            onChanged: onSearchTextChanged,
          ),
          trailing: new IconButton(
            icon: new Icon(Icons.cancel),
            onPressed: () {
              controller.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return new Column(
      children: <Widget>[
        new Container(color: primaryRedColor, child: _buildSearchBox()),
        new Expanded(child: _buildSearchResults()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Services'),
        elevation: 0.0,
        backgroundColor: primaryRedColor,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 0.0),
        child: _buildBody(),
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchServiceResult = [];
    if (text.isEmpty) {
      setState(() {});
      return;
    } else if (_serviceList
        .where((element) => element.service.contains(text))
        .isNotEmpty) {
      _serviceList.forEach((serviceDetail) {
        if (serviceDetail.service.contains(text)) {
          setState(() {
            _searchServiceResult.add(serviceDetail);
          });
        }
      });
    } else if (_subServiceList
        .where((element) => element.subService.contains(text))
        .isNotEmpty) {
      _subServiceList.forEach((serviceDetail) {
        if (serviceDetail.subService.contains(text)) {
          setState(() {
            _searchServiceResult.add(
              _serviceList
                  .where((element) => element.id == serviceDetail.serviceId)
                  .single,
            );
          });
        }
      });
    } else if (_categoriesList
        .where((element) => element.category.contains(text))
        .isNotEmpty) {
      _categoriesList.forEach((serviceDetail) {
        if (serviceDetail.category.contains(text)) {
          setState(() {
            _searchServiceResult.add(
              _serviceList
                  .where((element) => element.catId == serviceDetail.id)
                  .first,
            );
          });
        }
      });
    } else if (_subCategoriesList
        .where((element) => element.subCategory.contains(text))
        .isNotEmpty) {
      _subCategoriesList.forEach((serviceDetail) {
        if (serviceDetail.subCategory.contains(text)) {
          setState(() {
            setState(() {
              _searchServiceResult.add(_serviceList
                  .where((element) => element.subCatId == serviceDetail.id)
                  .first);
            });
          });
        }
      });
    } else {
      return;
    }
  }
}
