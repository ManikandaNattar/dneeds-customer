import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:daily_needs/colors.dart';

Widget centeredCircularProgressIndicator({Color color}) {
  return new Center(
    child: new CircularProgressIndicator(
      valueColor: new AlwaysStoppedAnimation<Color>(color ?? primaryColor),
    ),
  );
}

void calLoaderPage({BuildContext context}) {
  Navigator.of(context)
      .push(new PageRouteBuilder(
          opaque: false,
          barrierColor: Colors.black.withOpacity(0.3),
          barrierDismissible: false,
          maintainState: true,
          pageBuilder: (BuildContext context, _, __) {
            return new Theme(
              data: new ThemeData(
                scaffoldBackgroundColor: Colors.transparent,
                primaryColor: Colors.transparent,
              ),
              child: new WillPopScope(
                  child: new Center(
                    child: new Stack(
                      children: <Widget>[
                        new CircularProgressIndicator(
                          valueColor: new AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ],
                    ),
                  ),
                  onWillPop: () async {
                    return false;
                  }),
            );
          }))
      .then((onValue) {});
}

Widget editText(
    {String hint,
    TextInputType keyBoardType,
    bool hideText: false,
    Function(String) validator,
    TextEditingController textEditingController,
    FocusNode focusNode,
    FocusNode focusTo,
    int maxLength,
    ValueChanged<String> onChanged,
    Widget suffixIcon,
    TextCapitalization textCapitalization,
    BuildContext context,
    EdgeInsets padding,
    EdgeInsets contentPadding,
    Color labelColor,
    bool enable: true,
    bool isBox: false}) {
  return new Padding(
    padding: padding ?? EdgeInsets.all(5.0),
    child: TextFormField(
      enabled: enable,
      controller: textEditingController,
      focusNode: focusNode,
      maxLength: maxLength,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      decoration: new InputDecoration(
          counterText: "",
          contentPadding: contentPadding ?? new EdgeInsets.only(bottom: 3.0),
          labelText: hint,
          hasFloatingPlaceholder: true,
          focusedBorder: isBox
              ? new OutlineInputBorder(
                  borderSide: new BorderSide(color: primaryColor))
              : new UnderlineInputBorder(
                  borderSide: new BorderSide(color: primaryColor)),
          border: isBox ? new OutlineInputBorder() : new UnderlineInputBorder(),
          suffixIcon: suffixIcon,
          labelStyle: new TextStyle(color: labelColor ?? primaryColor)),
      obscureText: hideText,
      keyboardType: keyBoardType,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: (String value) {
        FocusScope.of(context).requestFocus(focusTo);
      },
    ),
  );
}

bottomSheetEditor({BuildContext context, Widget widget}) {
  showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return widget;
      });
}
