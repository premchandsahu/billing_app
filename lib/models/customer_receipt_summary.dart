class CustomerReceiptSummary {
  int customerreceiptno;
  DateTime customerreceiptdate;
  String customername;
  double receiptamount;
  String paymentmodedescription;
  String documentnumber;
  String remarks;

  CustomerReceiptSummary({
    required this.customerreceiptno,
    required this.customerreceiptdate,
    required this.customername,
    required this.receiptamount,
    required this.paymentmodedescription,
    required this.documentnumber,
    required this.remarks,
  });

  factory CustomerReceiptSummary.fromJson(Map<String, dynamic> json) {
    return CustomerReceiptSummary(
      customerreceiptno: json['customerreceiptno'],
      customerreceiptdate: DateTime.parse(json['customerreceiptdate']),
      customername: json['customername'],
      receiptamount: double.tryParse(json['receiptamount'].toString()) ?? 0,
      paymentmodedescription: json['paymentmodedescription'],
      documentnumber: json['documentnumber'],
      remarks: json['remarks'],
    );
  }
}
