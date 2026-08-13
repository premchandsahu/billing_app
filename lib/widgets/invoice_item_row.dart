import 'package:flutter/material.dart';

import '../models/invoice_item.dart';

class InvoiceItemRow extends StatefulWidget {
  final InvoiceItem item;
  final VoidCallback onDelete;
  final VoidCallback onSelectProduct;
  final VoidCallback onChanged;
  final VoidCallback onNextItem;
  final int qtyFocusRequest;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onSelectProduct,
    required this.onChanged,
    required this.onNextItem,
    required this.qtyFocusRequest,
  });

  @override
  State<InvoiceItemRow> createState() => _InvoiceItemRowState();
}

class _InvoiceItemRowState extends State<InvoiceItemRow> {
  late final FocusNode _qtyFocusNode;
  late final TextEditingController _qtyController;
  late final TextEditingController _rateController;

  Widget _buildDesktopRow() {
    return Container(
      height: 54,
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // PRODUCT
          // ------------------------------------------------------
          Expanded(
            flex: 5,
            child: InkWell(
              onTap: widget.onSelectProduct,
              child: Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.item.product?.name ?? 'Select Product',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.item.product == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                    ),

                    const Icon(Icons.search, size: 18, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // QTY
          // ------------------------------------------------------
          Container(
            width: 70,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Center(
              child: TextField(
                controller: _qtyController,
                focusNode: _qtyFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 8,
                  ),
                ),
                onChanged: _qtyChanged,
              ),
            ),
          ),

          // ------------------------------------------------------
          // RATE
          // ------------------------------------------------------
          Container(
            width: 90,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Center(
              child: TextField(
                controller: _rateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 8,
                  ),
                ),
                onChanged: _rateChanged,
              ),
            ),
          ),

          // ------------------------------------------------------
          // AMOUNT
          // ------------------------------------------------------
          Container(
            width: 100,
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
            ),
            alignment: Alignment.centerRight,
            child: Text(
              widget.item.amount.toStringAsFixed(2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),

          // ------------------------------------------------------
          // DELETE
          // ------------------------------------------------------
          SizedBox(
            width: 45,
            height: double.infinity,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: widget.onDelete,
              tooltip: 'Delete',
              icon: const Icon(
                Icons.delete_outline,
                size: 20,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileInput({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction keyboardAction,
    required ValueChanged<String> onChanged,
    required ValueChanged<String> onSubmitted,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),

        // Important:
        // Keep the cursor in this field while typing.
        textInputAction: TextInputAction.none,

        textAlign: TextAlign.right,

        style: const TextStyle(fontSize: 14),

        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 8,
          ),
        ),

        onChanged: onChanged,

        // Do not move focus automatically.
        onSubmitted: null,
      ),
    );
  }

  Widget _buildMobileRow() {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ------------------------------------------------------
          // PRODUCT
          // ------------------------------------------------------
          SizedBox(
            height: 40,
            child: InkWell(
              onTap: widget.onSelectProduct,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.product?.name ?? 'Select Product',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.item.product == null
                            ? Colors.grey.shade600
                            : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.search, size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          const SizedBox(height: 5),

          // ------------------------------------------------------
          // QTY / RATE / AMOUNT / DELETE
          // ------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _qtyController,
                  focusNode: _qtyFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'Qty',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                  ),
                  onChanged: _qtyChanged,
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                flex: 4,
                child: TextField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    labelText: 'Rate',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                  ),
                  onChanged: _rateChanged,
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                flex: 4,
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      Text(
                        widget.item.amount.toStringAsFixed(2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 2),

              SizedBox(
                width: 34,
                height: 48,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: widget.onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //And replace _buildMobileInput() with:

  @override
  void initState() {
    super.initState();
    _qtyFocusNode = FocusNode();
    _qtyController = TextEditingController(text: _getQtyText());

    _rateController = TextEditingController(text: _getRateText());
  }

  // ------------------------------------------------------------
  // IMPORTANT:
  // Synchronize TextFields when InvoiceScreen changes
  // product / qty / rate.
  // ------------------------------------------------------------
  @override
  void didUpdateWidget(covariant InvoiceItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Synchronize controller values with the InvoiceItem.
    _syncControllers();

    // Product was selected -> request Qty focus.
    if (widget.qtyFocusRequest != oldWidget.qtyFocusRequest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _qtyFocusNode.requestFocus();
        }
      });
    }
  }
  // ------------------------------------------------------------
  // QTY TEXT
  // ------------------------------------------------------------

  String _getQtyText() {
    if (widget.item.qty == 0) {
      return '';
    }

    if (widget.item.qty == widget.item.qty.roundToDouble()) {
      return widget.item.qty.toInt().toString();
    }

    return widget.item.qty.toString();
  }

  // ------------------------------------------------------------
  // RATE TEXT
  // ------------------------------------------------------------

  String _getRateText() {
    if (widget.item.rate == 0) {
      return '';
    }

    return widget.item.rate.toStringAsFixed(2);
  }

  void _syncControllers() {
    final qtyText = _getQtyText();
    final rateText = _getRateText();

    // Sync only when the displayed value is actually different.
    // This prevents the cursor from jumping while typing.
    if (_qtyController.text != qtyText) {
      _qtyController.value = TextEditingValue(
        text: qtyText,
        selection: TextSelection.collapsed(offset: qtyText.length),
      );
    }

    if (_rateController.text != rateText) {
      _rateController.value = TextEditingValue(
        text: rateText,
        selection: TextSelection.collapsed(offset: rateText.length),
      );
    }
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    _qtyController.dispose();
    _rateController.dispose();
    _qtyFocusNode.dispose();

    //  _qtyFocusNode.dispose();
    //  _rateFocusNode.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // QTY CHANGED
  // ------------------------------------------------------------

  void _qtyChanged(String value) {
    widget.item.qty = double.tryParse(value) ?? 0;

    widget.onChanged();
  }

  // ------------------------------------------------------------
  // RATE CHANGED
  // ------------------------------------------------------------

  void _rateChanged(String value) {
    widget.item.rate = double.tryParse(value) ?? 0;

    widget.onChanged();
  }

  // ------------------------------------------------------------
  // PRODUCT
  // ------------------------------------------------------------

  void _selectProduct() {
    widget.onSelectProduct();
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use compact grid on larger screens.
    // Use two-line layout on mobile.
    if (screenWidth >= 600) {
      return _buildDesktopRow();
    }

    return _buildMobileRow();
  }
}
