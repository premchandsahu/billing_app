import 'package:billing_app/models/invoice.dart';
import 'package:billing_app/models/product.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/widgets/product_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../widgets/customer_search_dialog.dart';
import '../models/invoice_item.dart';
import '../widgets/invoice_item_row.dart';

class InvoiceScreen extends StatefulWidget {
  final int? invoiceNo;

  const InvoiceScreen({super.key, this.invoiceNo});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final DateFormat df = DateFormat("dd-MM-yyyy");

  DateTime invoiceDate = DateTime.now();
  List<InvoiceItem> items = [];
  Customer? selectedCustomer;
  Product? selectedProduct;

  final remarksController = TextEditingController();

  bool get isEdit => widget.invoiceNo != null;

  @override
  void initState() {
    super.initState();

    if (widget.invoiceNo != null) {
      loadInvoice();
    }
  }

  Future<void> saveInvoice() async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select Customer")));
      return;
    }

    if (items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least one product")));
      return;
    }
    final lines = items.map((e) {
      return InvoiceLine(
        productno: e.product!.productno,
        productqty: e.qty,
        productrate: e.rate,
        total: e.amount,
      );
    }).toList();

    final invoice = Invoice(
      invoiceno: widget.invoiceNo,
      invoicedate: invoiceDate,
      custno: selectedCustomer!.custno,
      centerno: 1,
      total: grandTotal,
      remarks: remarksController.text,
      details: lines,
    );

    bool success;

    if (widget.invoiceNo == null) {
      success = await InvoiceService().insertInvoice(invoice);
    } else {
      success = await InvoiceService().updateInvoice(invoice);
    }
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.invoiceNo == null ? "Invoice Saved" : "Invoice Updated",
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to save invoice")));
    }
  }

  Future<void> loadInvoice() async {
    final invoice = await InvoiceService().getInvoice(
      invoiceNo: widget.invoiceNo!,
      centerNo: 1,
    );

    final customers = await InvoiceService().getCustomers();
    final products = await InvoiceService().getProducts();

    setState(() {
      invoiceDate = invoice.invoicedate;

      remarksController.text = invoice.remarks;

      selectedCustomer = customers.firstWhere(
        (c) => c.custno == invoice.custno,
      );

      items.clear();

      for (final line in invoice.details) {
        final product = products.firstWhere(
          (p) => p.productno == line.productno,
        );

        items.add(
          InvoiceItem(
            product: product,
            qty: line.productqty,
            rate: line.productrate,
          ),
        );
      }
    });

    refreshTotal();
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        invoiceDate = date;
      });
    }
  }

  Future<void> selectCustomer() async {
    final Customer? customer = await showDialog<Customer>(
      context: context,
      builder: (_) => const CustomerSearchDialog(),
    );

    if (customer != null) {
      setState(() {
        selectedCustomer = customer;
      });
    }
  }

  Future<void> selectProduct() async {
    final Product? product = await showDialog<Product>(
      context: context,
      builder: (_) => const ProductSearchDialog(),
    );

    if (product != null) {
      setState(() {
        selectedProduct = product;
      });
    }
  }

  double get grandTotal => items.fold(0, (sum, e) => sum + e.amount);

  void addItem() {
    setState(() {
      items.add(InvoiceItem());
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void refreshTotal() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Invoice" : "New Invoice"),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: () {
                // Delete later
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          saveInvoice;
        },
        icon: const Icon(Icons.save),
        label: const Text("SAVE"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    "Invoice No : ${widget.invoiceNo ?? "NEW"}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(df.format(invoiceDate)),
                  ),

                  const SizedBox(height: 15),

                  InkWell(
                    onTap: selectCustomer,

                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Customer",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        selectedCustomer?.customername ?? "Select Customer",
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller: remarksController,
                    maxLines: 3,

                    decoration: const InputDecoration(
                      labelText: "Remarks",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Products",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          addItem();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Product"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  if (items.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          "No Products Added",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (_, index) {
                        return InvoiceItemRow(
                          item: items[index],
                          onDelete: () => removeItem(index),
                          onSelectProduct: () {
                            selectProduct();
                          },
                          onChanged: refreshTotal,
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            color: Colors.indigo.shade50,

            child: Padding(
              padding: const EdgeInsets.all(18),

              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Grand Total",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    "₹${grandTotal.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
