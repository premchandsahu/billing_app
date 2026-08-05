class Paymentmode {
  int paymentmodeno;
  String paymentmodedescription;

  Paymentmode({
    required this.paymentmodeno,
    required this.paymentmodedescription,
  });

  factory Paymentmode.fromJson(Map<String, dynamic> json) {
    return Paymentmode(
      paymentmodeno: json['paymentmodeno'],
      paymentmodedescription: json['paymentmodedescription'],
    );
  }
}
