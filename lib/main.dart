import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:toast/toast.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'DatabaseHelper.dart';
import 'User.dart';

Future<Database> database;
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Covid SMS'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String address = "";
  String name = "";
  String surname = "";
  String city = "";
  bool exists = false;
  List<String> recipents = ["13033"];

  List<User> userList = new List();
  List<String> locationList = [
    "Μετάβαση σε φαρμακείο ή επίσκεψη στον γιατρό",
    "Μετάβαση σε Σούπερ Μάρκετ",
    "Μετάβαση στην Τράπεζα",
    "Παροχή βοήθεις σε ανθρώπους που βρίσκονται σε ανάγκη",
    "Μετάβαση σε τελετή(π.χ γάμος,κηδεία,βάφτιση)",
    "Σωματική άσκηση σε εξωτερικο χώροή κίνηση με κατοικίδιο ζώο"
  ];
  List<String> images = [
    'assets/farmakeio.jpg',
    'assets/souper.jpg',
    'assets/bank.jpg',
    'assets/help.png',
    'assets/ceremony.jpg',
    'assets/run.png'
  ];

  @override
  void initState() {
    super.initState();
    //i epomeni seira xrisimopoieitai gia na kanei init otan ektelesei i async
    WidgetsBinding.instance.addPostFrameCallback((_) {
      readTableofUser();
    });
  }

  readTableofUser() async {
    await DatabaseHelper.instance.queryAllRows().then((value) {
      setState(() {
        value.forEach((element) {
          print(element);
          userList.add(User(
            name: element["name"],
            surname: element["surname"],
            address: element["address"],
            city: element["city"],
          ));
        });
      });
    }).catchError((error) {
      print(error);
    });
    print(userList);
    if (userList.isEmpty) {
      exists = false;
    } else {
      exists = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !exists
          ? Center(
              child: Card(
                  color: Colors.white,
                  child: Padding(
                      padding: EdgeInsets.only(top: 150),
                      child: Column(
                        children: <Widget>[
                          new ListTile(
                            leading: const Icon(Icons.person),
                            title: new TextField(
                              decoration: new InputDecoration(
                                hintText: "Όνομα *",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  name = value.toUpperCase();
                                });
                              },
                            ),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.person),
                            title: new TextField(
                              decoration: new InputDecoration(
                                hintText: "Επώνυμο *",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  surname = value.toUpperCase();
                                });
                              },
                            ),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.code),
                            title: new TextField(
                              decoration: new InputDecoration(
                                hintText: "Διεύθυνση Κατοικίας *",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  address = value.toUpperCase();
                                });
                              },
                            ),
                          ),
                          new ListTile(
                            leading: const Icon(Icons.location_city),
                            title: new TextField(
                              decoration: new InputDecoration(
                                hintText: "Πόλη *",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  city = value.toUpperCase();
                                });
                              },
                            ),
                          ),
                          Container(
                              padding: EdgeInsets.all(28.0),
                              child: FlatButton(
                                onPressed: () {
                                  name == "" ||
                                          city == "" ||
                                          address == "" ||
                                          surname == ""
                                      ? Toast.show(
                                          "Συμπληρώστε όλα τα πεδία!", context,
                                          duration: Toast.LENGTH_LONG,
                                          gravity: Toast.BOTTOM)
                                      : storageintoDatabase(
                                          name, surname, address, city);
                                },
                                child: Text(
                                  'ΑΠΟΘΉΚΕΥΣΗ',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                color: Colors.grey,
                              ))
                        ],
                      ))))
          : Center(
              child: Column(children: <Widget>[
              SizedBox(height: 40.0),
              Text(
                "Καλωσήλθατε κ." + userList[0].name + " " + userList[0].surname,
                style: TextStyle(fontSize: 17, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 40.0),
              Expanded(
                  child: ListView.builder(
                      itemCount: locationList.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return new GestureDetector(
                            onTap: () => {
                                  _sendSMS(
                                      '${index + 1} ${userList[0].name} ${userList[0].surname} ${userList[0].address} ${userList[0].city}',
                                      recipents)
                                },
                            child: Container(
                                child: Card(
                                    child: Container(
                              child: Row(
                                children: <Widget>[
                                  Hero(
                                    tag: images[index],
                                    child: Container(
                                      height: 90.0,
                                      width: 70.0,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              topLeft: Radius.circular(5)),
                                          image: DecorationImage(
                                              image:
                                                  AssetImage(images[index]))),
                                    ),
                                  ),
                                  Container(
                                    height: 80,
                                    width: 240,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                            child: Text(locationList[index],
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                  color: Colors.red[900],
                                                ))),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.arrow_right,
                                  )
                                ],
                              ),
                            ))));
                      }))
            ])),
    );
  }

  storageintoDatabase(
      String name, String surname, String address, String city) async {
    var user = User(
      name: name,
      surname: surname,
      address: address,
      city: city,
    );
    await DatabaseHelper.instance.insert(user);
    setState(() {
      userList.insert(0, user);
      print(userList);
      Toast.show(
          "Τα στοιχεία σας καταχωρήθηκαν!Ανοίξτε ξανά την εφαρμογή για να στείλετε το μήνυμα.",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM);
      Navigator.of(context).pop();
      SystemNavigator.pop();
      exit(0);
    });
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}
