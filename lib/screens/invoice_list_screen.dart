import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/invoice_summary.dart';
import '../services/invoice_service.dart';
import '../widgets/customer_search_dialog.dart';
import '../models/customer.dart';
import 'invoice_screen.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  final DateFormat df = DateFormat("dd-MM-yyyy");

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String? selectedCustomer;
  int? selectedCustomerNo;

  final InvoiceService service = InvoiceService();

  List<InvoiceSummary> invoices = [];

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
      invoices = await service.getInvoiceSummary(
        fromDate: fromDate,
        toDate: toDate,
        custno: selectedCustomerNo,
        centerno: 1,
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
      appBar: AppBar(title: const Text("Invoice List"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceScreen()),
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
              "Invoices",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (invoices.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "No invoices found",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoice = invoices[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InvoiceScreen(invoiceNo: invoice.invoiceno),
                          ),
                        );

                        loadInvoices();
                      },
                      leading: CircleAvatar(
                        child: Text(invoice.invoiceno.toString()),
                      ),
                      title: Text(
                        invoice.customername,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(df.format(invoice.invoicedate)),
                          const SizedBox(height: 5),
                          Text(
                            invoice.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        "₹${invoice.totalSAmount.toStringAsFixed(2)}",
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
