import 'package:daily_needs/api.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:daily_needs/getAllCategoryService.dart';

class CarouselWithIndicator extends StatefulWidget {
  List<String> sliderList;
  bool autoPlay;
  bool enlargeCenterPage;
  double aspectRatio;
  double radius;
  double margin;

  CarouselWithIndicator(
      {this.sliderList,
      this.aspectRatio,
      this.autoPlay,
      this.enlargeCenterPage,
      this.radius,
      this.margin});

  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;
  List child;

  @override
  void initState() {
    super.initState();
    print(widget.sliderList.length);
    initSlider();
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }

    return result;
  }

  void initSlider() {
    child = map<Widget>(
      widget.sliderList,
      (index, i) {
        return Container(
          margin: EdgeInsets.all(widget.margin ?? 5.0),
          child: ClipRRect(
            borderRadius:
                BorderRadius.all(Radius.circular(widget.radius ?? 5.0)),
            child: Image.network(
              baseUrl + i,
              fit: BoxFit.cover,
              width: 1000.0,
            ),
          ),
        );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CarouselSlider(
        items: child,
        options: CarouselOptions(
            autoPlay: widget.autoPlay ?? true,
            enlargeCenterPage: widget.enlargeCenterPage ?? true,
            aspectRatio: widget.aspectRatio ?? 2.0,
            onPageChanged: _pageChanging),
      ),
      new Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 4.5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: map<Widget>(
            widget.sliderList,
            (index, url) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(0, 0, 0, 0.9)
                        : Color.fromRGBO(0, 0, 0, 0.4)),
              );
            },
          ),
        ),
      ),
    ]);
  }

  carouselmethod() {
    setState(() {});
  }

  _pageChanging(int index, CarouselPageChangedReason reason) {
    setState(() {
      _current = index;
    });
  }
}
