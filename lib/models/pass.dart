class Pass {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final bool isPopular;
  final String? passSecret;
  final String? homeZone;
  final String? destinationZone;

  Pass({
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
    this.passSecret,
    this.homeZone,
    this.destinationZone,
  });

  factory Pass.fromMap(Map<String, dynamic> map) {
    return Pass(
      title: map['pass_type'] ?? '',
      price: map['price'] ?? '',
      duration: map['duration'] ?? 'day',
      features: List<String>.from(map['features'] ?? []),
    );
  }
} 