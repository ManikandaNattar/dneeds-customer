import 'package:flutter/material.dart';
import 'package:daily_needs/getAllCategoryService.dart';

class ServiceData {
  String serviceName;
  List<String> subServiceIds;
  List<SubServices> subServices;
  String service_Id;

  ServiceData(
      {Key key,
      this.serviceName,
      this.service_Id,
      this.subServiceIds,
      this.subServices});
}

class ChoosingButton {
  MaterialButton choosenButton;

  ChoosingButton({Key key, this.choosenButton});
}
