class GetAllCategoryServices {
  String statusCode;
  String status;
  String serviceName;
  Data data;

  GetAllCategoryServices(
      {this.statusCode, this.status, this.serviceName, this.data});

  GetAllCategoryServices.fromJson(Map<String, dynamic> json) {
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
  List<Categories> categories;
  List<Subcategories> subcategories;
  List<Services> services;
  List<SubServices> subServices;
  List<AreaPincodes> areaPincodes;
  List<Cities> cities;
  List<States> states;
  List<HomeBanners> homeBanners;
  List<HomeLogoTexts> homeLogoTexts;
  List<HomePartners> homePartners;
  List<Testimonials> testimonials;
  String message;

  Data(
      {this.categories,
      this.subcategories,
      this.services,
      this.subServices,
      this.areaPincodes,
      this.cities,
      this.states,
      this.homeBanners,
      this.homeLogoTexts,
      this.homePartners,
      this.testimonials,
      this.message});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = new List<Categories>();
      json['categories'].forEach((v) {
        categories.add(new Categories.fromJson(v));
      });
    }
    if (json['subcategories'] != null) {
      subcategories = new List<Subcategories>();
      json['subcategories'].forEach((v) {
        subcategories.add(new Subcategories.fromJson(v));
      });
    }
    if (json['services'] != null) {
      services = new List<Services>();
      json['services'].forEach((v) {
        services.add(new Services.fromJson(v));
      });
    }
    if (json['sub_services'] != null) {
      subServices = new List<SubServices>();
      json['sub_services'].forEach((v) {
        subServices.add(new SubServices.fromJson(v));
      });
    }
    if (json['area_pincodes'] != null) {
      areaPincodes = new List<AreaPincodes>();
      json['area_pincodes'].forEach((v) {
        areaPincodes.add(new AreaPincodes.fromJson(v));
      });
    }
    if (json['cities'] != null) {
      cities = new List<Cities>();
      json['cities'].forEach((v) {
        cities.add(new Cities.fromJson(v));
      });
    }
    if (json['states'] != null) {
      states = new List<States>();
      json['states'].forEach((v) {
        states.add(new States.fromJson(v));
      });
    }
    if (json['home_banners'] != null) {
      homeBanners = new List<HomeBanners>();
      json['home_banners'].forEach((v) {
        homeBanners.add(new HomeBanners.fromJson(v));
      });
    }
    if (json['home_logo_texts'] != null) {
      homeLogoTexts = new List<HomeLogoTexts>();
      json['home_logo_texts'].forEach((v) {
        homeLogoTexts.add(new HomeLogoTexts.fromJson(v));
      });
    }
    if (json['home_partners'] != null) {
      homePartners = new List<HomePartners>();
      json['home_partners'].forEach((v) {
        homePartners.add(new HomePartners.fromJson(v));
      });
    }
    if (json['testimonials'] != null) {
      testimonials = new List<Testimonials>();
      json['testimonials'].forEach((v) {
        testimonials.add(new Testimonials.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    if (this.subcategories != null) {
      data['subcategories'] =
          this.subcategories.map((v) => v.toJson()).toList();
    }
    if (this.services != null) {
      data['services'] = this.services.map((v) => v.toJson()).toList();
    }
    if (this.subServices != null) {
      data['sub_services'] = this.subServices.map((v) => v.toJson()).toList();
    }
    if (this.areaPincodes != null) {
      data['area_pincodes'] = this.areaPincodes.map((v) => v.toJson()).toList();
    }
    if (this.cities != null) {
      data['cities'] = this.cities.map((v) => v.toJson()).toList();
    }
    if (this.states != null) {
      data['states'] = this.states.map((v) => v.toJson()).toList();
    }
    if (this.homeBanners != null) {
      data['home_banners'] = this.homeBanners.map((v) => v.toJson()).toList();
    }
    if (this.homeLogoTexts != null) {
      data['home_logo_texts'] =
          this.homeLogoTexts.map((v) => v.toJson()).toList();
    }
    if (this.homePartners != null) {
      data['home_partners'] = this.homePartners.map((v) => v.toJson()).toList();
    }
    if (this.testimonials != null) {
      data['testimonials'] = this.testimonials.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class Categories {
  String id;
  String category;
  String displayOrder;
  String iconImage;
  String createdDatetime;
  String modifiedDatetime;

  Categories(
      {this.id,
      this.category,
      this.displayOrder,
      this.iconImage,
      this.createdDatetime,
      this.modifiedDatetime});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['category'];
    displayOrder = json['display_order'];
    iconImage = json['icon_image'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['category'] = this.category;
    data['display_order'] = this.displayOrder;
    data['icon_image'] = this.iconImage;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    return data;
  }
}

class Subcategories {
  String id;
  String subCategory;
  String catId;
  String displayOrder;
  String iconClassName;
  String iconImage;
  String createdDatetime;
  String modifiedDatetime;

  Subcategories(
      {this.id,
      this.subCategory,
      this.catId,
      this.displayOrder,
      this.iconClassName,
      this.iconImage,
      this.createdDatetime,
      this.modifiedDatetime});

  Subcategories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subCategory = json['sub_category'];
    catId = json['cat_id'];
    displayOrder = json['display_order'];
    iconClassName = json['icon_class_name'];
    iconImage = json['icon_image'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sub_category'] = this.subCategory;
    data['cat_id'] = this.catId;
    data['display_order'] = this.displayOrder;
    data['icon_class_name'] = this.iconClassName;
    data['icon_image'] = this.iconImage;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    return data;
  }
}

class Services {
  String id;
  String service;
  String catId;
  String subCatId;
  String price;
  String allowMultiService;
  String iconImage;
  String createdDatetime;
  String modifiedDatetime;

  Services(
      {this.id,
      this.service,
      this.catId,
      this.subCatId,
      this.price,
      this.allowMultiService,
      this.iconImage,
      this.createdDatetime,
      this.modifiedDatetime});

  Services.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    service = json['service'];
    catId = json['cat_id'];
    subCatId = json['sub_cat_id'];
    price = json['price'];
    allowMultiService = json['allow_multi_service'];
    iconImage = json['icon_image'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service'] = this.service;
    data['cat_id'] = this.catId;
    data['sub_cat_id'] = this.subCatId;
    data['price'] = this.price;
    data['allow_multi_service'] = this.allowMultiService;
    data['icon_image'] = this.iconImage;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    return data;
  }
}

class SubServices {
  String id;
  String serviceId;
  String subService;
  String price;
  String description;
  String points;
  String createdDatetime;
  String modifiedDatetime;
  List<SubServiceImages> subServiceImages;

  SubServices(
      {this.id,
      this.serviceId,
      this.subService,
      this.price,
      this.description,
      this.points,
      this.createdDatetime,
      this.modifiedDatetime,
      this.subServiceImages});

  SubServices.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    serviceId = json['service_id'];
    subService = json['sub_service'];
    price = json['price'];
    description = json['description'];
    points = json['points'];
    createdDatetime = json['created_datetime'];
    modifiedDatetime = json['modified_datetime'];
    if (json['sub_service_images'] != null) {
      subServiceImages = new List<SubServiceImages>();
      json['sub_service_images'].forEach((v) {
        subServiceImages.add(new SubServiceImages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['service_id'] = this.serviceId;
    data['sub_service'] = this.subService;
    data['price'] = this.price;
    data['description'] = this.description;
    data['points'] = this.points;
    data['created_datetime'] = this.createdDatetime;
    data['modified_datetime'] = this.modifiedDatetime;
    if (this.subServiceImages != null) {
      data['sub_service_images'] =
          this.subServiceImages.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SubServiceImages {
  String imageUrl;

  SubServiceImages({this.imageUrl});

  SubServiceImages.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image_url'] = this.imageUrl;
    return data;
  }
}

class AreaPincodes {
  String area;
  String pincode;

  AreaPincodes({this.area, this.pincode});

  AreaPincodes.fromJson(Map<String, dynamic> json) {
    area = json['area'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['area'] = this.area;
    data['pincode'] = this.pincode;
    return data;
  }
}

class Cities {
  String city;

  Cities({this.city});

  Cities.fromJson(Map<String, dynamic> json) {
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['city'] = this.city;
    return data;
  }
}

class States {
  String state;

  States({this.state});

  States.fromJson(Map<String, dynamic> json) {
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['state'] = this.state;
    return data;
  }
}

class HomeBanners {
  String imageUrl;
  String displayOrder;

  HomeBanners({this.imageUrl, this.displayOrder});

  HomeBanners.fromJson(Map<String, dynamic> json) {
    imageUrl = json['image_url'];
    displayOrder = json['display_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['image_url'] = this.imageUrl;
    data['display_order'] = this.displayOrder;
    return data;
  }
}

class HomePartners {
  String image_url;
  String display_order;

  HomePartners({
    this.image_url,
    this.display_order,
  });

  HomePartners.fromJson(Map<String, dynamic> json) {
    image_url = json['image_url'];
    display_order = json['display_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['display_order'] = this.display_order;
    data['image_url'] = this.image_url;
    return data;
  }
}

class HomeLogoTexts {
  String logoUrl;
  String visionText;
  String missionText;
  String valueText;

  HomeLogoTexts(
      {this.logoUrl, this.visionText, this.missionText, this.valueText});

  HomeLogoTexts.fromJson(Map<String, dynamic> json) {
    logoUrl = json['logo_url'];
    visionText = json['vision_text'];
    missionText = json['mission_text'];
    valueText = json['value_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logo_url'] = this.logoUrl;
    data['vision_text'] = this.visionText;
    data['mission_text'] = this.missionText;
    data['value_text'] = this.valueText;
    return data;
  }
}

class Testimonials {
  String name;
  String designation;
  String company;
  String text;
  String displayOrder;

  Testimonials(
      {this.name,
      this.designation,
      this.company,
      this.text,
      this.displayOrder});

  Testimonials.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    designation = json['designation'];
    company = json['company'];
    text = json['text'];
    displayOrder = json['display_order'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['designation'] = this.designation;
    data['company'] = this.company;
    data['text'] = this.text;
    data['display_order'] = this.displayOrder;
    return data;
  }
}
