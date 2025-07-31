class ServiceLocation {
  final double latitude;
  final double longitude;
  final String address;
  final double radius; // rayon de service en km

  ServiceLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.radius = 10.0,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
      address: json["address"],
      radius: json["radius"]?.toDouble() ?? 10.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'radius': radius,
    };
  }
}


