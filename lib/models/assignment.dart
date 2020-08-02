import 'package:flutter/foundation.dart';

class Assignment {
  String consumerName;
  String orderType;
  String numberOfElements;
  String installationDate;
  String glassDeliveryDate;
  String aluminumDeliveryDate;
  String statusText;
  String priorityText;
  bool isGlassOrdered;
  bool isAluminumOrdered;
  int status;
  int aluminum;
  int priority;

  Assignment({
    @required this.consumerName,
    @required this.orderType,
    @required this.numberOfElements,
    @required this.installationDate,
    @required this.glassDeliveryDate,
    @required this.aluminumDeliveryDate,
    @required this.status,
    @required this.aluminum,
    @required this.statusText,
    @required this.isGlassOrdered,
    @required this.isAluminumOrdered,
    @required this.priorityText,
    @required this.priority,
  });
}
