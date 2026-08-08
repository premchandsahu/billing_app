class Receipt {
  int customerreceiptno;
  DateTime customerreceiptdate;
  int custno;
  double receiptamount;
  int paymentmodeno;
  String documentnumber;
  String remarks;

  Receipt({
    required this.customerreceiptno,
    required this.customerreceiptdate,
    required this.custno,
    required this.receiptamount,
    required this.paymentmodeno,
    required this.documentnumber,
    required this.remarks,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      customerreceiptno: json['customerreceiptno'],
      customerreceiptdate: DateTime.parse(json['customerreceiptdate']),
      custno: json['custno'],
      receiptamount: double.tryParse(json['receiptamount']) ?? 0,
      paymentmodeno: json['paymentmodeno'],
      documentnumber: json['documentnumber'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customerreceiptno": customerreceiptno,
      "customerreceiptdate": customerreceiptdate.toIso8601String(),
      "custno": custno,
      "receiptamount": receiptamount,
      "paymentmodeno": paymentmodeno,
      "documentnumber": documentnumber,
      "remarks": remarks,
    };
  }
}
