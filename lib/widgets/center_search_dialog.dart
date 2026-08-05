import 'package:flutter/material.dart';

import '../models/centers.dart';
import '../services/invoice_service.dart';

class CentersSearchDialog extends StatefulWidget {
  const CentersSearchDialog({super.key});

  @override
  State<CentersSearchDialog> createState() => _CentersSearchDialogState();
}

class _CentersSearchDialogState extends State<CentersSearchDialog> {
  final InvoiceService service = InvoiceService();

  List<Centers> centerss = [];
  List<Centers> filtered = [];

  bool loading = true;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCenterss();
  }

  Future<void> loadCenterss() async {
    try {
      centerss = await service.getCenters();
      filtered = List.from(centerss);
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
      filtered = centerss.where((c) {
        return c.centername.toLowerCase().contains(value);
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
              title: const Text("Select Centers"),
              automaticallyImplyLeading: false,
            ),

            Padding(
              padding: const EdgeInsets.all(10),

              child: TextField(
                controller: searchController,

                decoration: InputDecoration(
                  hintText: "Search centers...",
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
                    final centers = filtered[index];

                    return ListTile(
                      title: Text(centers.centername),

                      onTap: () {
                        Navigator.pop(context, centers);
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
