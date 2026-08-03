import 'package:flutter/material.dart';

import '../models/customer.dart';
import '../services/invoice_service.dart';

class CustomerSearchDialog extends StatefulWidget {
  const CustomerSearchDialog({super.key});

  @override
  State<CustomerSearchDialog> createState() => _CustomerSearchDialogState();
}

class _CustomerSearchDialogState extends State<CustomerSearchDialog> {
  final InvoiceService service = InvoiceService();

  List<Customer> customers = [];
  List<Customer> filtered = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      customers = await service.getCustomers();
      filtered = List.from(customers);
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
      filtered = customers.where((c) {
        return c.customername.toLowerCase().contains(value) ||
            c.customerphone1.contains(value);
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
              title: const Text("Select Customer"),
              automaticallyImplyLeading: false,
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: TextField(
                controller: searchController,

                decoration: InputDecoration(
                  hintText: "Search customer...",
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
                    final customer = filtered[index];

                    return ListTile(
                      title: Text(customer.customername),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(customer.customerphone1),

                          if (customer.customeraddress.isNotEmpty)
                            Text(
                              customer.customeraddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),

                      onTap: () {
                        Navigator.pop(context, customer);
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
