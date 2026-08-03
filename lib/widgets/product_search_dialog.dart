import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/invoice_service.dart'; // <-- change if your service filename differs

class ProductSearchDialog extends StatefulWidget {
  const ProductSearchDialog({super.key});

  @override
  State<ProductSearchDialog> createState() => _ProductSearchDialogState();
}

class _ProductSearchDialogState extends State<ProductSearchDialog> {
  final InvoiceService service = InvoiceService();

  final TextEditingController _searchController = TextEditingController();

  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    try {
      final products = await service.getProducts();

      setState(() {
        _products = products;
        _filteredProducts = products;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _filterProducts() {
    final search = _searchController.text.trim().toLowerCase();

    setState(() {
      if (search.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((p) {
          return p.name.toLowerCase().contains(search) ||
              p.description.toLowerCase().contains(search);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Product"),

      content: SizedBox(
        width: 450,
        height: 500,

        child: Column(
          children: [
            TextField(
              controller: _searchController,

              decoration: const InputDecoration(
                hintText: "Search Product",
                prefixIcon: Icon(Icons.search),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_filteredProducts.isEmpty) {
      return const Center(child: Text("No products found"));
    }

    return ListView.separated(
      itemCount: _filteredProducts.length,

      separatorBuilder: (_, __) => const Divider(height: 1),

      itemBuilder: (_, index) {
        final product = _filteredProducts[index];

        return ListTile(
          title: Text(product.name),

          subtitle: Text(product.description),

          trailing: Text("₹${product.salerate.toStringAsFixed(2)}"),

          onTap: () {
            Navigator.pop(context, product);
          },
        );
      },
    );
  }
}
