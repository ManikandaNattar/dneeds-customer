import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonMap {
  String actionName;
  Function() buttonAction;

  ButtonMap({this.actionName, this.buttonAction});
}

class CustomDialogue extends StatefulWidget {
  bool isSimpleDialogue;
  String message;
  List<ButtonMap> buttonList;

  CustomDialogue(
      {Key key, this.isSimpleDialogue: true, this.message, this.buttonList})
      : super(key: key);

  @override
  _CustomDialogueState createState() => _CustomDialogueState();
}

class _CustomDialogueState extends State<CustomDialogue> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: SingleChildScrollView(
        child: widget.isSimpleDialogue
            ? new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        left: 0.0, right: 0.0, top: 0.0, bottom: 5.0),
                    child: Text(
                      widget.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
                  ),
                  widget.buttonList != null
                      ? new SizedBox(
                          height: 30.0,
                        )
                      : new Container(),
                  widget.buttonList != null
                      ? new Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: widget.buttonList
                              .map((eachButton) => Padding(
                                    padding:
                                        EdgeInsets.only(left: 0.0, right: 0.0),
                                    child: new FlatButton(
                                      onPressed: () {
                                        eachButton.buttonAction();
                                      },
                                      child: new Padding(
                                        padding: new EdgeInsets.only(
                                            left: 0.0,
                                            right: 0.0,
                                            top: 0.0,
                                            bottom: 0.0),
                                        child: new Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            new Text(
                                              eachButton.actionName,
                                              style: new TextStyle(
                                                  fontSize: 17.0,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red),
                                              maxLines: 10,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        )
                      : new Container(),
                ],
              )
            : new Container(),
      ),
    );
  }
}
