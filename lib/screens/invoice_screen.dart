import 'package:billing_app/models/centers.dart';
import 'package:billing_app/models/invoice.dart';
import 'package:billing_app/models/product.dart';
import 'package:billing_app/services/invoice_pdf_service.dart';
import 'package:billing_app/services/invoice_print_service.dart';
import 'package:billing_app/services/invoice_service.dart';
import 'package:billing_app/services/invoice_share_service.dart';
import 'package:billing_app/widgets/product_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/customer.dart';
import '../widgets/customer_search_dialog.dart';
import '../models/invoice_item.dart';
import '../widgets/invoice_item_row.dart';

class InvoiceScreen extends StatefulWidget {
  final int? invoiceNo;
  final int centerno;

  const InvoiceScreen({super.key, this.invoiceNo, required this.centerno});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  final DateFormat df = DateFormat("dd-MM-yyyy");

  int? lastinvoiceno = 0;
  final Map<int, FocusNode> _qtyFocusNodes = {};
  DateTime invoiceDate = DateTime.now();

  List<InvoiceItem> items = [];
  int _qtyFocusRequest = 0;
  Customer? selectedCustomer;

  Centers? centers;

  final remarksController = TextEditingController();

  bool isSaving = false;
  bool isLoading = false;

  bool get isEdit => widget.invoiceNo != null;

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    if (isEdit) {
      loadInvoice();
    }

