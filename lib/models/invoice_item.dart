import 'product.dart';

class InvoiceItem {
  Product? product;

  double qty;

  double rate;

  InvoiceItem({this.product, this.qty = 1, this.rate = 0});

  double get amount => qty * rate;
}
