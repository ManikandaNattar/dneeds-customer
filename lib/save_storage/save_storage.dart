import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;

save_string_prefs(String pref_name, String value) async {
  // obtain shared preferences
  prefs = await SharedPreferences.getInstance();

// set value
  prefs.setString(pref_name, value);
}

save_bool_prefs(String key, bool value) async {
  // obtain shared preferences
  prefs = await SharedPreferences.getInstance();

// set value
  prefs.setBool(key, value);
}

save_stringList_pref(String key, List<String> value) async {
  prefs = await SharedPreferences.getInstance();
  prefs.setStringList(key, value);
}

Future<List<String>> get_stringList_pref(String key) async {
  prefs = await SharedPreferences.getInstance();
  return prefs.getStringList(key) ?? [""];
}

Future<String> get_string_prefs(String pref_name) async {
  prefs = await SharedPreferences.getInstance();

// Try reading data from the counter key. If it does not exist, return 0.
  // print(prefs.getString(pref_name));
  return prefs.getString(pref_name) ?? "";
}

Future<bool> get_bool_prefs(String key) async {
  prefs = await SharedPreferences.getInstance();

// Try reading data from the counter key. If it does not exist, return 0.
  // print(prefs.getString(pref_name));
  return prefs.getBool(key) ?? false;
}

clearPrefs() {
  prefs.clear();
}
