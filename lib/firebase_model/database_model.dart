import 'package:firebase_database/firebase_database.dart';

class User {
  String Lattitude;
  String Longitude;
  String is_order_placed;
  String is_vendor_accepted;

  User.fromFirebase(DataSnapshot snapshot) {
    this.Lattitude = snapshot.value["Lattitude"];
    this.Longitude = snapshot.value["Longitude"];
    this.is_order_placed = snapshot.value["is_order_placed"];
    this.is_vendor_accepted = snapshot.value["is_vendor_accepted"];
  }
}
