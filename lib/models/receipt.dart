class Receipt {
  int customerreceiptno;
  String customerreceiptdate;
  int custno;
  String receiptamount;
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
      customerreceiptdate: json['customerreceiptdate'] ?? '',
      custno: json['custno'] ?? '',
      receiptamount: json['receiptamount'] ?? '',
      paymentmodeno: json['paymentmodeno'] ?? '',
      documentnumber: json['documentnumber'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "customerreceiptno": customerreceiptno,
      "customerreceiptdate": customerreceiptdate,
      "custno": custno,
      "receiptamount": receiptamount,
      "paymentmodeno": paymentmodeno,
      "documentnumber": documentnumber,
      "remarks": remarks,
    };
  }
}
