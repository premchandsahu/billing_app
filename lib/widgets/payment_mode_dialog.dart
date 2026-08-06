import 'package:billing_app/models/paymentmode.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:flutter/material.dart';

class PaymentModeDialog extends StatefulWidget {
  const PaymentModeDialog({super.key});

  @override
  State<PaymentModeDialog> createState() => _PaymentModeDialogState();
}

class _PaymentModeDialogState extends State<PaymentModeDialog> {
  final InvoiceService service = InvoiceService();

  List<Paymentmode> paymentmode = [];
  List<Paymentmode> filtered = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPaymentmode();
  }

  Future<void> loadPaymentmode() async {
    try {
      paymentmode = await service.getPaymentmode();
      filtered = List.from(paymentmode);
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

  void filter(String value) {
    value = value.toLowerCase();

    setState(() {
      filtered = paymentmode.where((c) {
        return c.paymentmodedescription.toLowerCase().contains(value);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 500,
        height: 600,

        child: Column(
          children: [
            AppBar(
              title: const Text("Select Paymentmode"),
              automaticallyImplyLeading: false,
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: TextField(
                controller: searchController,

                decoration: InputDecoration(
                  hintText: "Search Paymentmode...",
                  prefixIcon: const Icon(Icons.search),

                  suffixIcon: searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            searchController.clear();
                            filter("");
                          },
                          icon: const Icon(Icons.clear),
                        ),

                  border: const OutlineInputBorder(),
                ),

                onChanged: filter,
              ),
            ),

            if (loading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,

                  itemBuilder: (_, index) {
                    final Paymentmode = filtered[index];

                    return ListTile(
                      title: Text(Paymentmode.paymentmodedescription),

                      onTap: () {
                        Navigator.pop(context, Paymentmode);
                      },
                    );
                  },
                ),
              ),

            const Divider(height: 1),

            Padding(
              padding: const EdgeInsets.all(10),

              child: Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context, null);
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Clear"),
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Close"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
