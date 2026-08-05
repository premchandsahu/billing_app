import 'package:billing_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'screens/invoice_list_screen.dart';

void main() {
  runApp(const BillingApp());
}

class BillingApp extends StatelessWidget {
  const BillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billing App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      // home: const InvoiceListScreen(centerno: 1),
      home: LoginScreen(),
    );
  }
}
