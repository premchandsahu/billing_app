import 'package:billing_app/models/centers.dart';
import 'package:billing_app/screens/menu_screen.dart';
import 'package:billing_app/widgets/center_search_dialog.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Centers? selectedCenter;

  String? selectedCentername;
  int selectedcenterno = 1;
  @override
  void initState() {
    super.initState();
  }

  Future<void> selectCenter() async {
    final Centers? centers = await showDialog<Centers>(
      context: context,
      builder: (_) => const CentersSearchDialog(),
    );

    if (centers != null) {
      setState(() {
        selectedCenter = centers;
        selectedCentername = centers.centername;
        selectedcenterno = centers.centerno;
      });
    }
  }

  Future<void> letsbBegin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        // builder: (_) => InvoiceListScreen(centerno: selectedcenterno),
        builder: (_) => MainMenu(centerno: selectedcenterno),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select center"), centerTitle: true),
      body: InkWell(
        onTap: selectCenter,
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: "Center",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
          child: Column(
            children: [
              Text(
                selectedCentername ?? "All Center",
                style: TextStyle(
                  color: selectedCenter == null ? Colors.grey : Colors.black,
                ),
              ),
              SizedBox(height: 120),
              ElevatedButton.icon(
                onPressed: letsbBegin,
                icon: const Icon(Icons.skip_next),
                label: const Text("Proceed"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
