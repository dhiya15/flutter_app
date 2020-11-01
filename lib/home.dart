import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pharmasist/strings.dart';
import 'package:pharmasist/tools.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'api.dart';
import 'main.dart';
import 'models.dart';

class PharmasistHome extends StatefulWidget {
  @override
  _PharmasistHomeState createState() => _PharmasistHomeState();

  static User user;
}

class _PharmasistHomeState extends State<PharmasistHome> {

  // ----------> Variables & objects <----------

  Widget body;
  Widget floatingActionButton;

  ProgressDialog pr;

  final _updateUserFormKey = GlobalKey<FormState>();
  final _addProductFormKey = GlobalKey<FormState>();

  TextEditingController homeSearch = new TextEditingController();

  TextEditingController updateFname = new TextEditingController();
  TextEditingController updateLname = new TextEditingController();
  TextEditingController updatePhone = new TextEditingController();
  TextEditingController updateEmail = new TextEditingController();
  TextEditingController updatePassword = new TextEditingController();
  TextEditingController updateMStart = new TextEditingController();
  TextEditingController updateMEnd = new TextEditingController();
  TextEditingController updateEStart = new TextEditingController();
  TextEditingController updateEEnd = new TextEditingController();

  TextEditingController addProductName = new TextEditingController();
  TextEditingController addProductCntr = new TextEditingController();
  TextEditingController addProductQuantity = new TextEditingController();
  TextEditingController addProductPrice = new TextEditingController();
  TextEditingController addProductExpiration = new TextEditingController();
  TextEditingController addProductBarCode = new TextEditingController();

  List<Product> medicinesList;
  List<Product> oldList = List<Product>();

  int currentTab = 0;
  int length = 0;

