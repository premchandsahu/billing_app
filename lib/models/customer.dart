class Customer {
  final int custno;
  final String customername;
  final String customeraddress;
  final String customerphone1;
  final String customerphone2;
  final String customeremail;
  final double openingbalance;

  Customer({
    required this.custno,
    required this.customername,
    required this.customeraddress,
    required this.customerphone1,
    required this.customerphone2,
    required this.customeremail,
    required this.openingbalance,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      custno: json['custno'],
      customername: json['customername'] ?? '',
      customeraddress: json['customeraddress'] ?? '',
      customerphone1: json['customerphone1'] ?? '',
      customerphone2: json['customerphone2'] ?? '',
      customeremail: json['customeremail'] ?? '',
      openingbalance: double.tryParse(json['openingbalance'].toString()) ?? 0,
    );
  }
}
