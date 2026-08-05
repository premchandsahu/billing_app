import 'package:billing_app/models/receipt.dart';
import 'package:flutter/material.dart';

class PaymentReceipt extends StatefulWidget {
  const PaymentReceipt({super.key});

  @override
  State<PaymentReceipt> createState() => _PaymentReceiptState();
}

class _PaymentReceiptState extends State<PaymentReceipt> {
  Receipt? receipt;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