  // ----------> init state <----------

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    floatingActionButton = fab();
    body = getHomeWidget();
    fillMedecnesList();
  }

  // ----------> Widgets <----------

  Widget fab() {
    return new FloatingActionButton(
      // onPressed: scanQRCode,
      child: new Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.lightBlueAccent,
      onPressed: () {
        setState((){
          cleanProductFields();
        });
        showAddProductWindow();
      },
    );
  }

  Widget drawer() {
    return new Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(Strings.welcome),
            accountEmail:
                Text(PharmasistHome.user.fname + " " + PharmasistHome.user.lname),
            currentAccountPicture: Image.asset(
              "images/user.png",
              height: 250,
              width: 250,
            ),
            /*CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    PharmasistHome.user.fname[0].toUpperCase(),
                    style: TextStyle(fontSize: 40.0, color: Colors.blue),
                  ),
                )*/
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text(PharmasistHome.user.phone),
          ),
          ListTile(
            leading: Icon(Icons.email),
            title: Text(PharmasistHome.user.username),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_circle),
            title: Text(Strings.update_profil),
            onTap: () => showScreen(1),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text(Strings.setting),
            onTap: () => Tools.showAlertDialog(context, Strings.appTitle, Strings.not_yet),
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text(Strings.about),
            onTap: () => Tools.about(context),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text(Strings.disconnect),
            onTap: () => disconnect(),
          ),
      ],
    ));
  }

  Widget getHomeWidget() {
    return new Container(
      margin: new EdgeInsets.all(20),
      alignment: Alignment.center,
      child: new Column(
        children: <Widget>[
          new Container(
              child:new TextField(
                controller: homeSearch,
                keyboardType: TextInputType.text,
                onChanged: (String value) {
                  print("$value");
                  searchFor(value);
                },
                onSubmitted: (String value) {
                  print("$value");
                  searchFor(value);
                },
                maxLength: 30,
                decoration: new InputDecoration(
                  icon: new Icon(Icons.search),
                  hintText: Strings.searchField,
                ),
              ),
          ),
          new Padding(padding: EdgeInsets.all(10)),
          new Expanded(
            //height: 200.0,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: length,
                itemBuilder: (BuildContext context, int position) {
                  return Card(
                      borderOnForeground: true,
                      shadowColor: Colors.white70,
                      margin: EdgeInsets.all(6),
                      color: Colors.white70,
                      child: new Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: ListTile(
                            title: new Text(Strings.trade_name +
                                medicinesList[position].productName),
                            subtitle: new Column(
                              children: <Widget>[
                                new Padding(padding: EdgeInsets.only(top: 10)),
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Text(Strings.product_form +
                                          medicinesList[position]
                                              .productForm),
                                      flex: 1,
                                    ),
                                    new Expanded(
                                      child: new Text(Strings.product_cntr +
                                          medicinesList[position]
                                              .productCntr
                                      ),
                                      flex: 1,
                                    ),
                                  ],
                                ),
                                new Padding(padding: EdgeInsets.only(top: 10)),
                                new Row(
                                  children: <Widget>[
                                    new Expanded(
                                      child: new Text(
                                          Strings.product_price +
                                              medicinesList[position]
                                                  .productPrice
                                                  .toStringAsFixed(2) + "DA"),
                                      flex: 2,
                                    ),
                                    new Expanded(
                                      child: new Text(
                                        (medicinesList[position].checkIsExpire())
                                            ? Strings.acceptable
                                            : Strings.expired,
                                        style: new TextStyle(
                                            color: (medicinesList[position].checkIsExpire())
                                                ? Colors.lightGreen
                                                : Colors.red),
                                      ),
                                      flex: 1,
                                    )
                                  ],
                                ),
                                Divider(),
                                new Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    IconButton(icon: Icon(Icons.update), onPressed: () => showUpdateProductWindow(medicinesList[position])),
                                    new Padding(padding: EdgeInsets.only(left: 15, right: 15)),
                                    IconButton(icon: Icon(Icons.delete), onPressed: () => confirmDelete(medicinesList[position].productId))
                                  ],
                                )
                              ],
                            ),
                            leading: new CircleAvatar(
                              backgroundColor: Colors.lightBlueAccent,
                              child: new Text(
                                  medicinesList[position]
                                      .productName
                                      .toString()[0]
                                      .toUpperCase(),
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)
                              ),
                            ),
                          )
                      )
                  );
              })),
        ],
      ),
    );
  }

  Widget getProfilWidget(){
    return new Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.all(30),
      child: new Center(
        child: new Column(
          children: <Widget>[
            Image.asset('images/user.png', width: 250.0, height: 250.0),
            Form(
                key: _updateUserFormKey,
                child: Column(children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.text,
                    controller: updateFname,
                    maxLength: 50,
                    decoration: new InputDecoration(
                      hintText: Strings.fname,
                      icon: new Icon(Icons.text_fields),
                    ),
                    validator: (value) {
                      return Tools.validateString(value, 6);
                    },
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.text,
                    controller: updateLname,
                    maxLength: 50,
                    decoration: new InputDecoration(
                      hintText: Strings.lname,
                      icon: new Icon(Icons.text_fields),
                    ),
                    validator: (value) {
                      return Tools.validateString(value, 6);
                    },
                  ),
                  new TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: updatePhone,
                    maxLength: 10,
                    decoration: new InputDecoration(
                      hintText: Strings.phone,
                      icon: new Icon(Icons.phone),
                    ),
                    validator: (value) {
                      return Tools.validateString(value, 3);
                    },
                  ),
                  new TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: updateEmail,
                      maxLength: 50,
                      decoration: new InputDecoration(
                        hintText: Strings.email,
                        icon: new Icon(Icons.person),
                      ),
                      validator: (value) {
                        return Tools.validateString(value, 0);
                      }),
                  new TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: updatePassword,
                      maxLength: 50,
                      obscureText: true,
                      decoration: new InputDecoration(
                        hintText: Strings.password,
                        icon: new Icon(Icons.lock),
                      ),
                      validator: (value) {
                        return Tools.validateString(value, 1);
                      }),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Expanded(
                          child: new TextFormField(
                              onTap: (){
                                DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                                  setState(() {
                                    updateMStart.text = Tools.fillDate2(date);
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    updateMStart.text = Tools.fillDate2(date);
                                  });
                                }, currentTime: DateTime.now());
                              },
                              controller: updateMStart,
                              maxLength: 8,
                              readOnly: true,
                              showCursor: true,
                              decoration: new InputDecoration(
                                hintText: Strings.time1,
                                icon: new Icon(Icons.timer),
                              ),
                              validator: (value) {
                                return Tools.validateString(value, 5);
                              })),
                      new Padding(padding: EdgeInsets.all(15)),
                      new Expanded(
                          child: new TextFormField(
                              onTap: (){
                                DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                                  setState(() {
                                    updateMEnd.text = Tools.fillDate2(date);
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    updateMEnd.text = Tools.fillDate2(date);
                                  });
                                }, currentTime: DateTime.now());
                              },
                              readOnly: true,
                              showCursor: true,
                              controller: updateMEnd,
                              maxLength: 8,
                              decoration: new InputDecoration(
                                hintText: Strings.time2,
                                icon: new Icon(Icons.timer),
                              ),
                              validator: (value) {
                                return Tools.validateString(value, 5);
                              })),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Expanded(
                        child: new TextFormField(
                            onTap: (){
                              DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                                setState(() {
                                  updateEStart.text = Tools.fillDate2(date);
                                });
                              }, onConfirm: (date) {
                                setState(() {
                                  updateEStart.text = Tools.fillDate2(date);
                                });
                              }, currentTime: DateTime.now());
                            },
                            readOnly: true,
                            showCursor: true,
                            controller: updateEStart,
                            maxLength: 8,
                            decoration: new InputDecoration(
                              hintText: Strings.time3,
                              icon: new Icon(Icons.timer),
                            ),
                            validator: (value) {
                              return Tools.validateString(value, 5);
                            }),
                      ),
                      new Padding(padding: EdgeInsets.all(15)),
                      new Expanded(
                          child: new TextFormField(
                              onTap: (){
                                DatePicker.showTimePicker(context, showTitleActions: true, onChanged: (date) {
                                  setState(() {
                                    updateEEnd.text = Tools.fillDate2(date);
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    updateEEnd.text = Tools.fillDate2(date);
                                  });
                                }, currentTime: DateTime.now());
                              },
                              readOnly: true,
                              showCursor: true,
                              controller: updateEEnd,
                              maxLength: 8,
                              decoration: new InputDecoration(
                                hintText: Strings.time4,
                                icon: new Icon(Icons.timer),
                              ),
                              validator: (value) {
                                return Tools.validateString(value, 5);
                              })),
                    ],
                  ),
                  new Padding(padding: EdgeInsets.only(top: 20)),
                  CheckBoxWidget(),
                  new Padding(padding: EdgeInsets.only(top: 20)),
                  new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () {
                          if (_updateUserFormKey.currentState.validate()) {
                            sendToUpdateUser();
                          }
                        },
                        child: new Text(
                          Strings.save,
                          style: new TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                      new Padding(padding: EdgeInsets.all(8)),
                      new RaisedButton(
                        onPressed: () {
                          confirmDeleteUser();
                        },
                        child: new Text(Strings.delete_profile,
                            style: new TextStyle(color: Colors.white)),
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  )
                ]
                )
            ),
          ],
        ),
      ),
    );
  }

  Widget getAddProductWidget(){
    return new Container(
      child: Form(
        key: _addProductFormKey,
        child: SingleChildScrollView(child: Column(children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(child: new TextFormField(
                controller: addProductName,
                maxLength: 50,
                decoration: new InputDecoration(
                  hintText: Strings.trade_name,
                  icon: new Icon(Icons.text_format),
                ),
                validator: (value) {
                  return Tools.validateString(value, 6);
                },
              )),
            ],
          ),
          new Row(children: <Widget>[
            new Expanded(child: DropDownWidget()),
            new Padding(padding: EdgeInsets.only(left: 5, right: 5)),
            new Expanded(child: new TextFormField(
                controller: addProductCntr,
                maxLength: 50,
                decoration: new InputDecoration(
                  hintText: Strings.product_cntr,
                  icon: new Icon(Icons.text_format),
                ),
                validator: (value) {
                  return Tools.validateString(value, 8);
                }
            ))
          ],),
          new Row(children: <Widget>[
            new Expanded(child: new TextFormField(
              controller: addProductQuantity,
              maxLength: 50,
              decoration: new InputDecoration(
                hintText: Strings.product_quantity,
                icon: new Icon(Icons.plus_one),
              ),
              validator: (value) {
                return Tools.validateString(value, 4);
              },
            )),
            new Padding(padding: EdgeInsets.only(left: 5, right: 5)),
            new Expanded(child: new TextFormField(
              controller: addProductPrice,
              maxLength: 50,
              decoration: new InputDecoration(
                hintText: Strings.product_price,
                icon: new Icon(Icons.monetization_on),
              ),
              validator: (value) {
                return Tools.validateString(value, 7);
              },
            ))
          ],),
          new TextFormField(
            controller: addProductExpiration,
            maxLength: 50,
            readOnly: true,
            onTap: (){
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  onChanged: (date) {
                    setState(() {
                      addProductExpiration.text = Tools.fillDate(date);
                    });
                  }, onConfirm: (date) {
                    setState(() {
                      addProductExpiration.text = Tools.fillDate(date);
                    });
                  }, currentTime: DateTime.now(), locale: LocaleType.fr);
            },
            decoration: new InputDecoration(
              hintText: Strings.product_expiration,
              icon: new Icon(Icons.date_range),
            ),
            validator: (value) {
              return Tools.validateString(value, 5);
            },
          ),
          new TextFormField(
            controller: addProductBarCode,
            readOnly: true,
            onTap: () async{
              String code = await Tools.scanQRCode();
              setState(() {
                addProductBarCode.text = code;
              });
            },
            decoration: new InputDecoration(
              hintText: Strings.product_bar_code,
              icon: new Icon(Icons.code),
            ),
            validator: (value) {
              return Tools.validateString(value, 5);
            },
          ),
        ]
        )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, type: ProgressDialogType.Normal,
        isDismissible: false, showLogs: true);
    pr.style(message: Strings.wait);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        title: new Text(Strings.appTitle),
        centerTitle: false,
        backgroundColor: Colors.lightBlueAccent,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.info), onPressed: () => Tools.about(context))
        ],
      ),
      body: body,
      //floatingActionButton: floatingActionButton,
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white70,
        unselectedItemColor: Colors.white,
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home), title: new Text(Strings.home)),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.person),
              title: new Text(Strings.update_profil)),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.settings), title: new Text(Strings.setting)),
        ],
        onTap: (value) => showScreen(value),
        currentIndex: currentTab,
      ),
      drawer: drawer(),
      floatingActionButton: floatingActionButton,
    );
  }

  // ----------> Functions & Methods <----------

  void showScreen(value) {
    setState(() {
      switch (value) {
        case 0:
          body = getHomeWidget();
          floatingActionButton = fab();
          break;
        case 1:
          updateFname.text = PharmasistHome.user.fname;
          updateLname.text = PharmasistHome.user.lname;
          updatePhone.text = PharmasistHome.user.phone;
          updateEmail.text = PharmasistHome.user.username;
          updatePassword.text = PharmasistHome.user.pass;
          updateMStart.text = Tools.getStringTime(PharmasistHome.user.moorningStart);
          updateMEnd.text = Tools.getStringTime(PharmasistHome.user.moorningEnd);
          updateEStart.text = Tools.getStringTime(PharmasistHome.user.eveningStart);
          updateEEnd.text = Tools.getStringTime(PharmasistHome.user.eveningEnd);
          body = Tools.getScrollWidget(getProfilWidget());
          floatingActionButton = null;
          break;
        case 2:
          //body = Tools.getScrollWidget(getSignUpWidget());
          floatingActionButton = null;
          break;
      }
      currentTab = value;
    });
  }

  void fillMedecnesList() async {
    ProgressDialog pr = ProgressDialog(context, type: ProgressDialogType.Normal,
        isDismissible: false, showLogs: true);
    pr.style(message: Strings.wait);

    if(!pr.isShowing())
      await pr.show();

    List<Product> x = await Api.getProductsList(
        Api.USER_PRODUCTS + "/${PharmasistHome.user.id}/1");

    if(pr.isShowing())
      await pr.hide();

    for(Product p in x)
      oldList.add(p);

    setState(() {
      if(medicinesList != null)
        medicinesList.clear();
      if(oldList != null)
        oldList.clear();
      medicinesList = x;
      oldList = medicinesList;
      length = medicinesList.length;
      body = getHomeWidget();
    });

  }

  void showAddProductWindow(){
    var alertDialog = new AlertDialog(
      title: Text(Strings.add_product),
      content: getAddProductWidget(),
      actions: <Widget>[
        new FlatButton(
            onPressed: sendToAddProduct,
            child: new Text(Strings.add_product)),
        new FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: new Text(Strings.cancel)),
      ],
    );
    showDialog(context: context, child: alertDialog, barrierDismissible: false);
  }

  void showUpdateProductWindow(Product product){

    setState(() {
      addProductName.text = product.productName;
      dropdownValue = product.productForm;
      addProductCntr.text = product.productCntr;
      addProductQuantity.text = product.productQuantity.toString();
      addProductPrice.text = product.productPrice.toString();
      addProductExpiration.text = product.productExpiration.toIso8601String().substring(0, 10);
      addProductBarCode.text = product.productCode;
    });

    var alertDialog = new AlertDialog(
      title: Text(Strings.update_product),
      content: getAddProductWidget(),
      actions: <Widget>[
        new FlatButton(
            onPressed: () => sendToUpdateProduct(product.productId),
            child: new Text(Strings.update_product)),
        new FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: new Text(Strings.cancel)),
      ],
    );
    showDialog(context: context, child: alertDialog, barrierDismissible: false);

  }

  void sendToAddProduct() async{
    /*if(!pr.isShowing())
      await pr.show();
*/
    Tools.showWaitDialog(context, Strings.server_response, Strings.wait);
    String response = await addProduct(Api.ADD_PRODUCT);
    Navigator.pop(context);
    /*if(pr.isShowing())
      await pr.hide();*/

    String title = Strings.server_response;
    String message = "";
    if(response != null)
      message = Strings.operation_success;
    else
      message = Strings.error;
    Tools.showAlertDialog(context, title, message);
    fillMedecnesList();
    cleanProductFields();
  }

  void sendToUpdateProduct(int id) async{
    /*if(!pr.isShowing())
      await pr.show();*/
    Tools.showWaitDialog(context, Strings.server_response, Strings.wait);
    String response = await updateProduct(Api.UPDATE_PRODUCT, id);
    Navigator.pop(context);
   /* if(pr.isShowing())
      await pr.hide();*/

    String title = Strings.server_response;
    String message = "";
    if(response != null)
      message = Strings.operation_success;
    else
      message = Strings.error;
    Navigator.pop(context);
    Tools.showAlertDialog(context, title, message);
    fillMedecnesList();
    cleanProductFields();
  }

  void sendToDeleteProduct(int productId) async{
    if(!pr.isShowing())
      await pr.show();

    String response = await deleteProduct(Api.DELETE_PRODUCT + productId.toString());

    if(pr.isShowing())
      await pr.hide();

    String title = Strings.server_response;
    String message = "";
    if(response != null)
      message = Strings.operation_success;
    else
      message = Strings.error;
    Navigator.pop(context);
    Tools.showAlertDialog(context, title, message);
    fillMedecnesList();
  }

  void sendToUpdateUser() async{
    if(!pr.isShowing())
      await pr.show();

    String response = await updateUser(Api.UPDATE_USER);

    if(pr.isShowing())
      await pr.hide();

    String title = Strings.server_response;
    String message = "";
    if(response != null) {
      message = Strings.operation_success;
      Map<String, String> data = await getUserMap();
      User u = await Api.fillUserObject(data);
      setState(() {
        PharmasistHome.user = u;
        /*PharmasistHome.user.id = u.id;
        PharmasistHome.user.fname = u.fname;
        PharmasistHome.user.lname = u.lname;
        PharmasistHome.user.phone = u.phone;
        PharmasistHome.user.username = u.username;
        PharmasistHome.user.pass = u.pass;
        PharmasistHome.user.locationx = u.locationx;
        PharmasistHome.user.locationy = u.locationy;
        PharmasistHome.user.isOpen = u.isOpen;
        PharmasistHome.user.distance = u.distance;
        PharmasistHome.user.moorningStart = u.moorningStart;
        PharmasistHome.user.moorningEnd = u.moorningEnd;
        PharmasistHome.user.eveningStart = u.eveningStart;
        PharmasistHome.user.eveningEnd = u.eveningEnd;*/
      });

    }else {
      message = Strings.error;
    }
    Tools.showAlertDialog(context, title, message);
  }

  void sendToDeleteUser() async{
    if(!pr.isShowing())
      await pr.show();

    String url = Api.DELETE_USER + PharmasistHome.user.id.toString();
    String response = await deleteUser(url);

    if(pr.isShowing())
      await pr.hide();

    String title = Strings.server_response;
    String message = "";
    if(response != null) {
      message = Strings.operation_success;
      Tools.showAlertDialog(context, title, message);
      disconnect();

    }else {
      message = Strings.error;
      Tools.showAlertDialog(context, title, message);
    }

  }

  void disconnect(){
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
        ModalRoute.withName("/AnonymosMain")
    );
  }

  void cleanProductFields(){
    setState(() {
      addProductName.clear();
      addProductCntr.clear();
      addProductQuantity.clear();
      addProductPrice.clear();
      addProductExpiration.clear();
      addProductBarCode.clear();
    });
  }

  void confirmDelete(int productId){

    var alertDialog = new AlertDialog(
      title: new Text(Strings.confirmation),
      content: new Text(Strings.confirm_delete),
      actions: <Widget>[
        new FlatButton(
            onPressed:(){
              sendToDeleteProduct(productId);
            },
            child: new Text(Strings.ok)),
        new FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: new Text(Strings.cancel)),
      ],
    );
    showDialog(context: context, child: alertDialog, barrierDismissible: false);

  }

  void confirmDeleteUser(){
    var alertDialog = new AlertDialog(
      title: new Text(Strings.confirmation),
      content: new Text(Strings.confirm_delete),
      actions: <Widget>[
        new FlatButton(
            onPressed:(){
              sendToDeleteUser();
            },
            child: new Text(Strings.ok)),
        new FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: new Text(Strings.cancel)),
      ],
    );
    showDialog(context: context, child: alertDialog, barrierDismissible: false);
  }

  void searchFor(String value) {
    List<Product> resultList = new List<Product>();
    if(value != ""){
      for(int i=0; i<oldList.length; i++){
        if(oldList[i].productName.toLowerCase().contains(value.toLowerCase())) {
          resultList.add(oldList[i]);
        }
      }
      setState(() {
        medicinesList = resultList;
        length = medicinesList.length;
        body = getHomeWidget();
      });
    }else{
      setState(() {
        medicinesList = oldList;
        length = medicinesList.length;
        body = getHomeWidget();
      });
    }
  }

  Map<String, String> getProductMap(){
    var data = new Map<String, String>();
    data["productName"] = addProductName.text;
    data["productForm"] = dropdownValue;
    data["productCntr"] = addProductCntr.text;
    data["productQuantity"] = addProductQuantity.text;
    data["productPrice"] = addProductPrice.text;
    data["productExpiration"] = addProductExpiration.text;
    data["user"] = PharmasistHome.user.id.toString();
    data["productCode"] = addProductBarCode.text;
    return data;
  }

  Future<Map<String, String>> getUserMap() async{
    var data = new Map<String, String>();
    data["id"] = PharmasistHome.user.id.toString();
    data["fname"] = updateFname.text;
    data["lname"] = updateLname.text;
    data["phone"] = updatePhone.text;
    data["username"] = updateEmail.text;
    data["pass"] = updatePassword.text;
    if(isChacked){
      List positions = await new User().getCurrentLocation();
      data["locationx"] = positions[1].toString();
      data["locationy"] = positions[0].toString();
    }else{
      data["locationx"] = PharmasistHome.user.locationx.toString();
      data["locationy"] = PharmasistHome.user.locationy.toString();
    }
    data["moorningStart"] = updateMStart.text;
    data["moorningEnd"] = updateMEnd.text;
    data["eveningStart"] = updateEStart.text;
    data["eveningEnd"] = updateEEnd.text;
    return data;
  }

