class AccountBalance {
  int custno;
  String customername;
  String customerphone1;
  double balance;

  AccountBalance({
    required this.custno,
    required this.customername,
    required this.customerphone1,
    required this.balance,
  });

  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    return AccountBalance(
      custno: json["custno"],
      customername: json["customername"],
      customerphone1: json["customerphone1"],
      balance: double.tryParse(json["balance"]) ?? 0,
    );
  }
}
