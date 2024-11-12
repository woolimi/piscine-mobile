import 'package:flutter/material.dart';
import 'package:medium_weather_app/data/current_weather_data.dart';
import 'package:medium_weather_app/data/location_data.dart';

class CurrentWeatherSection extends StatelessWidget {
  const CurrentWeatherSection({
    super.key,
    required LocationData location,
    required CurrentWeatherData? currentWeatherData,
  })  : _location = location,
        _currentWeatherData = currentWeatherData;

  final LocationData _location;
  final CurrentWeatherData? _currentWeatherData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
          child: Column(children: [
        if (_location.city.isNotEmpty)
          Column(children: [
            Text(_location.city),
            Text(_location.region),
            Text(_location.country),
          ]),
        if (_currentWeatherData != null)
          Column(children: [
            Text(_currentWeatherData!.weather),
            Text(_currentWeatherData!.temperature.toString()),
            Text(_currentWeatherData!.windSpeed.toString()),
          ])
      ])),
    );
  }
}
