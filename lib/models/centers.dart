class Centers {
  final int centerno;
  final String centername;

  Centers({required this.centerno, required this.centername});

  factory Centers.fromJson(Map<String, dynamic> json) {
    return Centers(centerno: json['centerno'], centername: json['centername']);
  }
}
