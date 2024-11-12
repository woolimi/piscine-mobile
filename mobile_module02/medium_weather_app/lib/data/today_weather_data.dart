class HourlyWeatherData {
  final String time;
  final double temperature;
  final String weather;
  final double windSpeed;

  HourlyWeatherData({
    required this.time,
    required this.temperature,
    required this.weather,
    required this.windSpeed,
  });
}

class TodayWeatherData {
  final double latitude;
  final double longitude;
  final List<HourlyWeatherData> hourly;

  TodayWeatherData({
    required this.latitude,
    required this.longitude,
    required this.hourly,
  });
}
