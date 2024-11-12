class LocationData {
  final String city;
  final String region;
  final String country;
  final double? latitude;
  final double? longitude;

  LocationData({
    required this.city,
    required this.region,
    required this.country,
    this.latitude,
    this.longitude,
  });
}
