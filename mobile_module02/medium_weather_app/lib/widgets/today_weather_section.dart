import 'package:flutter/material.dart';
import 'package:medium_weather_app/data/today_weather_data.dart';
import 'package:medium_weather_app/data/location_data.dart';
import 'package:intl/intl.dart';

class TodayWeatherSection extends StatelessWidget {
  const TodayWeatherSection(
      {super.key,
      required LocationData location,
      required TodayWeatherData? todayWeatherData})
      : _location = location,
        _todayWeatherData = todayWeatherData;

  final LocationData _location;
  final TodayWeatherData? _todayWeatherData;

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
        if (_todayWeatherData != null)
          Column(
              children: _todayWeatherData!.hourly.map((e) {
            DateTime dateTime = DateTime.parse(e.time);
            String timeString = DateFormat.Hm().format(dateTime);
            return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(timeString),
                  Text('${e.temperature.toString()} °C'),
                  Text('${e.windSpeed.toString()} km/h'),
                  Text(e.weather),
                ]);
          }).toList())
      ])),
    );
  }
}
