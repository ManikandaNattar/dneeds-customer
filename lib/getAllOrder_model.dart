class GetAllOrder {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  GetAllOrder({this.statusCode, this.status, this.serviceName, this.data});

  GetAllOrder.fromJson(Map<String, dynamic> json) {
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
  List<Orders> orders;
  String message;

  Data({this.orders, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Orders {
  String id;
  String userId;
  String serviceId;
  String subServiceIds;
  String serviceType;
  String serviceRequestDate;
  String issueDescription;
  String bookingStatus;
  String lat;
  String long;
  String issueImageUrl;
  String zipcode;
  String address;
  String createdDatetime;
  String modifiedDatetime;
  String orderId;
  String vendorId;
  String isVendorAccepted;
  String isOrderCompleted;
  String chatRoomId;
  String vendorMobile;
  List<SubServices> subServices;
  String orderNo;
  Orders({
    this.id,
    this.userId,
    this.serviceId,
    this.subServiceIds,
    this.serviceType,
    this.serviceRequestDate,
    this.issueDescription,
    this.bookingStatus,
    this.lat,
    this.long,
    this.issueImageUrl,
    this.zipcode,
    this.address,
    this.createdDatetime,
    this.modifiedDatetime,
    this.orderId,
    this.vendorId,
    this.isVendorAccepted,
    this.isOrderCompleted,
    this.chatRoomId,
    this.vendorMobile,
    this.subServices,
    this.orderNo,
  });

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    serviceId = json['service_id'];
    subServiceIds = json['sub_service_ids'];
    serviceType = json['service_type'];
    serviceRequestDate = json['service_request_date'];
    issueDescription = json['issue_description'];
    bookingStatus = json['booking_status'];
    lat = json['lat'];
    long = json['long'];
    issueImageUrl = json['issue_image_url'];
    zipcode = json['zipcode'];
    address = json['address'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
    orderId = json['order_id'];
    vendorId = json['vendor_id'];
    isVendorAccepted = json['is_vendor_accepted'];
    isOrderCompleted = json['is_order_completed'];
    chatRoomId = json['chat_room_id'];
    vendorMobile = json['vendor_mobile'];
    orderNo = json['order_no'];
    if (json['sub_services'] != null) {
      subServices = new List<SubServices>();
      json['sub_services'].forEach((v) {
        subServices.add(new SubServices.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['service_id'] = this.serviceId;
    data['sub_service_ids'] = this.subServiceIds;
    data['service_type'] = this.serviceType;
    data['service_request_date'] = this.serviceRequestDate;
    data['issue_description'] = this.issueDescription;
    data['booking_status'] = this.bookingStatus;
    data['lat'] = this.lat;
    data['long'] = this.long;
    data['issue_image_url'] = this.issueImageUrl;
    data['zipcode'] = this.zipcode;
    data['address'] = this.address;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    data['order_id'] = this.orderId;
    data['vendor_id'] = this.vendorId;
    data['is_vendor_accepted'] = this.isVendorAccepted;
    data['is_order_completed'] = this.isOrderCompleted;
    data['chat_room_id'] = this.chatRoomId;
    data['vendor_mobile'] = this.vendorMobile;
    data['order_no'] = orderNo;
    if (this.subServices != null) {
      data['sub_services'] = this.subServices.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubServices {
  String service;
  String subService;
  String price;

  SubServices({this.service, this.subService, this.price});

  SubServices.fromJson(Map<String, dynamic> json) {
    service = json['service'];
    subService = json['sub_service'];
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['service'] = this.service;
    data['sub_service'] = this.subService;
    data['price'] = this.price;
    return data;
  }
}
