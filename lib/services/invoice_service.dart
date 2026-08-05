import 'dart:convert';

import 'package:billing_app/models/centers.dart';
import 'package:billing_app/models/customer_receipt_summary.dart';
import 'package:billing_app/models/paymentmode.dart';
import 'package:billing_app/models/receipt.dart';
import 'package:http/http.dart' as http;

import '../models/customer.dart';
import '../models/product.dart';
import '../models/invoice.dart';
import '../models/invoice_summary.dart';
import 'api.dart';

class InvoiceService {
  ///------------------------------
  /// Customers
  ///------------------------------
  Future<List<Customer>> getCustomers() async {
    final response = await http.get(Uri.parse(Api.customer));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Customer.fromJson(e)).toList();
    }

    throw Exception("Unable to load customers");
  }

  ///------------------------------
  /// Products
  ///------------------------------
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse(Api.product));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }

    throw Exception("Unable to load products");
  }

  ///------------------------------
  /// Invoices
  ///------------------------------
  Future<List<Invoice>> getInvoices() async {
    final response = await http.get(Uri.parse(Api.invoice));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Invoice.fromJson(e)).toList();
    }

    throw Exception("Unable to load invoices");
  }

  ///------------------------------
  /// Insert
  ///------------------------------
  Future<bool> insertInvoice(Invoice invoice) async {
    final response = await http.post(
      Uri.parse(Api.invoice),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(invoice.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  ///------------------------------
  /// Update
  ///------------------------------
  Future<bool> updateInvoice(Invoice invoice) async {
    final response = await http.post(
      Uri.parse(Api.invoice),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(invoice.toJson()),
    );

    return response.statusCode == 200;
  }

  Future<int> lastInvoice(int centerno) async {
    final response = await http.post(
      Uri.parse(Api.lastinvoice),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"centerno": centerno}),
    );
    Map<String, dynamic> jsonMap = jsonDecode(response.body.toString());
    return jsonMap['lastinvoiceno'] as int;
  }

  ///------------------------------
  /// Delete
  ///------------------------------
  Future<bool> deleteInvoice(int invoiceNo) async {
    final response = await http.delete(Uri.parse("${Api.invoice}/$invoiceNo"));

    return response.statusCode == 200;
  }

  Future<List<InvoiceSummary>> getInvoiceSummary({
    required DateTime fromDate,
    required DateTime toDate,
    int? custno,
    required int centerno,
  }) async {
    final response = await http.post(
      Uri.parse("${Api.invoice}/reportinvoicesummary"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fromdate": fromDate.toIso8601String().split("T").first,
        "todate": toDate.toIso8601String().split("T").first,
        "custno": custno,
        "centerno": centerno,
      }),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);

      return list.map((e) => InvoiceSummary.fromJson(e)).toList();
    }

    throw Exception("Unable to load invoices");
  }

  Future<Invoice> getInvoice({
    required int invoiceNo,
    required int centerNo,
  }) async {
    final response = await http.get(
      Uri.parse("${Api.invoice}/$invoiceNo/$centerNo"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle both { ... } and [ { ... } ] response formats.
      if (data is List) {
        if (data.isEmpty) {
          throw Exception("Invoice not found");
        }
        return Invoice.fromJson(data.first);
      }

      return Invoice.fromJson(data);
    }

    throw Exception("Unable to load invoice");
  }

  ///------------------------------
  /// Centers
  ///------------------------------
  Future<List<Centers>> getCenters() async {
    final response = await http.get(Uri.parse(Api.center));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Centers.fromJson(e)).toList();
    }

    throw Exception("Unable to load centers");
  }

  Future<Centers> getCenter({required int centerNo}) async {
    final response = await http.get(Uri.parse("${Api.center}/$centerNo"));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle both { ... } and [ { ... } ] response formats.
      if (data is List) {
        if (data.isEmpty) {
          throw Exception("Center not found");
        }
        return Centers.fromJson(data.first);
      }

      return Centers.fromJson(data);
    }

    throw Exception("Unable to load invoice");
  }

  ///------------------------------
  /// Customer receipt
  ///------------------------------
  Future<List<Receipt>> getCustomerreceipts() async {
    final response = await http.get(Uri.parse(Api.customerreceipt));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Receipt.fromJson(e)).toList();
    }

    throw Exception("Unable to load receipts");
  }

  Future<Receipt> getCustomerreceipt({required int receiptno}) async {
    final response = await http.get(
      Uri.parse("${Api.customerreceipt}/$receiptno"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Handle both { ... } and [ { ... } ] response formats.
      if (data is List) {
        if (data.isEmpty) {
          throw Exception("Center not found");
        }
        return Receipt.fromJson(data.first);
      }

      return Receipt.fromJson(data);
    }
    throw Exception("Unable to load centers");
  }

  Future<bool> insertReceipt(Receipt receipt) async {
    final response = await http.post(
      Uri.parse(Api.customerreceipt),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(receipt.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateReceipt(Receipt receipt) async {
    final response = await http.put(
      Uri.parse(Api.customerreceipt),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(receipt.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<List<Paymentmode>> getPaymentmode() async {
    final response = await http.get(Uri.parse(Api.paymentmode));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Paymentmode.fromJson(e)).toList();
    }

    throw Exception("Unable to load receipts");
  }

  Future<List<CustomerReceiptSummary>> getReceiptSummary({
    required DateTime fromDate,
    required DateTime toDate,
    int? custno,
  }) async {
    final response = await http.post(
      Uri.parse("${Api.customerreceipt}/fetchpostcustomerreceipts"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fromdate": fromDate.toIso8601String().split("T").first,
        "todate": toDate.toIso8601String().split("T").first,
        "custno": custno,
      }),
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);

      return list.map((e) => CustomerReceiptSummary.fromJson(e)).toList();
    }

    throw Exception("Unable to load invoices");
  }
}
