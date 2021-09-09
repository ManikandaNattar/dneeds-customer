import 'dart:async';
import 'dart:convert';
import 'package:daily_needs/api_model_classes/promo_code_get.dart';
import 'package:daily_needs/api_model_classes/validate_promo.dart';
import 'package:daily_needs/login.dart';
import 'package:daily_needs/model/Change_pass_model.dart';
import 'package:daily_needs/model/query_model.dart';
import 'package:http/http.dart' as http;
import 'package:daily_needs/api_model_classes/check_mobile.dart';

//import 'dart:convert' as json;
import 'package:daily_needs/login_model.dart';
import 'package:daily_needs/getAllCategoryService.dart';
import 'package:daily_needs/getAllOrder_model.dart';
import 'package:daily_needs/signup_model.dart';
import 'package:daily_needs/api_model_classes/booking_user_service.dart';
import 'package:daily_needs/save_storage/save_storage.dart';
import 'package:daily_needs/api_model_classes/change_vendor.dart';
import 'model/Update_user_model.dart';
import 'model/User_detail_model.dart';
import 'model/faq_model.dart';
import 'package:daily_needs/api_model_classes/cancel_order.dart';
import 'package:daily_needs/forgot_password_model.dart';

String baseUrl = "https://dneeds.in/dailyneeds/";
//String baseUrl = "https://dneeds.in/dneeds/";

Map<String, String> header = {
  'Accept': 'application/json',
};

const String firebaseCloudserverToken =
    'AAAAoBIXX0g:APA91bGSOnemYYCHI6l0a7V34_vxw2RUHTr48ZAoYpQ4PVIXRgSKQD4muj55vrrGqNP_ccaZBPxpg08cj0h3-xiKtYWKvQG_kq9_QkZJdNU-5lgwiSfo8HFHdHf2CAJLa5HL_NUQIOm7';

Future<dynamic> loginDailyNeeds(
    {String email, String password, String login_flag}) async {
  if (checkIsNumeric(mobileNumber: email)) {
    var response = await http.post(Uri.encodeFull(baseUrl + "users/login"),
        body: {
          "mobile_no": email,
          "password": password,
          "login_flag": "mobile"
        },
        headers: header);
    print(response.statusCode);
    print("login called via mobile number");
    print(response.body);
    if (response.statusCode == 200) {
      //return json.jsonDecode(response.body);
      Map<String, dynamic> userMap = json.decode(response.body.toString());
      LoginModel result = LoginModel.fromJson(userMap);
      return result;
    } else
      return response?.reasonPhrase ?? "Unknown Error Occured";
  } else {
    var response = await http.post(Uri.encodeFull(baseUrl + "users/login"),
        body: {"email": email, "password": password, "login_flag": "email"},
        headers: header);
    print(response.statusCode);
    print("login called via email id");
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> userMap = json.decode(response.body.toString());
      LoginModel result = LoginModel.fromJson(userMap);
      return result;
    } else
      return response?.reasonPhrase ?? "Unknown Error Occured";
  }
}

bool checkIsNumeric({String mobileNumber}) {
  if (mobileNumber == null) {
    return false;
  }
  return double.tryParse(mobileNumber) != null;
}

Future<dynamic> forgotPassword(
    {String email, String newPassword, String flag}) async {
  if (checkIsNumeric(mobileNumber: email)) {
    var response = await http.post(
        Uri.encodeFull(baseUrl + "users/change_forgot_password"),
        body: {"mobile_no": email, "new_password": newPassword, "flag": flag},
        headers: header);
    print(response.statusCode);
    print("login called via mobile number");
    print(response.body);
    if (response.statusCode == 200) {
      //return json.jsonDecode(response.body);
      Map<String, dynamic> userMap = json.decode(response.body.toString());
      ForgotPasswordModel result = ForgotPasswordModel.fromJson(userMap);
      return result;
    } else
      return response?.reasonPhrase ?? "Unknown Error Occured";
  } else {
    var response = await http.post(
        Uri.encodeFull(baseUrl + "users/change_forgot_password"),
        body: {"email": email, "new_password": newPassword, "flag": flag},
        headers: header);
    print(response.statusCode);
    print("login called via email id");
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> userMap = json.decode(response.body.toString());
      ForgotPasswordModel result = ForgotPasswordModel.fromJson(userMap);
      return result;
    } else
      return response?.reasonPhrase ?? "Unknown Error Occured";
  }
}

