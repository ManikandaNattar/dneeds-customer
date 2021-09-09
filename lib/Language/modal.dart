import 'package:flutter/material.dart';

class Modal {
  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, 'English', _action1),
              _createTile(context, 'Tamil', _action2),
              _createTile(context, 'Hindi', _action3),
            ],
          );
        });
  }

  ListTile _createTile(BuildContext context, String name, Function action) {
    return ListTile(
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        action();
      },
    );
  }

  _action1(BuildContext context) {
    Navigator.pop(context);
  }

  _action2(BuildContext context) {
    Navigator.pop(context);
  }

  _action3(BuildContext context) {
    Navigator.pop(context);
  }
}
