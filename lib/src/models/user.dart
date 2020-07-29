import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  int height;  // this is for h  for bmi
  int weight; // this is for h  bm
  int age;
  String gender;
  String dailyActivity;
  double bmr;
  double bmi;
  Media image;

  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      dailyActivity = jsonMap['dailyActivity'] != null ? jsonMap['dailyActivity'] : '';
      gender = jsonMap['gender'] != null ? jsonMap['gender'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      height=jsonMap['height']!= null ?jsonMap['height'] : 0;
      age=jsonMap['age']!= null ?jsonMap['age'] : 0;
      bmi=jsonMap['bmi']!= null ?double.parse(jsonMap['bmi']) : 0.0;
      bmr=jsonMap['bmr']!= null ?double.parse(jsonMap['bmr']) : 0.0;
      weight=jsonMap['weight']!= null ?jsonMap['weight'] : 0;
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["bmr"] = bmr;
    //bmr
    map["height"] = height;
    map["bmi"] = bmi;
    map["weight"] = weight;
    map["age"] = age;
    map["gender"] = gender;
    map["dailyActivity"] = dailyActivity;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
    return address != null && address != '' && phone != null && phone != '';
  }
}
