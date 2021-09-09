class ChangeVendor {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  ChangeVendor({this.statusCode, this.status, this.serviceName, this.data});

  ChangeVendor.fromJson(Map<String, dynamic> json) {
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
  String orderId;
  ClosestVendor closestVendor;
  String chatRoom;
  Input input;
  String message;

  Data(
      {this.orderId,
      this.closestVendor,
      this.chatRoom,
      this.input,
      this.message});

  Data.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    closestVendor = json['closest_vendor'] != null
        ? new ClosestVendor.fromJson(json['closest_vendor'])
        : null;
    chatRoom = json['chat_room'];
    input = json['input'] != null ? new Input.fromJson(json['input']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    if (this.closestVendor != null) {
      data['closest_vendor'] = this.closestVendor.toJson();
    }
    data['chat_room'] = this.chatRoom;
    if (this.input != null) {
      data['input'] = this.input.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class ClosestVendor {
  String id;
  String firstName;
  String lastName;
  String address;
  String address2;
  String latitude;
  String longitude;
  String mobileNo;

  ClosestVendor(
      {this.id,
      this.firstName,
      this.lastName,
      this.address,
      this.address2,
      this.latitude,
      this.longitude,
      this.mobileNo});

  ClosestVendor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    address2 = json['address2'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    mobileNo = json['mobile_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address'] = this.address;
    data['address2'] = this.address2;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['mobile_no'] = this.mobileNo;
    return data;
  }
}

class Input {
  String orderId;

  Input({this.orderId});

  Input.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    return data;
  }
}
