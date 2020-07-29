import 'package:fit_kit/fit_kit.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:markets/src/elements/WeightCard.dart';
import 'package:markets/src/models/user.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';

import '../../generated/l10n.dart';
import '../controllers/user_controller.dart';
import '../elements/BlockButtonWidget.dart';
import '../helpers/app_config.dart' as config;

class CalorieCalculator extends StatefulWidget {
  @override
  _CalorieCalculatortState createState() => _CalorieCalculatortState();
}

class _CalorieCalculatortState extends StateMVC<CalorieCalculator> {
  UserController _con;
  User _user;

//Daily exercise or intense exercise 3-4 times/weekly
  List<Map> WorkTypes = [
    {"id": "Little or no exercise", "name": "Little or no exercise"},
    {"id": "Exercise 1-3 times/weekly", "name": "Exercise 1-3 times/weekly"},
    {"id": "Exercise 4-5 times/weekly", "name": "Exercise 4-5 times/weekly"},
    {
      "id": "Very intense exercise daily, or physical job",
      "name": "Very intense exercise daily, or physical job"
    },
    {
      "id": "Daily exercise or intense exercise 3-4 times/weekly",
      "name": "Daily exercise or intense exercise 3-4 times/weekly"
    }
  ];
  List<Map> genders = [
    {"id": "male", "name": "male"},
    {"id": "female", "name": "female"}
  ];

  String result = '', WorkType, Gender;
  Map<DataType, List<FitData>> results = Map();
  bool permissions;

  RangeValues _dateRange = RangeValues(1, 8);
  List<DateTime> _dates = List<DateTime>();
  double _limitRange = 0;

  DateTime get _dateFrom => _dates[_dateRange.start.round()];
  DateTime get _dateTo => _dates[_dateRange.end.round()];
  int get _limit => _limitRange == 0.0 ? null : _limitRange.round();

  _CalorieCalculatortState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    //   initPlatformState();
    // getCurrentUser()

    print(currentUser.value);
    final now = DateTime.now();
    _dates.add(null);
    for (int i = 7; i >= 0; i--) {
      _dates.add(DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i)));
    }
    _dates.add(null);

    //hasPermissions();
    // read();
    // read2();
  }

  Future<void> read2() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.activityRecognition
    ].request();
    print(statuses[Permission.sensors]);
  }

  Future<void> read() async {
    results.clear();

    try {
      permissions = await FitKit.requestPermissions(DataType.values);
      print("67");
      if (!permissions) {
        print("fail to get permission");
        result = 'requestPermissions: failed';
      } else {
        print("has");
        for (DataType type in DataType.values) {
          try {
            results[type] = await FitKit.read(
              type,
              dateFrom: _dateFrom,
              dateTo: _dateTo,
              limit: _limit,
            );
          } on UnsupportedException catch (e) {
            results[e.dataType] = [];
            print("79");
          }
        }
        print("83");
        result = 'readAll: success';
      }
    } catch (e) {
      result = 'readAll: $e';
    }

    setState(() {});
  }

  Future<void> hasPermissions() async {
    try {
      permissions = await FitKit.hasPermissions(DataType.values);

      print("has");
      for (DataType type in DataType.values) {
        try {
          results[type] = await FitKit.read(
            type,
            dateFrom: _dateFrom,
            dateTo: _dateTo,
            limit: _limit,
          );
          print(results);
        } on UnsupportedException catch (e) {
          results[e.dataType] = [];
        }
      }
      print("83");
      result = 'readAll: success';
    } catch (e) {
      result = 'hasPermissions: $e';
      print(result);
    }

    if (!mounted) return;

    setState(() {});
  }

  Future<void> revokePermissions() async {
    results.clear();

    try {
      await FitKit.revokePermissions();
      permissions = await FitKit.hasPermissions(DataType.values);
      result = 'revokePermissions: success';
    } catch (e) {
      result = 'revokePermissions: $e';
    }

    setState(() {});
  }

  // Platform messages are asynchronous, so we initialize in an async method.

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        key: _con.scaffoldKey,
        resizeToAvoidBottomPadding: false,
        body: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(29.5),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(29.5),
                child: Text(
                  S.of(context).lets_Calculate_your_Calorie,
                  style: Theme.of(context)
                      .textTheme
                      .headline2
                      .merge(TextStyle(color: Theme.of(context).primaryColor)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(29.5) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding: EdgeInsets.symmetric(vertical: 50, horizontal: 27),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: _con.loginFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) => _con.user.height = int.parse(input),
                        validator: (input) => input.length < 3
                            ? S.of(context).should_be_more_than_3_letters
                            : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).height,
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: S.of(context).height,
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.person_outline,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        onSaved: (input) => _con.user.weight = int.parse(input),
                        //     validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).weight,
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '69k',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.shopping_basket,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),

                      SizedBox(height: 30),

                      TextFormField(
                        onSaved: (input) => _con.user.age = int.parse(input),
                        //     validator: (input) => !input.contains('@') ? S.of(context).should_be_a_valid_email : null,
                        decoration: InputDecoration(
                          labelText: S.of(context).age,
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '24',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.accessibility,
                              color: Theme.of(context).accentColor),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),

                      SearchableDropdown.single(
                        isExpanded: true,
                        hint: Text("gender"),
                        value: Gender,
                        items: genders.map((Map map) {
                          return new DropdownMenuItem<Map>(
                            value: map,
                            child: new Text(map["name"].toString()),
                          );
                        }).toList(),
                        onChanged: (Map va) {
                          setState(() {
                            Gender = va["id"].toString();
                            _con.user.gender = Gender;
                          });
                        },
                      ),

                      SizedBox(height: 15),
                      SearchableDropdown.single(
                        isExpanded: true,
                        hint: Text("Activity"),
                        value: WorkType,
                        items: WorkTypes.map((Map map) {
                          return new DropdownMenuItem<Map>(
                            value: map,
                            child: new Text(map["name"].toString()),
                          );
                        }).toList(),
                        onChanged: (Map va) {
                          setState(() {
                            WorkType = va["id"].toString();
                            _con.user.dailyActivity = WorkType;
                          });
                        },
                      ),

                      BlockButtonWidget(
                        text: Text(
                          S.of(context).save,
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          _con.bmica();
                        },
                      ),
                      SizedBox(height: 25),
//                      FlatButton(
//                        onPressed: () {
//                          Navigator.of(context).pushNamed('/MobileVerification');
//                        },
//                        padding: EdgeInsets.symmetric(vertical: 14),
//                        color: Theme.of(context).accentColor.withOpacity(0.1),
//                        shape: StadiumBorder(),
//                        child: Text(
//                          'Register with Google',
//                          textAlign: TextAlign.start,
//                          style: TextStyle(
//                            color: Theme.of(context).accentColor,
//                          ),
//                        ),
//                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
