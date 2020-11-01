import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models.dart';

class Api{

  static String _ROOT = "https://pharmasist-app.herokuapp.com/";

  static String ADD_PRODUCT = _ROOT + "Products/Add";
  static String UPDATE_PRODUCT = _ROOT + "Products/Update";
  static String DELETE_PRODUCT = _ROOT + "Products/Delete/";
  static String FIND_PRODUCT = _ROOT + "ProductsName/";

  static String ADD_USER = _ROOT + "Users/Add";
  static String UPDATE_USER = _ROOT + "Users/Update";
  static String DELETE_USER = _ROOT + "Users/Delete/";
  static String FIND_USER = _ROOT + "Users/Check";
  static String RESET_PASSWORD = _ROOT + "Users/ResetPassword";
  static String USER_PRODUCTS = _ROOT + "ProductsUser";

  static Future<List<Product>> getProductsList(url) async {
    http.Response response = await http.get(url);
    List jsonList = json.decode(response.body);
    var ml = List<Product>();

    for (int i = 0; i < jsonList.length; i++) {
      Product product = fillProductObject(jsonList[i]);
      product.user = await fillUserObject(jsonList[i]["user"]);
      ml.add(product);
    }
    return ml;
  }

  static Product fillProductObject(jsonList){
    Product product = new Product();
    product.productId = jsonList["productId"];
    product.productName = jsonList["productName"];
    product.productForm = jsonList["productForm"];
    product.productCntr = jsonList["productCntr"];
    product.productQuantity = jsonList["productQuantity"];
    product.productPrice = jsonList["productPrice"];
    product.productExpiration = DateTime.parse(jsonList["productExpiration"]);
    product.productCode = jsonList["productCode"];
    return product;
  }

  static Future<User> fillUserObject(jsonList) async{
    User user = new User();

    if(jsonList["id"] is String){
      user.id = int.parse(jsonList["id"]);
    }else{
      user.id = jsonList["id"];
    }

    user.fname = jsonList["fname"];
    user.lname = jsonList["lname"];
    user.phone = jsonList["phone"];
    user.username = jsonList["username"];
    user.pass = jsonList["pass"];

    if(jsonList["locationx"] is String) {
      user.locationx = double.parse(jsonList["locationx"]);
    }else {
      user.locationx = jsonList["locationx"];
    }

    if(jsonList["locationy"] is String){
      user.locationy = double.parse(jsonList["locationy"]);
    }else{
      user.locationy = jsonList["locationy"];
    }

    user.distance = await user.calcDistance();

    List<String> time = getTime(jsonList["moorningStart"]);
    user.moorningStart = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));

    time = getTime(jsonList["moorningEnd"]);
    user.moorningEnd = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));

    time = getTime(jsonList["eveningStart"]);
    user.eveningStart = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));

    time = getTime(jsonList["eveningEnd"]);
    user.eveningEnd = TimeOfDay(hour: int.parse(time[0]), minute: int.parse(time[1]));

    user.isOpen = user.checkIsOpened();

    return user;
  }

  static List<String> getTime(String str) {
    String h = str.substring(0, 2);
    String m = str.substring(3, 5);
    return [h, m];
  }

}