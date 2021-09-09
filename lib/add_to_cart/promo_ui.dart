import 'package:daily_needs/api_model_classes/promo_code_get.dart';
import 'package:daily_needs/api_model_classes/validate_promo.dart';
import 'package:daily_needs/reusuable_widgets/common_loader.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:daily_needs/colors.dart';
import 'package:daily_needs/api.dart';
import 'package:toast/toast.dart';

class PromoScreen extends StatefulWidget {
  @override
  PromoScreenState createState() => PromoScreenState();
}

class PromoScreenState extends State<PromoScreen> {
  GetPromoCode getPromoCode;
  ValidPromo _validPromoModel;
  List<PromoCode> allPromoCodes;
  String errorText = "Please Wait";
  TextEditingController promoController = new TextEditingController();
  bool _promoFieldValidate = false;

  @override
  void initState() {
    super.initState();
    allPromoCodes = new List();
    getPromos();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryRedColor,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: Text("Promo Code"),
      ),
      body: allPromoCodes.length == 0
          ? new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(errorText),
                )
              ],
            )
          : new SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: new Padding(
                padding: EdgeInsets.only(left: 0.0, right: 0.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new SizedBox(
                      height: 20.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextField(
                              controller: promoController,
                              decoration: InputDecoration(
                                hintText: "Enter Promo Code",
                                errorText: _promoFieldValidate
                                    ? "Enter PromoCode"
                                    : null,
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey)),
                              ),
                            ),
                          ),
                          MaterialButton(
                            minWidth: MediaQuery.of(context).size.width * 0.2,
                            color: Colors.green,
                            child: new Text(
                              "Apply",
                              style: TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              if (!promoController.text.isEmpty) {
                                verifyPromoCode(pro_code: promoController.text);
                              } else if (promoController.text.isEmpty) {
                                setState(() {
                                  _promoFieldValidate = true;
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    new SizedBox(
                      height: 20.0,
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: allPromoCodes
                          .asMap()
                          .map((index, eachPromo) => MapEntry(
                              index,
                              new Container(
                                color: Colors.white,
                                padding:
                                    EdgeInsets.only(top: 20.0, bottom: 0.0),
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    InkWell(
                                      child: new Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5.0),
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  "DNeeds",
                                                  style: TextStyle(
                                                      color: primaryRedColor,
                                                      fontSize: 16.0),
                                                ),
                                                new SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text("Promo Code: " +
                                                    eachPromo.promoCode),
                                                new SizedBox(
                                                  height: 5.0,
                                                ),
                                                Text("Get " +
                                                    (eachPromo.discPer)
                                                        .toString() +
                                                    "% OFF"),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0, right: 5.0),
                                            child: new Text(
                                              "Apply",
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .pop(eachPromo.discPer);
                                      },
                                    ),
                                    Divider()
                                  ],
                                ),
                              )))
                          .values
                          .toList(),
                    )
                  ],
                ),
              ),
            ),
    );
  }

  void getPromos() async {
    String iddd = await get_string_prefs("categoryId");
    String signUpUser = await get_string_prefs("signupuser");
    String loginUser = await get_string_prefs("loginuser");
    String logId = await get_string_prefs("loginuserId");
    String signId = await get_string_prefs("signUpUesrId");
    String loginId = logId == "" ? null : logId;
    String signupId = signId == "" ? null : signId;
    getAllPromoCodes(user_id: loginId ?? signupId, cat_id: iddd).then((value) {
      if (value is GetPromoCode) {
        if (value.statusCode == "200") {
          setState(() {
            getPromoCode = value;
            allPromoCodes = getPromoCode.data.promoCode;
          });
        } else {
          setState(() {
            errorText = value.data.message;
          });
        }
      }
    });
  }

  Future<void> verifyPromoCode({String pro_code}) async {
    String iddd = await get_string_prefs("categoryId");
    double discountPrice = 0.0;
    String checkpromo = "";
    validatePromoCodeByUserId(cat_id: iddd, promo_code: pro_code)
        .then((onResponse) {
      String strResponse = onResponse.toString();

      if (onResponse is ValidPromo) {
        setState(() {
          _validPromoModel = onResponse;
        });
        if (_validPromoModel.statusCode == "200") {
          for (int i = 0; i < allPromoCodes.length; i++) {
            if (pro_code == allPromoCodes[i].promoCode) {
              discountPrice = allPromoCodes[i].discPer;
              checkpromo = allPromoCodes[i].promoCode;
            }
          }
          if (pro_code == checkpromo) {
            Navigator.of(context).pop(discountPrice);
          }
        } else {
          Toast.show(_validPromoModel.data.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      }
    });
  }
}
