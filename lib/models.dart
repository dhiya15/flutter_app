import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Product {
  int productId;
  String productName;
  String productForm;
  String productCntr;
  int productQuantity;
  double productPrice;
  DateTime productExpiration;
  String productCode;
  User user;

  bool checkIsExpire() {
    return productExpiration.isAfter(DateTime.now());
  }
}

class User{
  int id;
  String fname;
  String lname;
  String phone;
  String username;
  String pass;
  double locationx;
  double locationy;
  TimeOfDay moorningStart;
  TimeOfDay moorningEnd;
  TimeOfDay eveningStart;
  TimeOfDay eveningEnd;
  double distance;
  bool isOpen;

  Future<List<double>> getCurrentLocation() async {
    Geolocator geolocator = new Geolocator();
    Position position = await geolocator.getCurrentPosition();
    return [position.latitude, position.longitude];
  }

  Future<double> calcDistance() async {
    Geolocator geolocator = new Geolocator();
    Position position = await geolocator.getCurrentPosition();
    double distance = await geolocator.distanceBetween(
        position.latitude, position.longitude,
        locationy, locationx
    );
    return distance / 1000;
  }

  bool checkIsOpened() {
    int z = (TimeOfDay.now().hour * 60) + TimeOfDay.now().minute;

    int x = (moorningStart.hour * 60) + moorningStart.minute;
    int y = (moorningEnd.hour * 60) + moorningEnd.minute;

    int a = (eveningStart.hour * 60) + eveningStart.minute;
    int b = (eveningEnd.hour * 60) + eveningEnd.minute;

    return ((x < z) && (y > z)) || ((a < z) && (b > z));
  }
}