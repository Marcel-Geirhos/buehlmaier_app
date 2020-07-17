class Assignment {
  String consumerName;
  String orderType;
  String numberOfElements;
  String installationDate;
  String glassDeliveryDate;
  String aluminumDeliveryDate;
  int status;
  int aluminum;
  String statusString;
  bool isGlassOrdered;
  bool isAluminumOrdered;

  Assignment(this.consumerName, this.orderType, this.numberOfElements, this.installationDate, this.glassDeliveryDate,
      this.aluminumDeliveryDate, this.status, this.aluminum, this.statusString, this.isGlassOrdered, this.isAluminumOrdered);
}
