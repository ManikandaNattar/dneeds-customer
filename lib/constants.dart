import 'dart:math';
import 'package:daily_needs/colors.dart';
import 'package:flutter/material.dart';

String appName = "Daily Needs";

//Display
double deviceHeight = 0.0;
double deviceWidth = 0.0;
double size = 0.0;

//FontSize
double fontSizeMedium = 0.0;
double fontSizeSmall = 0.0;
double fontSizeLarge = 0.0;

void calculateFontSizeWithDeviceSize(BuildContext context) {
  if (MediaQuery.of(context).orientation == Orientation.portrait) {
    deviceHeight = MediaQuery.of(context).size.height;

    deviceWidth = MediaQuery.of(context).size.width;
  } else {
    deviceHeight = MediaQuery.of(context).size.width;
    deviceWidth = MediaQuery.of(context).size.height;
  }
  fontSizeMedium = deviceWidth / 24.0;
  fontSizeSmall = deviceWidth / 34.2;
  fontSizeLarge = deviceWidth / 18.1;
}

//Default Theme Engine
buildTheme() {
  final ThemeData base = ThemeData.light();

  return base.copyWith(
    primaryColor: primaryColor,
    primaryColorDark: primaryColorDark,
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme, Colors.black87),
    primaryIconTheme: base.iconTheme.copyWith(
      color: Colors.black87,
    ),
    iconTheme: base.iconTheme.copyWith(
      color: Colors.black87,
    ),
    appBarTheme: AppBarTheme(brightness: Brightness.light),
    dialogBackgroundColor: Colors.white,
    splashColor: primaryColor,
    buttonColor: buttonColor,
    accentColor: buttonColor,
    scaffoldBackgroundColor: splashColor,
    cardColor: Colors.white,
    canvasColor: Colors.white,
    textSelectionColor: Colors.white,
    errorColor: Colors.red,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      height: 42.0,
    ),
    textSelectionHandleColor: textColor,
    accentTextTheme: _buildTextTheme(base.accentTextTheme, textColor),
    textTheme: _buildTextTheme(base.textTheme, textColor),
  );
}

_buildTextTheme(TextTheme base, Color color) {
  return base
      .copyWith(
          headline: base.headline.copyWith(fontWeight: FontWeight.w500),
          title: base.title.copyWith(fontSize: 18.0),
          caption: base.caption
              .copyWith(fontWeight: FontWeight.w400, fontSize: 14.0))
      .apply(displayColor: color, bodyColor: color);
}

//Preference
String userDetailsPref = "USER_DETAILS";
String tokenPref = "TOKEN";
String userIdPref = "USER_ID";
int userIdConstant;
Map userDetailsConstant;
