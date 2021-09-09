class SignUpModel {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  SignUpModel({this.statusCode, this.status, this.serviceName, this.data});

  SignUpModel.fromJson(Map<String, dynamic> json) {
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
  int id;
  List<UserDetails> userDetails;
  String accessToken;
  String message;

  Data({this.id, this.userDetails, this.accessToken, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['user_details'] != null) {
      userDetails = new List<UserDetails>();
      json['user_details'].forEach((v) {
        userDetails.add(new UserDetails.fromJson(v));
      });
    }
    accessToken = json['access_token'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.userDetails != null) {
      data['user_details'] = this.userDetails.map((v) => v.toJson()).toList();
    }
    data['access_token'] = this.accessToken;
    data['message'] = this.message;
    return data;
  }
}

class UserDetails {
  String id;
  String usertypeId;
  Null username;
  String password;
  String email;
  String countryCode;
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
  String authCode;
  String isSocialUser;
  String socialMediaId;
  String userPaidType;
  String userProfileUrl;
  String companyName;
  String website;
  String description;
  String isLicence;
  String licenceNo;
  String latitude;
  String longitude;
  String isApproved;
  String userOrgType;
  String userOrgLegal;
  String parentCompany;
  String companyImg;
  String rating;
  Null serviceId;
  String latlngCheck;
  String createdDatetime;
  String modifiedDatetime;

  UserDetails(
      {this.id,
      this.usertypeId,
      this.username,
      this.password,
      this.email,
      this.countryCode,
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
      this.authCode,
      this.isSocialUser,
      this.socialMediaId,
      this.userPaidType,
      this.userProfileUrl,
      this.companyName,
      this.website,
      this.description,
      this.isLicence,
      this.licenceNo,
      this.latitude,
      this.longitude,
      this.isApproved,
      this.userOrgType,
      this.userOrgLegal,
      this.parentCompany,
      this.companyImg,
      this.rating,
      this.serviceId,
      this.latlngCheck,
      this.createdDatetime,
      this.modifiedDatetime});

  UserDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    usertypeId = json['usertype_id'];
    username = json['username'];
    password = json['password'];
    email = json['email'];
    countryCode = json['country_code'];
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
    authCode = json['auth_code'];
    isSocialUser = json['is_social_user'];
    socialMediaId = json['social_media_id'];
    userPaidType = json['user_paid_type'];
    userProfileUrl = json['user_profile_url'];
    companyName = json['company_name'];
    website = json['website'];
    description = json['description'];
    isLicence = json['is_licence'];
    licenceNo = json['licence_no'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isApproved = json['is_approved'];
    userOrgType = json['user_org_type'];
    userOrgLegal = json['user_org_legal'];
    parentCompany = json['parent_company'];
    companyImg = json['company_img'];
    rating = json['rating'];
    serviceId = json['service_id'];
    latlngCheck = json['latlng_check'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['usertype_id'] = this.usertypeId;
    data['username'] = this.username;
    data['password'] = this.password;
    data['email'] = this.email;
    data['country_code'] = this.countryCode;
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
    data['auth_code'] = this.authCode;
    data['is_social_user'] = this.isSocialUser;
    data['social_media_id'] = this.socialMediaId;
    data['user_paid_type'] = this.userPaidType;
    data['user_profile_url'] = this.userProfileUrl;
    data['company_name'] = this.companyName;
    data['website'] = this.website;
    data['description'] = this.description;
    data['is_licence'] = this.isLicence;
    data['licence_no'] = this.licenceNo;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['is_approved'] = this.isApproved;
    data['user_org_type'] = this.userOrgType;
    data['user_org_legal'] = this.userOrgLegal;
    data['parent_company'] = this.parentCompany;
    data['company_img'] = this.companyImg;
    data['rating'] = this.rating;
    data['service_id'] = this.serviceId;
    data['latlng_check'] = this.latlngCheck;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    return data;
  }
}
