import 'dart:convert';


import 'package:shared_preferences/shared_preferences.dart';

import 'package:kasie_transie_web/data/route.dart' as lib;
import 'package:kasie_transie_web/data/user.dart' as lib;
import 'package:kasie_transie_web/data/association.dart' as lib;


import 'color_and_locale.dart';
import 'functions.dart';

final Prefs prefs = Prefs();

class Prefs {
  Future saveUser(lib.User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = user.toJson();
    var jx = json.encode(mJson);
    prefs.setString('user', jx);
    pp("🌽 🌽 🌽 Prefs: saveUser:  SAVED: 🌽 ${user.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<lib.User?> getUser() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('user');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var user = lib.User.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getUser 🧩  ${user.firstName} retrieved");
    return user;
  }

  Future saveRoute(lib.Route route) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = route.toJson();
    var jx = json.encode(mJson);
    prefs.setString('route', jx);
    pp("🌽 🌽 🌽 Prefs: saveRoute  SAVED: 🌽 ${route.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<lib.Route?> getRoute() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('route');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var route = lib.Route.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getRoute 🧩  ${route.name} retrieved");
    return route;
  }

  //

  Future saveColorAndLocale(ColorAndLocale colorAndLocale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = colorAndLocale.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ColorAndLocale', jx);
    pp("🌽 🌽 🌽 Prefs: saveColorAndLocale  SAVED: 🌽 ${colorAndLocale.toJson()} 🌽 🌽 🌽");
  }

  Future<ColorAndLocale> getColorAndLocale() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('ColorAndLocale');
    if (string == null) {
      return ColorAndLocale(themeIndex: 0, locale: 'en');
    }
    var jx = json.decode(string);
    var cl = ColorAndLocale.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getColorAndLocale 🧩  ${cl.toJson()} retrieved");
    return cl;
  }

  //


  Future saveAssociation(lib.Association association) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map mJson = association.toJson();
    var jx = json.encode(mJson);
    prefs.setString('ass', jx);
    pp("🌽 🌽 🌽 Prefs: saveAssociation:  SAVED: 🌽 ${association.toJson()} 🌽 🌽 🌽");
    return null;
  }

  Future<lib.Association?> getAssociation() async {
    var prefs = await SharedPreferences.getInstance();
    var string = prefs.getString('ass');
    if (string == null) {
      return null;
    }
    var jx = json.decode(string);
    var car = lib.Association.fromJson(jx);
    pp("🌽 🌽 🌽 Prefs: getAssociation 🧩  ${car.associationName} retrieved");
    return car;
  }

  Future saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    pp("🌽 🌽 🌽 Prefs: Email:  SAVED: 🌽 $email 🌽 🌽 🌽");
    return;
  }
  Future<String?> getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('email');
    pp("🌽 🌽 🌽 Prefs: Email:  RETRIEVED: 🌽 $s 🌽 🌽 🌽");
    return s;
  }

  Future saveDemoFlag(bool demo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('demo', demo);
    pp("🌽 🌽 🌽 Prefs: DemoFlag:  SAVED: 🌽 $demo 🌽 🌽 🌽");
    return;
  }
  Future<bool> getDemoFlag() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final s = prefs.getBool('demo');
    pp("🌽 🌽 🌽 Prefs: getDemoFlag:  RETRIEVED: 🌽 $s 🌽 🌽 🌽");
    return s == null? false: true;
  }
}
