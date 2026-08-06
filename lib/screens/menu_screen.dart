import 'package:billing_app/screens/invoice_list_screen.dart';
import 'package:billing_app/screens/payment_receipt_list.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  final int centerno;
  const MainMenu({super.key, required this.centerno});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select option"), centerTitle: true),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceListScreen(centerno: widget.centerno),
                ),
              );
            },
            child: Text("Invoice"),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PayementReceiptList()),
              );
            },
            child: Text("Receipts"),
          ),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: Text("Ledger")),
          SizedBox(height: 12),
          ElevatedButton(onPressed: () {}, child: Text("Exit")),
        ],
      ),
    );
  }
}
