import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:daily_needs/colors.dart';
import '../api.dart';
import 'package:toast/toast.dart';
import 'package:google_map_polyline/google_map_polyline.dart';

class ShowMap extends StatefulWidget {
  String orderId;
  String initialLat;
  String initialLong;

  ShowMap({this.orderId, this.initialLat, this.initialLong}) : super();

  @override
  ShowMapState createState() => ShowMapState();
}

class ShowMapState extends State<ShowMap> {
  StreamSubscription _locationSubscription;
  Completer<GoogleMapController> _googleController = Completer();
  GoogleMapController _gmapController;
  final listenfirebasedatabase =
      FirebaseDatabase.instance.reference().child("user");
  LatLng customer;
  LatLng customer_track_map;
  Marker marker;
  Circle circle;
  final Set<Polyline> polyline = {};
  List<LatLng> list_for_polylines = List();
  GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "AIzaSyAySBuTqulauB3WO2Pcxuxbp95vXMKACWw");

  @override
  void initState() {
    super.initState();
    getVendorLocationFromDatabase();
    double initialCustomerLat = double.parse(widget.initialLat);
    double initialCustomerLong = double.parse(widget.initialLong);
    customer_track_map = LatLng(initialCustomerLat, initialCustomerLong);
    marker = (Marker(
      markerId: MarkerId(customer_track_map.toString()),
      position: customer_track_map,
      infoWindow: InfoWindow(
        title: 'You are here',
        snippet: '5 Star Rating',
      ),
      icon: BitmapDescriptor.defaultMarker,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
  }

  void _onMapCreated(GoogleMapController mapController) {
    setState(() {
      _googleController.complete(mapController);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        title: Text('Map'),
        centerTitle: true,
      ),
      body: new SingleChildScrollView(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  _gmapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: customer_track_map,
                  zoom: 16.0,
                ),
                circles: Set.of((circle != null) ? [circle] : []),
                markers: Set.of((marker != null) ? [marker] : []),
                polylines: polyline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void getVendorLocationFromDatabase() async {
    _locationSubscription = Stream.periodic(
            Duration(seconds: 10), (_) => listenfirebasedatabase.onValue)
        .listen((solution) async {
      solution.listen((events) async {
        var acceptsnapshot = events.snapshot;
        if (acceptsnapshot.value[widget.orderId]["is_vendor_accepted"] == "Y") {
          String temp = acceptsnapshot.value[widget.orderId]["lat_lng"];
          var ltlngarr = temp.split(",");
          print("lat is " + ltlngarr[0]);
          print("lng is" + ltlngarr[1]);
          double lat = double.parse(ltlngarr[0]);
          double long = double.parse(ltlngarr[1]);
          List<LatLng> temp_poly_list =
              await googleMapPolyline.getCoordinatesWithLocation(
                  origin: LatLng(double.parse(widget.initialLat),
                      double.parse(widget.initialLong)),
                  destination: LatLng(lat, long),
                  mode: RouteMode.driving);
          if (_gmapController != null) {
            _gmapController.animateCamera(
                CameraUpdate.newCameraPosition(new CameraPosition(
              target: LatLng(lat, long),
              zoom: 16.0,
            )));
          }
          if (mounted) {
            setState(() {
              circle = Circle(
                circleId: CircleId("vendor"),
                fillColor: Colors.blue,
                zIndex: 1,
                radius: 5.0,
                center: LatLng(lat, long),
              );
              polyline.add(Polyline(
                  polylineId: PolylineId(customer_track_map.toString()),
                  visible: true,
                  points: list_for_polylines = temp_poly_list,
                  width: 4,
                  color: Colors.blue,
                  startCap: Cap.roundCap,
                  endCap: Cap.buttCap));
            });
          }
        }
      });
    });
  }
}
