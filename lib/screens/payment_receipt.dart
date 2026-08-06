import 'package:billing_app/models/customer.dart';
import 'package:billing_app/models/paymentmode.dart';
import 'package:billing_app/models/receipt.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/widgets/customer_search_dialog.dart';
import 'package:billing_app/widgets/payment_mode_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentReceipt extends StatefulWidget {
  final int? customerreceiptno;
  const PaymentReceipt({super.key, this.customerreceiptno});

  @override
  State<PaymentReceipt> createState() => _PaymentReceiptState();
}

class _PaymentReceiptState extends State<PaymentReceipt> {
  Receipt? receipt;

  final DateFormat df = DateFormat("dd-MM-yyyy");
  DateTime receiptdate = DateTime.now();
  Customer? selectedCustomer;
  final receiptamountController = TextEditingController();
  Paymentmode? selectedPaymentmode;
  final documentnumberController = TextEditingController();
  final remarksController = TextEditingController();
  bool get isEdit => widget.customerreceiptno != null;

  @override
  void initState() {
    super.initState();

    if (widget.customerreceiptno != null) {
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

    final receipt = Receipt(
      customerreceiptno: widget.customerreceiptno ?? 0,
      customerreceiptdate: receiptdate,
      custno: selectedCustomer!.custno,
      receiptamount: 0,
      paymentmodeno: selectedPaymentmode!.paymentmodeno,
      documentnumber: "11",
      remarks: remarksController.text,
    );

    bool success;

    if (widget.customerreceiptno == null) {
      success = await InvoiceService().insertReceipt(receipt);
    } else {
      success = await InvoiceService().updateReceipt(receipt);
    }
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.customerreceiptno == null
                ? "Receipt Saved"
                : "Receipt Updated",
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unable to save receipt")));
    }
  }

  Future<void> loadInvoice() async {
    final invoice = await InvoiceService().getCustomerreceipt(
      receiptno: widget.customerreceiptno!,
    );

    final customers = await InvoiceService().getCustomers();
    final paymentmodes = await InvoiceService().getPaymentmode();

    setState(() {
      selectedCustomer = customers.firstWhere(
        (c) => c.custno == invoice.custno,
      );

      selectedPaymentmode = paymentmodes.firstWhere(
        (c) => c.paymentmodeno == invoice.paymentmodeno,
      );
      receiptdate = invoice.customerreceiptdate;

      remarksController.text = invoice.remarks;

      receiptamountController.text = invoice.receiptamount.toString();

      documentnumberController.text = invoice.documentnumber;
    });
  }

  @override
  void dispose() {
    remarksController.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: receiptdate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        receiptdate = date;
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

  Future<void> selectPaymentmode() async {
    final Paymentmode? paymentmode = await showDialog<Paymentmode>(
      context: context,
      builder: (_) => const PaymentModeDialog(),
    );

    if (paymentmode != null) {
      setState(() {
        selectedPaymentmode = paymentmode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Receipt" : "New Receipt"),
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
        onPressed: saveInvoice,
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
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Receipt No : ${widget.customerreceiptno ?? "NEW"}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(df.format(receiptdate)),
                      ),
                    ],
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
        ],
      ),
    );
  }
}
