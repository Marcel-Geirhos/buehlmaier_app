class Assignment {
  String consumerName;
  String orderType;
  String numberOfElements;
  String installationDate;
  String glassDeliveryDate;
  String aluminumDeliveryDate;
  String statusString;
  String prioritaetText;
  bool isGlassOrdered;
  bool isAluminumOrdered;
  int status;
  int aluminum;
  int prioritaet;

  Assignment(
    this.consumerName,
    this.orderType,
    this.numberOfElements,
    this.installationDate,
    this.glassDeliveryDate,
    this.aluminumDeliveryDate,
    this.status,
    this.aluminum,
    this.statusString,
    this.isGlassOrdered,
    this.isAluminumOrdered,
    this.prioritaetText,
    this.prioritaet,
  );
}
