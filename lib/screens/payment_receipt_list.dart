import 'package:billing_app/models/customer.dart';
import 'package:billing_app/models/customer_receipt_summary.dart';
import 'package:billing_app/screens/invoice_screen.dart';
import 'package:billing_app/screens/payment_receipt.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/widgets/customer_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PayementReceiptList extends StatefulWidget {
  const PayementReceiptList({super.key});

  @override
  State<PayementReceiptList> createState() => _PayementReceiptListState();
}

class _PayementReceiptListState extends State<PayementReceiptList> {
  final DateFormat df = DateFormat("dd-MM-yyyy");

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String? selectedCustomer;
  int? selectedCustomerNo;

  final InvoiceService service = InvoiceService();

  List<CustomerReceiptSummary> receipts = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    setState(() {
      loading = true;
    });

    try {
      receipts = await service.getReceiptSummary(
        fromDate: fromDate,
        toDate: toDate,
        custno: selectedCustomerNo,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _selectFromDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        fromDate = date;
      });
    }
  }

  Future<void> _selectToDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        toDate = date;
      });
    }
  }

  Future<void> _search() async {
    await loadInvoices();
  }

  Future<void> _refresh() async {
    await loadInvoices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Receipts List"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentReceipt(), //place holder for now
            ),
          );

          loadInvoices();
        },
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        final Customer? customer = await showDialog<Customer>(
                          context: context,
                          builder: (_) => const CustomerSearchDialog(),
                        );

                        if (customer != null) {
                          setState(() {
                            selectedCustomer = customer.customername;
                            selectedCustomerNo = customer.custno;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: "Customer",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                        child: Text(
                          selectedCustomer ?? "All Customers",
                          style: TextStyle(
                            color: selectedCustomer == null
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectFromDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(df.format(fromDate)),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _selectToDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(df.format(toDate)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        label: const Text("SEARCH"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Receipts",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (receipts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "No receipts found",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: receipts.length,
                itemBuilder: (context, index) {
                  final receipt = receipts[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentReceipt(
                              customerreceiptno: receipt.customerreceiptno,
                            ),
                          ),
                        );

                        loadInvoices();
                      },
                      leading: CircleAvatar(
                        child: Text(receipt.customerreceiptno.toString()),
                      ),
                      title: Text(
                        receipt.customername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(df.format(receipt.customerreceiptdate)),
                          const SizedBox(height: 5),
                          Text(
                            receipt.paymentmodedescription,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        "₹${receipt.receiptamount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
