import 'package:flutter/material.dart';
import 'package:medium_weather_app/data/location_data.dart';
import 'package:medium_weather_app/data/weekly_weather_data.dart';

class WeeklyWeatherSection extends StatelessWidget {
  const WeeklyWeatherSection({
    super.key,
    required LocationData location,
    required WeeklyWeatherData? weeklyWeatherData,
  })  : _location = location,
        _weeklyWeatherData = weeklyWeatherData;

  final LocationData _location;
  final WeeklyWeatherData? _weeklyWeatherData;

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
        if (_weeklyWeatherData != null)
          Column(
              children: _weeklyWeatherData!.daily.map((e) {
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(e.date),
                  Text(e.minTemperature.toString()),
                  Text(e.maxTemperature.toString()),
                  Text(e.weather),
                ]);
          }).toList())
      ])),
    );
  }
}
