import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmasist/models.dart';
import 'package:pharmasist/strings.dart';
import 'package:pharmasist/tools.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

class MapSample extends StatefulWidget {

  Product myProduct;

  MapSample(Product product){
    this.myProduct = product;
  }

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {

  Completer<GoogleMapController> _controller = Completer();
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          title: new Text(Strings.appTitle),
          centerTitle: false,
          backgroundColor: Colors.lightBlueAccent,
          actions: <Widget>[
            new IconButton(
                icon: new Icon(Icons.info), onPressed: () => {print("clicked !")})
          ],
        ),
      body: Tools.getScrollWidget(new Container(
        alignment: Alignment.bottomLeft,
        child: new Column(
          children: <Widget>[
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.trade_name + widget.myProduct.productName),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.product_form + widget.myProduct.productForm),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.product_cntr + widget.myProduct.productCntr),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.product_price + widget.myProduct.productPrice.toStringAsFixed(2) + " DA"),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.pharmasist_of + widget.myProduct.user.fname + " " + widget.myProduct.user.lname),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.pharmasist_distance + widget.myProduct.user.distance.toStringAsFixed(2) + " KM"),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.pharmasist_stateus + "${(widget.myProduct.user.isOpen == true) ? Strings.open : Strings.close}"),
            new Padding(padding: EdgeInsets.only(top: 25)),
            new Text(Strings.phone + widget.myProduct.user.phone),
            Container(
              alignment: Alignment.center,
              height: 200,
              margin: EdgeInsets.all(25),
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(widget.myProduct.user.locationy, widget.myProduct.user.locationx),
                  zoom: 16,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                  setState(() {
                    markers.add(
                        Marker(
                          position: LatLng(widget.myProduct.user.locationy, widget.myProduct.user.locationx),
                          markerId: MarkerId("Pharmasist"),
                          visible: true,
                          icon: BitmapDescriptor.defaultMarker,
                          infoWindow: InfoWindow(
                              title: Strings.pharmasist_position
                          ),
                        )
                    );
                  });
                },
                markers: markers.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            new Container(
              margin: EdgeInsets.only(left: 50, right: 50),
              alignment: Alignment.center,
              child: new RaisedButton(
                onPressed: _callPharmasist,
                color: Colors.lightBlueAccent,
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Icon(Icons.phone, color: Colors.white,),
                    new Padding(padding: EdgeInsets.only(left: 25)),
                    new Text(Strings.calling, style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)
                  ],
                ),
              ),
            )
          ],
        ),
      )
    ));
  }

  _callPharmasist(){
    UrlLauncher.launch('tel:${widget.myProduct.user.phone}');
  }

}