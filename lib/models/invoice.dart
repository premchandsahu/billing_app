class Invoice {
  int? invoiceno;
  DateTime invoicedate;
  int custno;
  int centerno;
  double total;
  String remarks;
  List<InvoiceLine> details;

  Invoice({
    this.invoiceno,
    required this.invoicedate,
    required this.custno,
    required this.centerno,
    required this.total,
    required this.remarks,
    required this.details,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceno: json["invoiceno"],
      invoicedate: DateTime.parse(json["invoicedate"]),
      custno: json["custno"],
      centerno: json["centerno"],
      total: double.tryParse(json["total"].toString()) ?? 0,
      remarks: json["remarks"] ?? "",
      details: (json["details"] as List? ?? [])
          .map((e) => InvoiceLine.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "invoiceno": invoiceno,
      "invoicedate": invoicedate.toIso8601String(),
      "custno": custno,
      "centerno": centerno,
      "remarks": remarks,
      "details": details.map((e) => e.toJson()).toList(),
    };
  }
}

class InvoiceLine {
  int productno;
  double productqty;
  double productrate;
  double total;

  InvoiceLine({
    required this.productno,
    required this.productqty,
    required this.productrate,
    required this.total,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    return InvoiceLine(
      productno: json["productno"],
      productqty: double.tryParse(json["productqty"].toString()) ?? 0,
      productrate: double.tryParse(json["productrate"].toString()) ?? 0,
      total: double.tryParse(json["total"].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "productno": productno,
      "productqty": productqty,
      "productrate": productrate,
      "total": total,
    };
  }
}
