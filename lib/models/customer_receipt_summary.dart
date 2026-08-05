class CustomerReceiptSummary {
  int customerreceiptno;
  String customerreceiptdate;
  String customername;
  String receiptamount;
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
      customerreceiptdate: json['customerreceiptdate'],
      customername: json['customername'],
      receiptamount: json['receiptamount'],
      paymentmodedescription: json['paymentmodedescription'],
      documentnumber: json['documentnumber'],
      remarks: json['remarks'],
    );
  }
}
