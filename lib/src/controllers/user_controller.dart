import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fit_kit/fit_kit.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:markets/src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:math' as math;

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as repository;

class UserController extends ControllerMVC {
  User user = new User();
  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;

  double _bmi;

  double _minwi,_maxw;

  bool mounted=false;

  double _extra_energy;

  var _energy_needs;

  UserController() {

    Health2();
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
  }

  void login() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_account_not_exist),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  void register() async {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.register(user).then((value) {
        if (value != null && value.apiToken != null) {
          Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Pages', arguments: 2);
        } else {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).wrong_email_or_password),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).this_email_account_exists),
        ));
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }


  void bmica(){
    loginFormKey.currentState.save();
    _bmi = user.weight/math.pow(user.height/ 100, 2);
    _minwi=(18.5 *math.pow(user.height/ 100, 2));
    _maxw=(25 *math.pow(user.height/ 100, 2));

      print("BMI::  "+_bmi.toString());
      print("min::  "+_minwi.toString());
      print("max::  "+_maxw.toString());

    // print(_bmi);  18.5 * _heightSquared(height);   $BMR=66 + (6.3 * $_POST["lbs"]) + (12.9 * $inch) - (6.8 * $_POST["age"]);

    print(BMICategory(_bmi));
    print(user.gender);
   // print(user.dailyActivity);


    var newcm=user.height * 0.3937;



    var ft = newcm / 12;
    var remain= newcm % 12;
    var inchs= remain;


    var Lastinch=ft*12+inchs;

    if(user.gender=='male'){



      user.bmr=66+(6.3 * (user.weight*2.2))+(12.9*Lastinch)-(6.8*user.age);
      bmr(user.dailyActivity);

      _extra_energy=user.bmr*bmr(user.dailyActivity);
      _energy_needs=user.bmr+_extra_energy;

      print(_extra_energy);
      print(_energy_needs);
    }

    else{


      user.bmr=655+(4.3 * (user.weight*2.2))+(4.7*Lastinch)-(4.7*user.age);
      bmr(user.dailyActivity);

      _extra_energy=user.bmr*bmr(user.dailyActivity);
      _energy_needs=user.bmr+_extra_energy;

      print(_extra_energy);
      print(_energy_needs);
    }




    update(user);


  }


  String BMICategory(_bmi)
  {


    if(_bmi<16)
      return "Severe Thinness	";

    else if (_bmi>16 && _bmi<17) return "Moderate Thinness";
    else if (_bmi>17 && _bmi<18.5) return "Mild Thinness";
    else if (_bmi>18.5 && _bmi<25) return "Normal";
    else if (_bmi>25 && _bmi<30) return "Overweight";
    else if (_bmi>30 && _bmi<35) return "Obese Class I	";
    else if (_bmi>35 && _bmi<40) return "Obese Class II	";
    else return "Obese Class III";




  }

  double  bmr(activitytpe)

  {


    switch(activitytpe){

      case"Little or no exercise": return 0.2; break;
      case"Exercise 1-3 times/weekly": return 0.375; break;
      case"Exercise 4-5 times/weekly": return 0.55; break;
      case"Daily exercise or intense exercise 3-4 times/weekly": return 0.725; break;
      case"Very intense exercise daily, or physical job": return 0.9; break;


  }


  }







  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> Health2() async {

  }


  void resetPassword() {
    FocusScope.of(context).unfocus();
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      Overlay.of(context).insert(loader);
      repository.resetPassword(user).then((value) {
        if (value != null && value == true) {
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).your_reset_link_has_been_sent_to_your_email),
            action: SnackBarAction(
              label: S.of(context).login,
              onPressed: () {
                Navigator.of(scaffoldKey.currentContext).pushReplacementNamed('/Login');
              },
            ),
            duration: Duration(seconds: 10),
          ));
        } else {
          loader.remove();
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).error_verify_email_settings),
          ));
        }
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }
}