// ----------> Send / Get Data From Server <----------

  Future<String> addProduct(url) async{
    http.Response response = await http.post(
      url,
      body: getProductMap(),
    );
    if(response.body.length > 0)
      return response.body.toString()[12];
    else
      return null;
  }

  Future<String> updateProduct(url, int id) async{
    Map<String, String> data = getProductMap();
    data["productId"] = id.toString();
    http.Response response = await http.put(
      url,
      body: data
    );

    if(response.body.length > 0)
      return response.body.toString()[12];
    else
      return null;
  }

  Future<String> deleteProduct(url) async{
    http.Response response = await http.delete(url);
    if(response.body.length > 0)
      return response.body.toString()[12];
    else
      return null;
  }

  Future<String> updateUser(url) async{
    Map<String, String> data = await getUserMap();
    http.Response response = await http.put(
      url,
      body: data,
    );
    if(response.body.length > 0)
      return response.body.toString()[12];
    else
      return null;
  }

  Future<String> deleteUser(url) async{
    http.Response response = await http.delete(url);
    if(response.body.length > 0)
      return response.body.toString()[12];
    else
      return null;
  }

}

class DropDownWidget extends StatefulWidget {
  DropDownWidget({Key key}) : super(key: key);

  @override
  _DropDownWidgetState createState() => _DropDownWidgetState();
}

String dropdownValue = Strings.product_forms[0];

class _DropDownWidgetState extends State<DropDownWidget> {

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: Icon(Icons.arrow_drop_down_circle),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
        });
      },
      items: Strings.product_forms
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

}

bool isChacked = false;

class CheckBoxWidget extends StatefulWidget {
  @override
  _CheckBoxWidgetState createState() => _CheckBoxWidgetState();
}

class _CheckBoxWidgetState extends State<CheckBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CheckboxListTile(
        value: isChacked,
        title: Text(Strings.change_position, textAlign: TextAlign.justify,),
        subtitle: Text(Strings.change_position_infos),
        secondary: Icon(Icons.location_on),
        onChanged: (bool checked){
          setState(() {
            isChacked = checked;
          });
        },
      ),
    );
  }
}