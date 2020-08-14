import 'package:flutter/foundation.dart';

class Assignment {
  String consumerName;
  String orderType;
  String numberOfElements;
  String creationDate;
  String installationDate;
  String glassDeliveryDate;
  String aluminumDeliveryDate;
  String statusText;
  String priorityText;
  String archiveDate;
  bool isGlassOrdered;
  bool isAluminumOrdered;
  int creationDateMilliseconds;
  int status;
  int aluminum;
  int priority;

  Assignment({
    @required this.consumerName,
    @required this.orderType,
    @required this.numberOfElements,
    @required this.installationDate,
    this.glassDeliveryDate,
    this.aluminumDeliveryDate,
    this.status,
    this.aluminum,
    this.statusText,
    this.isGlassOrdered,
    this.isAluminumOrdered,
    this.priorityText,
    this.priority,
    this.creationDate,
    this.creationDateMilliseconds,
    this.archiveDate,
  });
}
