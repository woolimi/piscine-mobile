import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medium_weather_app/data/current_weather_data.dart';
import 'package:medium_weather_app/data/today_weather_data.dart';
import 'package:medium_weather_app/data/weekly_weather_data.dart';

class OpenMeteoService {
  Map _weatherMap = {
    0: 'Sunny',
    1: 'Mainly Clear',
    2: 'Partly Sunny',
    3: 'Overcast',
    45: 'Foggy',
    48: 'Foggy',
    51: 'Light Drizzle',
    53: 'Moderate Drizzle',
    55: 'Dense Drizzle',
    56: 'Light Freezing Drizzle',
    57: 'Dense Freezing Drizzle',
    61: 'Slightly Rainy',
    63: 'Moderately Rainy',
    65: 'Heavily Rainy',
    66: 'Light Freezing Rainy',
    67: 'Heavy Freezing Rainy',
    71: 'Slightly Snowy',
    73: 'Moderately Snowy',
    75: 'Heavily Snowy',
    77: 'Snowy',
    80: 'Slight Rain Shower',
    81: 'Moderate Rain Shower',
    82: 'Violent Rain Shower',
    85: 'Slight Snow Shower',
    86: 'Violent Snow Shower',
    95: 'Slight Thunderstorm',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail'
  };

  Future<List<dynamic>> fetchSuggestions(
      String keyword, List<dynamic> currentSuggestions) async {
    if (keyword.isEmpty) {
      return [];
    }
    if (currentSuggestions.isNotEmpty) {
      final firstSuggestion = currentSuggestions[0];
      if (keyword ==
          '${firstSuggestion['name']}, ${firstSuggestion['country']}') {
        return currentSuggestions;
      }
    }

    final response = await http.get(Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$keyword'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['results'] ?? [])
          .where((d) => d['admin1'] != null && d['admin2'] != null)
          .take(6)
          .toList();
    }

    return Future.error(
        "The service connection is lost, please check your internet connection or try again later");
  }

  Future<CurrentWeatherData> fetchCurrentWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,weather_code,wind_speed_10m'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return CurrentWeatherData(
        latitude: data['latitude'],
        longitude: data['longitude'],
        temperature: data['current']['temperature_2m'],
        weather: _weatherMap[data['current']['weather_code']],
        windSpeed: data['current']['wind_speed_10m'],
      );
    }

    return Future.error(
        "The service connection is lost, please check your internet connection or try again later");
  }

  Future<TodayWeatherData> fetchTodayWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,weather_code,wind_speed_10m&forecast_days=1'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return TodayWeatherData(
          latitude: data['latitude'],
          longitude: data['longitude'],
          hourly: data['hourly']['time']
              .asMap()
              .entries
              .map<HourlyWeatherData>((entry) {
            int index = entry.key;
            String time = entry.value;
            return HourlyWeatherData(
                time: time,
                temperature: data['hourly']['temperature_2m'][index],
                weather: _weatherMap[data['hourly']['weather_code'][index]],
                windSpeed: data['hourly']['wind_speed_10m'][index]);
          }).toList());
    }

    return Future.error(
        "The service connection is lost, please check your internet connection or try again later");
  }

  Future<WeeklyWeatherData> fetchWeeklyWeather(
      double latitude, double longitude) async {
    final response = await http.get(Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&daily=weathercode,temperature_2m_max,temperature_2m_min'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return WeeklyWeatherData(
          latitude: data['latitude'],
          longitude: data['longitude'],
          daily: data['daily']['time']
              .asMap()
              .entries
              .map<DailyWeatherData>((entry) {
            int index = entry.key;
            String time = entry.value;

            return DailyWeatherData(
                date: time,
                maxTemperature: data['daily']['temperature_2m_max'][index],
                minTemperature: data['daily']['temperature_2m_min'][index],
                weather: _weatherMap[data['daily']['weathercode'][index]]);
          }).toList());
    }
    return Future.error(
        "The service connection is lost, please check your internet connection or try again later");
  }
}
