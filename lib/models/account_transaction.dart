class AccountTransaction {
  String ttype;
  int custno;
  int centerno;
  String centername;
  int tno;
  DateTime tdate;
  double invoiceamount;
  double receiptamount;
  String remarks;

  AccountTransaction({
    required this.ttype,
    required this.custno,
    required this.centerno,
    required this.centername,
    required this.tno,
    required this.tdate,
    required this.invoiceamount,
    required this.receiptamount,
    required this.remarks,
  });

  factory AccountTransaction.fromJson(Map<String, dynamic> json) {
    return AccountTransaction(
      ttype: json['ttype'],
      custno: json['custno'],
      centerno: json['centerno'] ?? 0,
      centername: json['centername'],
      tno: json['tno'],
      tdate: DateTime.parse(json['tdate']),
      invoiceamount: double.tryParse(json['invoiceamount']) ?? 0,
      receiptamount: double.tryParse(json['receiptamount']) ?? 0,
      remarks: json['remarks'],
    );
  }
}
