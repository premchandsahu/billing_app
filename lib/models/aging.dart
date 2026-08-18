class Aging {
  int custno;
  String customername;
  double ca30;
  double ca60;
  double ca120;
  double ca180;
  double caa180;

  Aging({
    required this.custno,
    required this.customername,
    required this.ca30,
    required this.ca60,
    required this.ca120,
    required this.ca180,
    required this.caa180,
  });

  factory Aging.fromJson(Map<String, dynamic> json) {
    return Aging(
      custno: json["custno"],
      customername: json["customername"],
      ca30: double.tryParse(json["ca30"]) ?? 0,
      ca60: double.tryParse(json["ca60"]) ?? 0,
      ca120: double.tryParse(json["ca120"]) ?? 0,
      ca180: double.tryParse(json["ca180"]) ?? 0,
      caa180: double.tryParse(json["caa180"]) ?? 0,
    );
  }
}
