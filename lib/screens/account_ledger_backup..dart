import 'package:billing_app/models/account_balance.dart';
import 'package:billing_app/models/account_transaction.dart';
import 'package:billing_app/models/customer.dart';
import 'package:billing_app/screens/payment_receipt.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/widgets/customer_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountLedger extends StatefulWidget {
  final int custno;
  final DateTime todate;

  const AccountLedger({super.key, required this.custno, required this.todate});

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

  bool loading = false;

  @override
  void initState() {
    super.initState();
    selectedCustomerNo = widget.custno;
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
      appBar: AppBar(
        title: const Text("Account Balance List"),
        centerTitle: true,
      ),
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
              "Balances",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            if (receipts.isNotEmpty)
              Text("Opening Balance: ${receipts[0].balance}"),
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
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                //  if (accounttransaction.ttype) == ""
                                PaymentReceipt(
                                  //     customerreceiptno: receipt.customername, will be called later
                                ),
                          ),
                        );

                        loadInvoices();
                      },
                      leading: CircleAvatar(
                        child: Column(
                          children: [
                            Text(accounttransaction.tno.toString()),
                            Text(accounttransaction.ttype),
                          ],
                        ),
                      ),
                      title: Text(
                        accounttransaction.tdate.toIso8601String(),
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
                        "₹${accounttransaction.receiptamount.toStringAsFixed(2)}",
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
