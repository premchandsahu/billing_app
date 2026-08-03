import 'package:flutter/material.dart';

import '../models/invoice_item.dart';

class InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final VoidCallback onDelete;
  final VoidCallback onSelectProduct;
  final VoidCallback onChanged;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSelectProduct,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qtyController = TextEditingController(text: item.qty.toString());

    final rateController = TextEditingController(
      text: item.rate.toStringAsFixed(2),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: onSelectProduct,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Product",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(item.product?.name ?? "Select Product"),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Qty",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      item.qty = double.tryParse(value) ?? 0;
                      onChanged();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Rate",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      item.rate = double.tryParse(value) ?? 0;
                      onChanged();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 90,
                  child: Text(
                    item.amount.toStringAsFixed(2),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
