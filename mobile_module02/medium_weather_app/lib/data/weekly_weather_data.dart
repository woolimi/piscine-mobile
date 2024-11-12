class DailyWeatherData {
  final String date;
  final String weather;
  final double maxTemperature;
  final double minTemperature;

  DailyWeatherData({
    required this.date,
    required this.weather,
    required this.maxTemperature,
    required this.minTemperature,
  });
}

class WeeklyWeatherData {
  final double latitude;
  final double longitude;
  final List<DailyWeatherData> daily;

  WeeklyWeatherData({
    required this.latitude,
    required this.longitude,
    required this.daily,
  });
}
