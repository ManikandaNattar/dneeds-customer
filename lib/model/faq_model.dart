class FAQModel {
  String statusCode;
  String status;
  String serviceName;
  Data data;
  String token;
  List<FAQModel> faqs;

  FAQModel(
      {this.statusCode,
      this.status,
      this.serviceName,
      this.data,
      this.token,
      List faqs});

  FAQModel.fromJson(Map<String, dynamic> json) {
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
  List<FAQ> fAQ;
  String message;

  Data({this.fAQ, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['FAQ'] != null) {
      fAQ = new List<FAQ>();
      json['FAQ'].forEach((v) {
        fAQ.add(new FAQ.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fAQ != null) {
      data['FAQ'] = this.fAQ.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class FAQ {
  String faqId;
  String faqQue;
  String faqAns;
  String category;
  String createdDatetime;
  String modifiedDatetime;

  FAQ(
      {this.faqId,
      this.faqQue,
      this.faqAns,
      this.category,
      this.createdDatetime,
      this.modifiedDatetime});

  FAQ.fromJson(Map<String, dynamic> json) {
    faqId = json['faq_id'];
    faqQue = json['faq_que'];
    faqAns = json['faq_ans'];
    category = json['category'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['faq_id'] = this.faqId;
    data['faq_que'] = this.faqQue;
    data['faq_ans'] = this.faqAns;
    data['category'] = this.category;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    return data;
  }
}
