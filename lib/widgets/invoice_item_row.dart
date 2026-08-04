import 'package:flutter/material.dart';

import '../models/invoice_item.dart';

class InvoiceItemRow extends StatefulWidget {
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
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;

  @override
  void initState() {
    super.initState();

    _qtyController = TextEditingController(
      text: widget.item.qty == 0 ? '' : widget.item.qty.toString(),
    );

    _rateController = TextEditingController(
      text: widget.item.rate == 0 ? '' : widget.item.rate.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _qtyChanged(String value) {
    widget.item.qty = double.tryParse(value) ?? 0;

    setState(() {});

    widget.onChanged();
  }

  void _rateChanged(String value) {
    widget.item.rate = double.tryParse(value) ?? 0;

    setState(() {});

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: widget.onSelectProduct,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Product",
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        widget.item.product?.name ?? "Select Product",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Qty",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _qtyChanged,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: _rateController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Rate",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _rateChanged,
                  ),
                ),

                const SizedBox(width: 10),

                SizedBox(
                  width: 90,
                  child: Text(
                    widget.item.amount.toStringAsFixed(2),
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