Future<dynamic> signupDailyNeeds(
    {String usertype_id,
    String email,
    String password,
    String mobile_no,
    String first_name,
    String address,
    String address2,
    String city,
    String state,
    String zipcode,
    String is_social_user,
    String user_paid_type,
    String is_licence,
    String is_approved,
    String user_org_legal,
    String rating,
    String country_code,
    String social_media_id}) async {
  var response = await http.post(Uri.encodeFull(baseUrl + "users/user_sign_up"),
      body: {
        "usertype_id": usertype_id,
        "email": email,
        "password": password,
        "mobile_no": mobile_no,
        "first_name": first_name,
        "address": address,
        "address2": address2,
        "city": city,
        "state": state,
        "zipcode": zipcode,
        "is_social_user": is_social_user,
        "user_paid_type": user_paid_type,
        "is_licence": is_licence,
        "is_approved": is_approved,
        "user_org_legal": user_org_legal,
        "rating": rating,
        "country_code": country_code,
        "social_media_id": social_media_id.toString()
      },
      headers: header);
  print(response.statusCode);
  print("Signup Response==" + response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    SignUpModel result = SignUpModel.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getAllCategoryServices() async {
  var response = await http.post(
      Uri.encodeFull(baseUrl + "lk_services/get_all_categories_services"),
      body: {},
      headers: header);
  if (response.statusCode == 200) {
    Map serviceMap = json.decode(response.body.toString());
    GetAllCategoryServices categoryServices =
        GetAllCategoryServices.fromJson(serviceMap);
    return categoryServices;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getAllOrderWithTrackingById(
    {String userId, String token}) async {
  var response = await http
      .post(baseUrl + "services/get_all_orders_with_tracking", body: {
    "user_id": userId
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 401) {
    return response.statusCode;
  }
  if (response.statusCode == 200) {
    Map orderMap = json.decode(response.body.toString());
    GetAllOrder allOrder = GetAllOrder.fromJson(orderMap);
    return allOrder;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> bookUserService(
    {String userId,
    String serviceId,
    String service_type,
    String service_request_date,
    String issueDescription,
    String lattitude,
    String longitude,
    String address,
    String zipcode,
    String sub_ser_Id,
    String issueImgURL,
    String token}) async {
  var response = await http.post(baseUrl + "services/add_user_service", body: {
    "user_id": userId,
    "service_id": serviceId,
    "service_type": service_type ?? "issue",
    "service_request_date": service_request_date,
    "issue_description": issueDescription,
    "lat": lattitude,
    "long": longitude,
    "issue_image_url": issueImgURL ?? "",
    "address": address,
    "zipcode": zipcode,
    "sub_service_ids": sub_ser_Id
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 401) {
    return response.statusCode;
  }
  if (response.statusCode == 200) {
    Map orderedServiceMap = json.decode(response.body.toString());
    BookUserService bookUserService =
        BookUserService.fromJson(orderedServiceMap);
    return bookUserService;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> Userdetail(
    {String id,
    String usertype_id,
    String email,
    String mobileno,
    String first_name,
    String last_name,
    String address,
    String city,
    String state,
    String zipcode,
    String country}) async {
  var response =
      await http.post(Uri.encodeFull(baseUrl + "users/update_user_details"),
          body: {
            "id": id,
            "usertype_id": usertype_id,
            "email": email,
            "mobile_no": mobileno,
            "first_name": first_name,
            "last_name": last_name,
            "address": address,
            "city": city,
            "state": state,
            "zipcode": zipcode,
            "country": country,
          },
          headers: header);
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    UserDetail result = UserDetail.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> Password(
    {String email, String new_password, String password, String token}) async {
  var response = await http
      .post(Uri.encodeFull(baseUrl + "users/change_password"), body: {
    "email": email,
    "new_password": new_password,
    "password": password
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  if (response.statusCode == 401) {
    String lmail = await get_string_prefs("emailPref");
    String lpass = await get_string_prefs("passwordPref");
    String gmail = await get_string_prefs("passwordPref");
    String spass = await get_string_prefs("emailSignUpPref");
    String lM = lmail == "" ? null : lmail;
    String sM = gmail == "" ? null : gmail;
    String lP = lpass == "" ? null : lpass;
    String sP = spass == "" ? null : spass;
    String loginMail = lM ?? sM;
    String loginPassword = lP ?? sP;
    loginDailyNeeds(
            password: loginPassword, email: loginMail, login_flag: "email")
        .then((onResponse) {
      if (onResponse is LoginModel) {
        if (onResponse.data.message == "Login Successfully") {
          String loginDetails = json.encode(onResponse);
          Map getToken = json.decode(loginDetails);
          String newToken = getToken["data"]["access_token"];
          Password(
            email: email,
            new_password: newToken,
            password: password,
            token: newToken,
          );
        }
      }
    });
  }
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    ChangePass result = ChangePass.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getFaq({String token}) async {
  var response = await http.post(Uri.encodeFull(baseUrl + "admin/get_faq"),
      body: {},
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });
  if (response.statusCode == 401) {
    String lmail = await get_string_prefs("emailPref");
    String lpass = await get_string_prefs("passwordPref");
    String gmail = await get_string_prefs("passwordPref");
    String spass = await get_string_prefs("emailSignUpPref");
    String lM = lmail == "" ? null : lmail;
    String sM = gmail == "" ? null : gmail;
    String lP = lpass == "" ? null : lpass;
    String sP = spass == "" ? null : spass;
    String loginMail = lM ?? sM;
    String loginPassword = lP ?? sP;
    loginDailyNeeds(
            password: loginPassword, email: loginMail, login_flag: "email")
        .then((onResponse) {
      if (onResponse is LoginModel) {
        if (onResponse.data.message == "Login Successfully") {
          String loginDetails = json.encode(onResponse);
          Map getToken = json.decode(loginDetails);
          String newToken = getToken["data"]["access_token"];
          getFaq(
            token: newToken,
          );
        }
      }
    });
  }

  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    FAQModel result = FAQModel.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getQuery({String user_id, String query, String token}) async {
  var response = await http.post(Uri.encodeFull(baseUrl + "users/add_query"),
      body: {
        "user_id": user_id,
        "query": query
      },
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      });
  if (response.statusCode == 401) {
    String lmail = await get_string_prefs("emailPref");
    String lpass = await get_string_prefs("passwordPref");
    String gmail = await get_string_prefs("passwordPref");
    String spass = await get_string_prefs("emailSignUpPref");
    String lM = lmail == "" ? null : lmail;
    String sM = gmail == "" ? null : gmail;
    String lP = lpass == "" ? null : lpass;
    String sP = spass == "" ? null : spass;
    String loginMail = lM ?? sM;
    String loginPassword = lP ?? sP;
    loginDailyNeeds(
            password: loginPassword, email: loginMail, login_flag: "email")
        .then((onResponse) {
      if (onResponse is LoginModel) {
        if (onResponse.data.message == "Login Successfully") {
          String loginDetails = json.encode(onResponse);
          Map getToken = json.decode(loginDetails);
          String newToken = getToken["data"]["access_token"];
          getQuery(
            user_id: user_id,
            query: query,
            token: newToken,
          );
        }
      }
    });
  }

  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    Query result = Query.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<void> sendNotificationMessageToPeerUser(
    unReadMSGCount,
    messageType,
    textFromTextField,
    myName,
    chatID,
    peerUserToken,
    groupChat,
    chatPersonTypesss,
    chatPersonIddd,
    currentDeviceToken,
    allDeviceTokens) async {
  print("send notification is called");
  await http.post(
    'https://fcm.googleapis.com/fcm/send',
    headers: <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$firebaseCloudserverToken',
    },
    body: jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{
          'body': messageType == "text" ? textFromTextField : '',
          'title': '$myName',
          'badge': '$unReadMSGCount', //'$unReadMSGCount'
          "sound": "ring.mp3"
        },
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': groupChat ?? '1',
          'status': 'done',
          'chatroomid': chatID,
          'chatPersonTypes': chatPersonTypesss,
          'chatPersonID': chatPersonIddd,
          'allTokens': allDeviceTokens,
          'personName': myName,
          'current_Token': currentDeviceToken
        },
        'to': peerUserToken,
      },
    ),
  );
  print("notification send to that phone");
  final Completer<Map<String, dynamic>> completer =
      Completer<Map<String, dynamic>>();
}

Future<dynamic> pushNotification(
    {String user_id, String device_token, String imei_no, String token}) async {
  var response = await http
      .post(Uri.encodeFull(baseUrl + "push/add_deviceid_android"), body: {
    "user_id": user_id,
    "device_token": device_token,
    "imei_no": imei_no
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print("notification response notification response notification response");
  print(response.statusCode);
  print(response.body);
}

Future<dynamic> changeVendor({String orderID, String token}) async {
  var response = await http.post(baseUrl + "services/change_vendor", body: {
    "order_id": orderID
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 401) {
    return response.statusCode;
  }
  if (response.statusCode == 200) {
    Map changeVendorMap = json.decode(response.body.toString());
    ChangeVendor changeVendor = ChangeVendor.fromJson(changeVendorMap);
    return changeVendor;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getUserDetailsbyID({String user_id, String token}) async {
  var response = await http
      .post(Uri.encodeFull(baseUrl + "users/get_user_details_by_id"), body: {
    "user_id": user_id,
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print(response.statusCode);
  if (response.statusCode == 401) {
    return response.statusCode;
  }
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body);
    GetDetailModel result = GetDetailModel.fromJson(userMap);
    return result;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> fbCheck(String gid) async {
  var url = baseUrl + "users/login";
  var response = await http.post(Uri.encodeFull(url),
      body: {
        "is_social_media": "1",
        "social_media_id": gid,
        "login_flag": "social"
      },
      headers: header);
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body.toString());
    LoginModel result = LoginModel.fromJson(userMap);
    return result;
  } else {
    Map userMap = json.decode(response.body.toString());
    LoginModel result = LoginModel.fromJson(userMap);
    return result;
  }
}

Future<dynamic> googleCall(String gid) async {
  var url = baseUrl + "users/login";
  var response = await http.post(Uri.encodeFull(url),
      body: {
        "is_social_media": "1",
        "social_media_id": gid,
        "login_flag": "social"
      },
      headers: header);
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map userMap = json.decode(response.body.toString());
    LoginModel result = LoginModel.fromJson(userMap);
    return result;
  } else {
    Map userMap = json.decode(response.body.toString());
    LoginModel result = LoginModel.fromJson(userMap);
    return result;
  }
}

Future<dynamic> cancelOrder({String orderUniqueID, String token}) async {
  var response = await http
      .post(Uri.encodeFull(baseUrl + "services/cancel_order"), body: {
    "order_id": orderUniqueID
  }, headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token'
  });
  print(response.statusCode);
  if (response.statusCode == 401) {
    return response.statusCode;
  }
  print(response.body);
  if (response.statusCode == 200) {
    Map cancelMap = json.decode(response.body.toString());
    CancelOrderModel cancelOrderModel = CancelOrderModel.fromJson(cancelMap);
    return cancelOrderModel;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> checkMobileNumber({String mobileNumber}) async {
  var response = await http.post(
      Uri.encodeFull(baseUrl + "users/check_mobile_no"),
      body: {"mobile_no": mobileNumber},
      headers: header);
  print(response.statusCode);
  print(response.body);
  if (response.statusCode == 200) {
    Map checkMobileMap = json.decode(response.body.toString());
    Check_MobileNumber check_mobileNumber =
        Check_MobileNumber.fromJson(checkMobileMap);
    return check_mobileNumber;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> getAllPromoCodes({String cat_id, String user_id}) async {
  var response = await http.post(
      Uri.encodeFull(baseUrl + "services/get_all_promo_codes_by_userid"),
      body: {"user_id": user_id, "cat_id": cat_id},
      headers: header);
  print("promo status code=" + response.statusCode.toString());
  if (response.statusCode == 200) {
    print("getallpromocode==" + response.body);
    Map promoMap = json.decode(response.body);
    GetPromoCode getPromoCode = GetPromoCode.fromJson(promoMap);
    return getPromoCode;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}

Future<dynamic> validatePromoCodeByUserId(
    {String promo_code, String cat_id}) async {
  var response = await http.post(
      Uri.encodeFull(baseUrl + "services/validate_promocode_by_userid"),
      body: {"promo_code": promo_code, "cat_id": cat_id},
      headers: header);
  print("promo status code=" + response.statusCode.toString());
  if (response.statusCode == 200) {
    print("validatePromovode==" + response.body);
    Map val_promo = json.decode(response.body);
    ValidPromo _validPromo = ValidPromo.fromJson(val_promo);
    return _validPromo;
  } else
    return response?.reasonPhrase ?? "Unknown Error Occured";
}
