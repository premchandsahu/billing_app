class InvoiceSummary {
  final int invoiceno;
  final DateTime invoicedate;
  final String customername;
  final double totalSAmount;
  final double totalPAmount;
  final String description;

  InvoiceSummary({
    required this.invoiceno,
    required this.invoicedate,
    required this.customername,
    required this.totalSAmount,
    required this.totalPAmount,
    required this.description,
  });

  factory InvoiceSummary.fromJson(Map<String, dynamic> json) {
    return InvoiceSummary(
      invoiceno: json["invoiceno"],
      invoicedate: DateTime.parse(json["invoicedate"]),
      customername: json["customername"] ?? "",
      totalSAmount: double.tryParse(json["totalSAmount"].toString()) ?? 0,
      totalPAmount: double.tryParse(json["totalPAmount"].toString()) ?? 0,
      description: json["description"] ?? "",
    );
  }
}