    lastInvoice(widget.centerno);
    getcenter();
  }

  Future<void> _completeCurrentItem(int index) async {
    // Don't create another row if product hasn't been selected.
    if (items[index].product == null) {
      return;
    }

    // Add the next blank item.
    setState(() {
      items.add(InvoiceItem(qty: 1));
    });

    final newIndex = items.length - 1;

    // Wait until the new row has been rendered.
    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    // Open product selection for the new row.
    await selectProduct(newIndex);
  }

  // ------------------------------------------------------------
  // LAST INVOICE
  // ------------------------------------------------------------

  Future<void> lastInvoice(int centerno) async {
    try {
      final res = await InvoiceService().lastInvoice(centerno);

      if (!mounted) return;

      setState(() {
        lastinvoiceno = res;
      });
    } catch (e) {
      debugPrint("Last invoice error: $e");
    }
  }

  // ------------------------------------------------------------
  // CENTER
  // ------------------------------------------------------------

  Future<void> getcenter() async {
    try {
      final res = await InvoiceService().getCenter(centerNo: widget.centerno);

      if (!mounted) return;

      setState(() {
        centers = res;
      });
    } catch (e) {
      debugPrint("Center error: $e");
    }
  }

  // ------------------------------------------------------------
  // SAVE / UPDATE INVOICE
  // ------------------------------------------------------------

  Future<void> saveInvoice() async {
    if (selectedCustomer == null) {
      _showMessage("Select Customer");
      return;
    }

    if (items.isEmpty) {
      _showMessage("Add at least one product");
      return;
    }

    // Make sure every item has a product.
    for (final item in items) {
      if (item.product == null) {
        _showMessage("Please select product for all rows");
        return;
      }

      //if (item.qty <= 0) {
      //  _showMessage("Quantity must be greater than zero");
      //  return;
      //}
    }

    final lines = items.map((e) {
      return InvoiceLine(
        productno: e.product!.productno,
        productqty: e.qty,
        productrate: e.rate,
        total: e.amount,
      );
    }).toList();

    final invoice = Invoice(
      invoiceno: widget.invoiceNo,
      invoicedate: invoiceDate,
      custno: selectedCustomer!.custno,
      centerno: widget.centerno,
      total: grandTotal,
      remarks: remarksController.text,
      details: lines,
    );

    setState(() {
      isSaving = true;
    });

    try {
      bool success;

      if (isEdit) {
        success = await InvoiceService().updateInvoice(invoice);
      } else {
        success = await InvoiceService().insertInvoice(invoice);
      }

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? "Invoice Updated" : "Invoice Saved")),
        );

        Navigator.pop(context, true);
      } else {
        _showMessage("Unable to save invoice");
      }
    } catch (e) {
      if (!mounted) return;

      _showMessage("Error saving invoice: $e");
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // LOAD EXISTING INVOICE
  // ------------------------------------------------------------

  Future<void> loadInvoice() async {
    setState(() {
      isLoading = true;
    });

    try {
      final invoice = await InvoiceService().getInvoice(
        invoiceNo: widget.invoiceNo!,
        centerNo: widget.centerno,
      );

      final customers = await InvoiceService().getCustomers();

      final products = await InvoiceService().getProducts();

      if (!mounted) return;

      setState(() {
        invoiceDate = invoice.invoicedate;

        remarksController.text = invoice.remarks;

        selectedCustomer = customers.firstWhere(
          (c) => c.custno == invoice.custno,
        );

        items.clear();

        for (final line in invoice.details) {
          final product = products.firstWhere(
            (p) => p.productno == line.productno,
          );

          items.add(
            InvoiceItem(
              product: product,
              qty: line.productqty,
              rate: line.productrate,
            ),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;

      _showMessage("Unable to load invoice: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // SHARE PDF
  // ------------------------------------------------------------

  Future<void> _shareInvoicePdf() async {
    if (widget.invoiceNo == null) {
      _showMessage("Please save invoice before sharing");
      return;
    }

    if (selectedCustomer == null) {
      _showMessage("Please select customer");
      return;
    }

    if (items.isEmpty) {
      _showMessage("Please add at least one product");
      return;
    }

    try {
      final pdfBytes = await InvoicePdfService.generateInvoicePdf(
        invoiceNo: widget.invoiceNo!,
        invoiceDate: invoiceDate,
        customer: selectedCustomer!,
        items: items,
      );

      await InvoiceShareService.shareInvoicePdf(
        pdfBytes: pdfBytes,
        invoiceNo: widget.invoiceNo!,
      );
    } catch (e) {
      _showMessage("Unable to share invoice: $e");
    }
  }

  // ------------------------------------------------------------
  // PRINT
  // ------------------------------------------------------------

  Future<void> _printInvoice() async {
    if (widget.invoiceNo == null) {
      _showMessage("Please save invoice before printing");
      return;
    }

    if (selectedCustomer == null) {
      _showMessage("Please select customer");
      return;
    }

    if (items.isEmpty) {
      _showMessage("Please add at least one product");
      return;
    }

    final pdfBytes = await InvoicePdfService.generateInvoicePdf(
      invoiceNo: widget.invoiceNo!,
      invoiceDate: invoiceDate,
      customer: selectedCustomer!,
      items: items,
    );

    await InvoicePrintService.printInvoice(pdfBytes);
  }

  // ------------------------------------------------------------
  // DATE
  // ------------------------------------------------------------

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: invoiceDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        invoiceDate = date;
      });
    }
  }

  // ------------------------------------------------------------
  // CUSTOMER
  // ------------------------------------------------------------

  Future<void> selectCustomer() async {
    final Customer? customer = await showDialog<Customer>(
      context: context,
      builder: (_) => const CustomerSearchDialog(),
    );

    if (customer != null) {
      setState(() {
        selectedCustomer = customer;
      });
    }
  }

  // ------------------------------------------------------------
  // PRODUCT
  // ------------------------------------------------------------

  Future<void> selectProduct(int index) async {
    final Product? product = await showDialog<Product>(
      context: context,
      builder: (_) => const ProductSearchDialog(),
    );

    if (product != null) {
      setState(() {
        items[index].product = product;

        // Automatically use sale rate.
        items[index].rate = product.salerate;

        // Default quantity.
        if (items[index].qty == 0) {
          items[index].qty = 1;
        }

        // Request Qty focus for this row.
        _qtyFocusRequest++;
      });
    }
  }
  // ------------------------------------------------------------
  // TOTAL
  // ------------------------------------------------------------

  double get grandTotal {
    return items.fold(0, (sum, item) => sum + item.amount);
  }

  // ------------------------------------------------------------
  // ADD ITEM
  // ------------------------------------------------------------

  void addItem() {
    setState(() {
      items.add(InvoiceItem());
    });
  }

  // ------------------------------------------------------------
  // REMOVE ITEM
  // ------------------------------------------------------------

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  // ------------------------------------------------------------
  // REFRESH TOTAL
  // ------------------------------------------------------------

  void refreshTotal() {
    if (mounted) {
      setState(() {});
    }
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ------------------------------------------------------------
  // DISPOSE
  // ------------------------------------------------------------

  @override
  void dispose() {
    remarksController.dispose();

    for (final node in _qtyFocusNodes.values) {
      node.dispose();
    }

    super.dispose();
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildInvoiceHeader() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Invoice number / center / date
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEdit ? "Invoice No : ${widget.invoiceNo}" : "New Invoice",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                if (centers != null)
                  Text(
                    centers!.centername,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: pickDate,
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(df.format(invoiceDate)),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    "Last Invoice: ${lastinvoiceno ?? '-'}",
                    textAlign: TextAlign.end,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Customer
            InkWell(
              onTap: selectCustomer,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Customer",
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                  isDense: true,
                ),
                child: Text(
                  selectedCustomer?.customername ?? "Select Customer",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT HEADER
  // ------------------------------------------------------------

  Widget _buildProductHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 30,
            child: Text("#", style: TextStyle(fontWeight: FontWeight.bold)),
          ),

          Expanded(
            flex: 5,
            child: Text(
              "PRODUCT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(
            width: 65,
            child: Text(
              "QTY",
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(width: 10),

          SizedBox(
            width: 85,
            child: Text(
              "RATE",
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          SizedBox(width: 10),

          SizedBox(
            width: 95,
            child: Text(
              "AMOUNT",
              textAlign: TextAlign.right,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCTS
  // ------------------------------------------------------------

  Widget _buildProducts() {
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: const Text(
          "No Products Added",
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        // ==========================================================
        // MOBILE
        // ==========================================================

        if (isMobile) {
          return Column(
            children: [
              // --------------------------------------------------------
              // MOBILE HEADER
              // --------------------------------------------------------
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(
                        '#',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Text(
                        'PRODUCT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 55,
                      child: Text(
                        'QTY',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 65,
                      child: Text(
                        'RATE',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: 72,
                      child: Text(
                        'AMOUNT',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(width: 28),
                  ],
                ),
              ),

              // --------------------------------------------------------
              // ITEMS
              // --------------------------------------------------------
              ...List.generate(items.length, (index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: InvoiceItemRow(
                        key: ValueKey(index),
                        item: items[index],
                        qtyFocusRequest: _qtyFocusRequest,
                        onDelete: () => removeItem(index),
                        onSelectProduct: () {
                          selectProduct(index);
                        },
                        onChanged: refreshTotal,
                        onNextItem: () {
                          _completeCurrentItem(index);
                        },
                      ),
                    ),
                  ],
                );
              }),
            ],
          );
        }

        // ==========================================================
        // DESKTOP / TABLET
        // ==========================================================

        return Column(
          children: [
            // ------------------------------------------------------
            // HEADER
            // ------------------------------------------------------
            Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 30,
                    child: Text(
                      '#',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'PRODUCT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 65,
                    child: Text(
                      'QTY',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 80,
                    child: Text(
                      'RATE',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 90,
                    child: Text(
                      'AMOUNT',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 40),
                ],
              ),
            ),

            // ------------------------------------------------------
            // ITEMS
            // ------------------------------------------------------
            ...List.generate(items.length, (index) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 30,
                    child: Container(
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: Colors.grey.shade300),
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),

                  Expanded(
                    child: InvoiceItemRow(
                      key: ValueKey(index),
                      item: items[index],
                      qtyFocusRequest: _qtyFocusRequest,
                      onDelete: () => removeItem(index),
                      onSelectProduct: () {
                        selectProduct(index);
                      },
                      onChanged: refreshTotal,
                      onNextItem: () {
                        _completeCurrentItem(index);
                      },
                    ),
                  ),
                ],
              );
            }),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // TOTAL CARD
  // ------------------------------------------------------------

  Widget _buildTotalCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Grand Total",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            Text(
              "₹${grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // REMARKS
  // ------------------------------------------------------------

  Widget _buildRemarks() {
    return TextField(
      controller: remarksController,
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: "Remarks",
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Invoice" : "New Invoice"),
        actions: [
          if (isEdit)
            IconButton(
              onPressed: () {
                // Delete invoice will be implemented separately.
              },
              icon: const Icon(Icons.delete),
              tooltip: "Delete",
            ),

          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Print",
            onPressed: _printInvoice,
          ),

          IconButton(
            icon: const Icon(Icons.share),
            tooltip: "WhatsApp / Share",
            onPressed: _shareInvoicePdf,
          ),
        ],
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(10),
                children: [
                  // HEADER
                  _buildInvoiceHeader(),

                  const SizedBox(height: 10),

                  // PRODUCTS
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  "Invoice Items",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              ElevatedButton.icon(
                                onPressed: addItem,
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text("Add Item"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          _buildProducts(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // REMARKS
                  _buildRemarks(),

                  const SizedBox(height: 10),

                  // TOTAL
                  _buildTotalCard(),

                  const SizedBox(height: 90),
                ],
              ),
            ),

      // SAVE BUTTON
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isSaving ? null : saveInvoice,
              icon: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),

              label: Text(
                isSaving
                    ? "Saving..."
                    : isEdit
                    ? "UPDATE INVOICE"
                    : "SAVE INVOICE",
              ),

              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
