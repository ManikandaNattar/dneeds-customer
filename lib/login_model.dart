class LoginModel {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  LoginModel({this.statusCode, this.status, this.serviceName, this.data});

  LoginModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['status_code'];
    status = json['status'];
    serviceName = json['service_name'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status_code'] = this.statusCode;
    data['status'] = this.status;
    data['service_name'] = this.serviceName;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class Data {
  List<User> user;
  String accessToken;
  String message;

  Data({this.user, this.accessToken, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['user'] != null) {
      user = new List<User>();
      json['user'].forEach((v) {
        user.add(new User.fromJson(v));
      });
    }
    accessToken = json['access_token'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user.map((v) => v.toJson()).toList();
    }
    data['access_token'] = this.accessToken;
    data['message'] = this.message;
    return data;
  }
}

class User {
  String id;
  String usertypeId;
  String email;
  String mobileNo;
  String firstName;
  String lastName;
  String address;
  String address2;
  Null areaName;
  String city;
  String state;
  String country;
  String zipcode;
  String userProfileUrl;
  String companyName;
  String website;
  String description;
  String latitude;
  String longitude;
  String parentCompany;
  String companyImg;
  String rating;

  User(
      {this.id,
      this.usertypeId,
      this.email,
      this.mobileNo,
      this.firstName,
      this.lastName,
      this.address,
      this.address2,
      this.areaName,
      this.city,
      this.state,
      this.country,
      this.zipcode,
      this.userProfileUrl,
      this.companyName,
      this.website,
      this.description,
      this.latitude,
      this.longitude,
      this.parentCompany,
      this.companyImg,
      this.rating});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    usertypeId = json['usertype_id'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    address2 = json['address2'];
    areaName = json['area_name'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    zipcode = json['zipcode'];
    userProfileUrl = json['user_profile_url'];
    companyName = json['company_name'];
    website = json['website'];
    description = json['description'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    parentCompany = json['parent_company'];
    companyImg = json['company_img'];
    rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['usertype_id'] = this.usertypeId;
    data['email'] = this.email;
    data['mobile_no'] = this.mobileNo;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address'] = this.address;
    data['address2'] = this.address2;
    data['area_name'] = this.areaName;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['zipcode'] = this.zipcode;
    data['user_profile_url'] = this.userProfileUrl;
    data['company_name'] = this.companyName;
    data['website'] = this.website;
    data['description'] = this.description;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['parent_company'] = this.parentCompany;
    data['company_img'] = this.companyImg;
    data['rating'] = this.rating;
    return data;
  }
}
