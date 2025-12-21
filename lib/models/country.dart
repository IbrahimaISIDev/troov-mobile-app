class Country {
  final String id;
  final String name;
  final String code;
  final String flagUrl;
  final String currency;

  Country({
    required this.id,
    required this.name,
    required this.code,
    required this.flagUrl,
    required this.currency,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      flagUrl: json['flagUrl'] ?? '', // Handle null
      currency: json['currency'],
    );
  }
}
