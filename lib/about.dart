import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pharmasist/strings.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(15),
      child: SingleChildScrollView(child: Column(children: <Widget>[
        new Text(
          Strings.about,
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 25.0, letterSpacing: 1),
        ),
        new Padding(padding: EdgeInsets.only(top: 20)),
        new Text(
          Strings.app_desc,
          textAlign: TextAlign.justify,
          style: new TextStyle(fontSize: 15.0),
        ),
        new Padding(padding: EdgeInsets.only(top: 20)),
        new Text(
          Strings.app_dev,
          textAlign: TextAlign.center,
          style: new TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
        ),
        new Padding(padding: EdgeInsets.only(top: 20)),
        new Row(children: <Widget>[
          new Icon(Icons.email),
          new Text("   abidmohamed93@gmail.com", style: new TextStyle(fontSize: 10.0))
        ], mainAxisAlignment: MainAxisAlignment.center,),
        new Padding(padding: EdgeInsets.only(top: 10)),
        new Row(children: <Widget>[
          new Icon(Icons.phone),
          new Text("   0672023497", style: new TextStyle(fontSize: 10.0))
        ], mainAxisAlignment: MainAxisAlignment.center,),
      ])),
    );
  }
}
