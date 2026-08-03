class Product {
  final int productno;
  final String name;
  final String description;
  final double purchaserate;
  final double salerate;
  final int productcategoryno;
  final double openingstock;

  Product({
    required this.productno,
    required this.name,
    required this.description,
    required this.purchaserate,
    required this.salerate,
    required this.productcategoryno,
    required this.openingstock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productno: json['productno'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      purchaserate: double.tryParse(json['purchaserate'].toString()) ?? 0,
      salerate: double.tryParse(json['salerate'].toString()) ?? 0,
      productcategoryno: json['productcategoryno'] ?? 0,
      openingstock: double.tryParse(json['openingstock'].toString()) ?? 0,
    );
  }
}
