import 'package:billing_app/models/account_balance.dart';
import 'package:billing_app/models/account_transaction.dart';
import 'package:billing_app/models/aging.dart';
import 'package:billing_app/models/customer.dart';
import 'package:billing_app/screens/invoice_screen.dart';
import 'package:billing_app/screens/payment_receipt.dart';
import 'package:billing_app/services/invoice_print_service.dart';
import 'package:billing_app/services/ledger_pdf_service.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/services/ledger_share_service.dart';
import 'package:billing_app/widgets/customer_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountLedger extends StatefulWidget {
  final int custno;
  final DateTime todate;
  final String custname;

  const AccountLedger({
    super.key,
    required this.custno,
    required this.todate,
    required this.custname,
  });

  @override
  State<AccountLedger> createState() => _AccountLedgerListState();
}

class _AccountLedgerListState extends State<AccountLedger> {
  final DateFormat df = DateFormat("dd-MM-yyyy");

  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();

  String? selectedCustomer;
  int? selectedCustomerNo;
  double openingbalance = 0;

  final InvoiceService service = InvoiceService();

  List<AccountBalance> receipts = [];
  List<AccountTransaction> accounttransactions = [];
  List<Aging> aging = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectedCustomerNo = widget.custno;
    selectedCustomer = widget.custname;
    toDate = widget.todate;
    fromDate = DateUtils.addMonthsToMonthDate(toDate, -1);
    // fromDate = toDate.add(const Duration(days:30));
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    setState(() {
      loading = true;
    });

    try {
      receipts = await service.getAccountBalance(
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

    try {
      accounttransactions = await service.getAccounTransaction(
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

    try {
      aging = await service.getAging(custno: selectedCustomerNo);
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

  Future<void> _shareLedgerPdf() async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select customer')));
      return;
    }

    try {
      final pdfBytes = await LedgerPdfService.generatePdf(
        fromdate: fromDate,
        todate: toDate,
        custno: selectedCustomerNo!,
        customername: selectedCustomer!,
        openingbalance: receipts[0].balance,
        items: accounttransactions,
        aging: aging,
      );

      await LedgerShareService.shareLedgerPdf(
        pdfBytes: pdfBytes,
        customername: widget.custname,
        message:
            "Period ${df.format(fromDate)}  to Period ${df.format(toDate)}, Op Bal: ${receipts[0].balance}, Invoice: $debitamount, Receipts: $creditamount, Cl Bal: ${receipts[0].balance + debitamount - creditamount} }",
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to share invoice: $e")));
    }
  }

  Future<void> _printLedger() async {
    if (selectedCustomer == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select customer')));
      return;
    }

    if (accounttransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one product')),
      );
      return;
    }

    final pdfBytes = await LedgerPdfService.generatePdf(
      fromdate: fromDate,
      todate: toDate,
      custno: selectedCustomerNo!,
      customername: selectedCustomer!,
      openingbalance: receipts[0].balance,
      items: accounttransactions,
      aging: aging,
    );

    await InvoicePrintService.printInvoice(pdfBytes);
  }

  double get debitamount =>
      accounttransactions.fold(0, (sum, e) => sum + e.invoiceamount);
  double get creditamount =>
      accounttransactions.fold(0, (sum, e) => sum + e.receiptamount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Balance List"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Print',
            onPressed: _printLedger,
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "WhatsApp / Share",
            onPressed: _shareLedgerPdf,
          ),
        ],
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
              "Balances",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            if (receipts.isNotEmpty && accounttransactions.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Opening Balance: ${receipts[0].balance}"),
                  Text("Invoices: $debitamount"),
                  Text("Receipts: $creditamount"),
                  Text(
                    "Closing Balance: ${receipts[0].balance + debitamount - creditamount}",
                  ),
                ],
              ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (receipts.isEmpty || accounttransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: Text(
                    "No account balances found",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounttransactions.length,
                itemBuilder: (context, index) {
                  final accounttransaction = accounttransactions[index];

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      onTap: () async {
                        if (accounttransaction.ttype == "receipt") {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentReceipt(
                                customerreceiptno: accounttransaction.tno,
                              ),
                            ),
                          );
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceScreen(
                                invoiceNo: accounttransaction.tno,
                                centerno: accounttransaction.centerno,
                              ),
                            ),
                          );
                        }
                        loadInvoices();
                      },
                      leading: CircleAvatar(
                        child: Text(
                          accounttransaction.tno.toString(),
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                      title: Text(
                        df.format(accounttransaction.tdate),

                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            accounttransaction.remarks,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            accounttransaction.centername,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        (accounttransaction.ttype == "receipt"
                            ? "₹${accounttransaction.receiptamount.toStringAsFixed(2)}"
                            : "₹${accounttransaction.invoiceamount.toStringAsFixed(2)}"),
                        style: TextStyle(
                          color: accounttransaction.ttype == "receipt"
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 10),
            if (aging.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("<30: ${aging[0].ca30},"),
                  Text("<60: ${aging[0].ca60},"),
                  Text("<120: ${aging[0].ca120},"),
                  Text("<180: ${aging[0].ca180},"),
                  Text(">180: ${aging[0].caa180}"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
