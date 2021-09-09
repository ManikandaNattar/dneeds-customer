class GetPromoCode {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  GetPromoCode({this.statusCode, this.status, this.serviceName, this.data});

  GetPromoCode.fromJson(Map<String, dynamic> json) {
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
  List<PromoCode> promoCode;
  String message;

  Data({this.promoCode, this.message});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['promo_code'] != null) {
      promoCode = new List<PromoCode>();
      json['promo_code'].forEach((v) {
        promoCode.add(new PromoCode.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.promoCode != null) {
      data['promo_code'] = this.promoCode.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class PromoCode {
  String promoCode;
  double discPer;

  PromoCode({this.promoCode, this.discPer});

  PromoCode.fromJson(Map<String, dynamic> json) {
    promoCode = json['promo_code'];
    discPer = double.parse(json['disc_per']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['promo_code'] = this.promoCode;
    data['disc_per'] = this.discPer;
    return data;
  }
}
