import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:pharmasist/api.dart';
import 'package:pharmasist/home.dart';
import 'package:pharmasist/product_detail.dart';
import 'package:pharmasist/sender.dart';
import 'package:pharmasist/tools.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog/progress_dialog.dart';
import 'models.dart';
import 'strings.dart';

void main() {
  runApp(new MaterialApp(
    title: Strings.appTitle,
    home: new Home(),
    routes: <String, WidgetBuilder>{
        '/PharmasistHome': (BuildContext context) => new PharmasistHome(),
        '/AnonymosMain': (BuildContext context) => new Home(),
    }
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();

}

class _HomeState extends State<Home> {

  @override
  void initState() {
    super.initState();
    medicinesList = new List<Product>();
    this.body = getHomeWidget();
    floatingActionButton = fab();
  }

  // ----------> Variables & objects <----------

  Widget body;
  Widget floatingActionButton;

  ProgressDialog pr;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final _forgetPasswordFormKey = GlobalKey<FormState>();

  TextEditingController homeSearch = new TextEditingController();

  TextEditingController loginEmail = new TextEditingController();
  TextEditingController loginPassword = new TextEditingController();

  TextEditingController registerFname = new TextEditingController();
  TextEditingController registerLname = new TextEditingController();
  TextEditingController registerPhone = new TextEditingController();
  TextEditingController registerEmail = new TextEditingController();
  TextEditingController registerPassword = new TextEditingController();
  TextEditingController registerMStart = new TextEditingController();
  TextEditingController registerMEnd = new TextEditingController();
  TextEditingController registerEStart = new TextEditingController();
  TextEditingController registerEEnd = new TextEditingController();

  TextEditingController forgetPassword = new TextEditingController();

  List<Product> medicinesList;

  int currentTab = 0;

  // ----------> Widgets <----------

  Widget fab() {
    return new FloatingActionButton(
      // onPressed: scanQRCode,
      child: new Icon(Icons.camera_alt, color: Colors.white),
      backgroundColor: Colors.lightBlueAccent,
      onPressed: () {
        scanQR();
      },
    );
  }

  Widget getHomeWidget() {
    return new Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.all(20),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: homeSearch,
                    keyboardType: TextInputType.text,
                    onSubmitted: (value) {
                      search(value);
                    },
                    maxLength: 30,
                    decoration: new InputDecoration(
                      icon: new Icon(Icons.search),
                      hintText: Strings.searchField,
                    ),
                  ),
                  flex: 5,
                ),
                new Padding(padding: EdgeInsets.all(15)),
                new Expanded(
                  child: new RaisedButton(
                    onPressed: () {
                      Tools.showAlertDialog(context, Strings.appTitle, Strings.not_yet);
                    },
                    child: new Icon(Icons.mic, color: Colors.white),
                    color: Colors.lightBlueAccent,
                  ),
                  flex: 1,
                )
              ],
            ),
            new Padding(padding: EdgeInsets.only(top: 8)),
            new Expanded(
              //height: 200.0,
              child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: medicinesList.length,
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
                                  new Padding(
                                      padding: EdgeInsets.only(top: 10)),
                                  new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new Text(Strings.product_form +
                                            medicinesList[position]
                                                .productForm),
                                        flex: 1,
                                      ),
                                      new Expanded(
                                        child: new Text(Strings.product_price +
                                            medicinesList[position]
                                                .productPrice
                                                .toStringAsFixed(2) +
                                            "DAَ"),
                                        flex: 1,
                                      ),
                                    ],
                                  ),
                                  new Padding(
                                      padding: EdgeInsets.only(top: 10)),
                                  new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        child: new Text(
                                            Strings.pharmasist_distance +
                                                medicinesList[position]
                                                    .user
                                                    .distance
                                                    .toStringAsFixed(2) + "KM"),
                                        flex: 2,
                                      ),
                                      new Expanded(
                                        child: new Text(
                                          (medicinesList[position].user.isOpen)
                                              ? Strings.open
                                              : Strings.close,
                                          style: new TextStyle(
                                              color: (medicinesList[position].user.isOpen)
                                                  ? Colors.lightGreen
                                                  : Colors.red),
                                        ),
                                        flex: 1,
                                      )
                                    ],
                                  ),
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
                                        color: Colors.white)),
                              ),
                              trailing: new Listener(
                                child: new Column(
                                  children: <Widget>[
                                    new Padding(padding: EdgeInsets.only(top: 22)),
                                    new Icon(Icons.more,
                                        color: Colors.lightBlueAccent)
                                  ],
                                ),
                                onPointerDown: (pointerEvent) {
                                  var router = new MaterialPageRoute(
                                      builder: (BuildContext context) => MapSample(medicinesList[position])
                                  );
                                  Navigator.of(context).push(router);
                                },
                              ),
                            )));
                  }),
              //flex: 1,
            )
          ],
        ),
      ),
    );
  }

  Widget getSignInWidget() {
    return new Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.all(30),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Padding(padding: EdgeInsets.only(top: 50)),
            Image.asset('images/logo5.png', width: 250.0, height: 250.0),
            new Padding(padding: EdgeInsets.only(top: 50)),
            Form(
                key: _loginFormKey,
                child: Column(children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: loginEmail,
                    maxLength: 50,
                    decoration: new InputDecoration(
                      hintText: Strings.email,
                      icon: new Icon(Icons.person),
                    ),
                    validator: (value) {
                      return Tools.validateString(value, 0);
                    },
                  ),
                  new TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: loginPassword,
                      maxLength: 50,
                      obscureText: true,
                      decoration: new InputDecoration(
                        hintText: Strings.password,
                        icon: new Icon(Icons.lock),
                      ),
                      validator: (value) {
                        return Tools.validateString(value, 1);
                      }),
                  new Padding(padding: EdgeInsets.only(top: 20)),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () {
                          if (_loginFormKey.currentState.validate()) {
                            sendToLogin();
                          }
                        },
                        child: new Text(
                          Strings.signin,
                          style: new TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                      new Padding(padding: EdgeInsets.all(15)),
                      new RaisedButton(
                        onPressed: () {
                          print("back");
                        },
                        child: new Text(Strings.back,
                            style: new TextStyle(color: Colors.white)),
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  )
                ])),
            new Padding(padding: EdgeInsets.only(top: 15)),
            new InkWell(
              borderRadius: new BorderRadius.circular(5.5),
              child: new Container(
                padding: new EdgeInsets.all(5),
                child: new Text(Strings.i_dont_have_account),
              ),
              onTap: () => showScreen(2),
            ),
            new Padding(padding: EdgeInsets.only(top: 10)),
            new InkWell(
              borderRadius: new BorderRadius.circular(5.5),
              child: new Container(
                padding: new EdgeInsets.all(5),
                child: new Text(Strings.i_forget_my_password),
              ),
              onTap: () => showForgetPasswordWindow(),
            )
          ],
        ),
      ),
    );
  }

  Widget getSignUpWidget() {
    return new Container(
      alignment: Alignment.center,
      margin: new EdgeInsets.all(30),
      child: new Center(
        child: new Column(
          children: <Widget>[
            new Padding(padding: EdgeInsets.only(top: 50)),
            Image.asset('images/logo5.png', width: 250.0, height: 250.0),
            new Padding(padding: EdgeInsets.only(top: 50)),
            Form(
                key: _registerFormKey,
                child: Column(children: <Widget>[
                  new TextFormField(
                    keyboardType: TextInputType.text,
                    controller: registerFname,
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
                    controller: registerLname,
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
                    controller: registerPhone,
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
                      controller: registerEmail,
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
                      controller: registerPassword,
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
                                  registerMStart.text = Tools.fillDate2(date);
                                });
                              }, onConfirm: (date) {
                                setState(() {
                                  registerMStart.text = Tools.fillDate2(date);
                                });
                              }, currentTime: DateTime.now());
                            },
                              controller: registerMStart,
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
                                    registerMEnd.text = Tools.fillDate2(date);
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    registerMEnd.text = Tools.fillDate2(date);
                                  });
                                }, currentTime: DateTime.now());
                              },
                              readOnly: true,
                              showCursor: true,
                              controller: registerMEnd,
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
                                  registerEStart.text = Tools.fillDate2(date);
                                });
                              }, onConfirm: (date) {
                                setState(() {
                                  registerEStart.text = Tools.fillDate2(date);
                                });
                              }, currentTime: DateTime.now());
                            },
                            readOnly: true,
                            showCursor: true,
                            controller: registerEStart,
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
                                    registerEEnd.text = Tools.fillDate2(date);
                                  });
                                }, onConfirm: (date) {
                                  setState(() {
                                    registerEEnd.text = Tools.fillDate2(date);
                                  });
                                }, currentTime: DateTime.now());
                              },
                              readOnly: true,
                              showCursor: true,
                              controller: registerEEnd,
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
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () {
                          if (_registerFormKey.currentState.validate()) {
                            sendToRegister();
                          }
                        },
                        child: new Text(
                          Strings.signup,
                          style: new TextStyle(color: Colors.white),
                        ),
                        padding: EdgeInsets.only(
                            left: 25, right: 25, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                      new Padding(padding: EdgeInsets.all(15)),
                      new RaisedButton(
                        onPressed: () {
                          print("back");
                        },
                        child: new Text(Strings.back,
                            style: new TextStyle(color: Colors.white)),
                        padding: EdgeInsets.only(
                            left: 20, right: 20, top: 10, bottom: 10),
                        color: Colors.lightBlueAccent,
                      ),
                    ],
                  )
                ])),
            new Padding(padding: EdgeInsets.only(top: 15)),
            new InkWell(
              borderRadius: new BorderRadius.circular(5.5),
              child: new Container(
                padding: new EdgeInsets.all(5),
                child: new Text(Strings.i_have_account),
              ),
              onTap: () => showScreen(1),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
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
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: new BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.lightBlueAccent,
        selectedItemColor: Colors.white70,
        unselectedItemColor: Colors.white,
        items: [
          new BottomNavigationBarItem(
              icon: new Icon(Icons.home), title: new Text(Strings.home)),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.person), title: new Text(Strings.signin)),
          new BottomNavigationBarItem(
              icon: new Icon(Icons.accessibility_new),
              title: new Text(Strings.signup)),
        ],
        onTap: (value) => showScreen(value),
        currentIndex: currentTab,
      ),
    );
  }

  // ----------> Functions & Methods <---------

  void showScreen(value) {
    setState(() {
      switch (value) {
        case 0:
          body = getHomeWidget();
          floatingActionButton = fab();
          break;
        case 1:
          body = Tools.getScrollWidget(getSignInWidget());
          floatingActionButton = null;
          break;
        case 2:
          body = Tools.getScrollWidget(getSignUpWidget());
          floatingActionButton = null;
          break;
      }
      currentTab = value;
    });
  }

  void search(value) async {
    pr.show();
    pr.style(message: Strings.wait);

    value = value.toString().toLowerCase();
    List<Product> x = await Api.getProductsList(Api.FIND_PRODUCT + "/" + value + "/1");
    //List<Product> x = await getJsonData(Api.SEARCH_PRODUCT + value + "&order=1");

    setState(() {
      medicinesList = x;
      body = getHomeWidget();
    });

    pr.hide();
  }

  void sendToLogin() async{
    pr.show();
    pr.style(message: Strings.wait);

    User user = await login(Api.FIND_USER);

    pr.hide();

    if(user != null){
      PharmasistHome.user = user;
      Navigator.of(context).popAndPushNamed("/PharmasistHome");
    }else{
      String title = Strings.server_response;
      String message = Strings.user_or_password_incorrect;
      Tools.showAlertDialog(context, title, message);
      cleanLoginFields();
    }

  }

  void sendToRegister() async{
    pr.show();
    pr.style(message: Strings.wait);

    String result = await register(Api.ADD_USER);
    String title = Strings.server_response;
    String message = "";

    switch(result){
      case "0":
        message = Strings.operation_success;
        cleanFields();
        break;
      case "1":
        message = Strings.email_exist;
        break;
      case "2":
        message = Strings.phone_exist;
        break;
    }

    pr.hide();

    Tools.showAlertDialog(context, title, message);
  }

  void cleanFields() {
    setState(() {
      registerFname.clear();
      registerLname.clear();
      registerPhone.clear();
      registerEmail.clear();
      registerPassword.clear();
      registerMStart.clear();
      registerMEnd.clear();
      registerEStart.clear();
      registerEEnd.clear();
    });
  }

  void cleanLoginFields() {
    setState(() {
      loginEmail.clear();
      loginPassword.clear();
    });
  }

  void cleanResetPassFields() {
    setState(() {
      forgetPassword.clear();
    });
  }

  void showForgetPasswordWindow(){
    var alertDialog = new AlertDialog(
      title: Text(Strings.reset_password),
      content: new Container(
        child: Form(
          key: _forgetPasswordFormKey,
          child: SingleChildScrollView(child: Column(children: <Widget>[
            new TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: forgetPassword,
              maxLength: 50,
              decoration: new InputDecoration(
                hintText: Strings.email,
                icon: new Icon(Icons.mail),
              ),
              validator: (value) {
                return Tools.validateString(value, 0);
              },
            ),
          ]
          )),
        ),
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () => sendToRestPassword(),
            child: new Text(Strings.send)),
        new FlatButton(
            onPressed: (){Navigator.pop(context);},
            child: new Text(Strings.cancel)),
      ],
    );
    showDialog(context: context, child: alertDialog, barrierDismissible: false);
  }

  void sendToRestPassword() async{
    pr.show();
    pr.style(message: Strings.wait);

    User user = await resetPassword(Api.RESET_PASSWORD);

    String title, message;

    if(user != null){
      message = "Email: " + user.username + ", Mot de passe: " + user.pass;
      String subject = Strings.reset_password;
      String email = user.username;

      bool x = await Sender.sendingMail(email, subject, message);

      if(x) {
        title = Strings.server_response;
        message = Strings.operation_success;
      }else {
        title = Strings.server_response;
        message = Strings.error;
      }
    }else{
      title = Strings.server_response;
      message = Strings.error;
    }

    pr.hide();

    Tools.showAlertDialog(context, title, message);
    cleanResetPassFields();
  }

  // ----------> Send / Get Data From Server <----------

  Future<String> register(url) async{
    List positions = await new User().getCurrentLocation();

    var data = new Map<String, String>();
    data["fname"] = registerFname.text;
    data["lname"] = registerLname.text;
    data["phone"] = registerPhone.text;
    data["username"] = registerEmail.text;
    data["pass"] = registerPassword.text;
    data["locationx"] = positions[1].toString();
    data["locationy"] = positions[0].toString();
    data["moorningStart"] = registerMStart.text;
    data["moorningEnd"] = registerMEnd.text;
    data["eveningStart"] = registerEStart.text;
    data["eveningEnd"] = registerEEnd.text;

    http.Response response = await http.post(
      url,
      body: data,
    );

    return response.body.toString()[12];
  }

  Future<User> login(url) async{
    var data = new Map<String, String>();
    data["username"] = loginEmail.text;
    data["pass"] = loginPassword.text;

    http.Response response = await http.post(
      url,
      body: data,
    );

    List jsonList = json.decode(response.body);
    User user = null;
    if(jsonList.length > 0)
      user = await Api.fillUserObject(jsonList[0]);
    return user;
  }

  Future<User> resetPassword(String url) async{
    var data = new Map<String, String>();
    data["username"] = forgetPassword.text;

    http.Response response = await http.post(
      url,
      body: data,
    );

    List jsonList = json.decode(response.body);
    User user = null;
    if(jsonList.length > 0)
      user = await Api.fillUserObject(jsonList[0]);
    return user;
  }

  void scanQR() async{
    String code = await Tools.scanQRCode();
    setState(() {
      homeSearch.text = code;
    });
  }

}