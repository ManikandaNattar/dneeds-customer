class UserDetail {
  String statusCode;
  String status;
  String serviceName;
  Data data;
  String token;

  UserDetail({
    this.statusCode,
    this.status,
    this.serviceName,
    this.data,
    this.token,
  });

  UserDetail.fromJson(Map<String, dynamic> json) {
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
  UpdatedDetails updatedDetails;
  String message;

  Data({this.updatedDetails, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    updatedDetails = json['updated_details'] != null
        ? new UpdatedDetails.fromJson(json['updated_details'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.updatedDetails != null) {
      data['updated_details'] = this.updatedDetails.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class UpdatedDetails {
  String id;
  String usertypeId;
  String email;
  String mobileNo;
  String firstName;
  String lastName;
  String address;
  String city;
  String state;
  String zipcode;
  String country;
  String authCode;
  String isSocialUser;
  String socialMediaId;
  String userPaidType;
  String userProfileUrl;
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
  String kidsDetails;

  UpdatedDetails(
      {this.id,
      this.usertypeId,
      this.email,
      this.mobileNo,
      this.firstName,
      this.lastName,
      this.address,
      this.city,
      this.state,
      this.zipcode,
      this.country,
      this.authCode,
      this.isSocialUser,
      this.socialMediaId,
      this.userPaidType,
      this.userProfileUrl,
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
      this.kidsDetails});

  UpdatedDetails.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    usertypeId = json['usertype_id'];
    email = json['email'];
    mobileNo = json['mobile_no'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    country = json['country'];
    authCode = json['auth_code'];
    isSocialUser = json['is_social_user'];
    socialMediaId = json['social_media_id'];
    userPaidType = json['user_paid_type'];
    userProfileUrl = json['user_profile_url'];
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
    kidsDetails = json['kids_details'];
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
    data['city'] = this.city;
    data['state'] = this.state;
    data['zipcode'] = this.zipcode;
    data['country'] = this.country;
    data['auth_code'] = this.authCode;
    data['is_social_user'] = this.isSocialUser;
    data['social_media_id'] = this.socialMediaId;
    data['user_paid_type'] = this.userPaidType;
    data['user_profile_url'] = this.userProfileUrl;
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
    data['kids_details'] = this.kidsDetails;
    return data;
  }
}
