class Query {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  Query({this.statusCode, this.status, this.serviceName, this.data});

  Query.fromJson(Map<String, dynamic> json) {
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
  Input input;
  String message;

  Data({this.input, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    input = json['input'] != null ? new Input.fromJson(json['input']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.input != null) {
      data['input'] = this.input.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Input {
  String userId;
  String query;

  Input({this.userId, this.query});

  Input.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    query = json['query'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_id'] = this.userId;
    data['query'] = this.query;
    return data;
  }
}
