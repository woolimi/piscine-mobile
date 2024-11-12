import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:medium_weather_app/data/current_weather_data.dart';
import 'package:medium_weather_app/data/today_weather_data.dart';
import 'package:medium_weather_app/data/weekly_weather_data.dart';
import 'package:medium_weather_app/services/geo_service.dart';
import 'package:medium_weather_app/services/open_meteo_service.dart';
import 'package:medium_weather_app/data/location_data.dart';
import 'package:medium_weather_app/widgets/error_section.dart';
import 'package:medium_weather_app/widgets/current_weather_section.dart';
import "package:medium_weather_app/widgets/today_weather_section.dart";
import "package:medium_weather_app/widgets/weekly_weather_section.dart";

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  FocusNode _searchFocus = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String _errorMessage = '';
  LocationData _location = LocationData(city: '', region: '', country: '');
  List<dynamic> _suggestions = [];
  CurrentWeatherData? _currentWeatherData = null;
  TodayWeatherData? _todayWeatherData = null;
  WeeklyWeatherData? _weeklyWeatherData = null;

  final OpenMeteoService _openMeteoService = OpenMeteoService();
  final GeoService _geoService = GeoService();

  void _onSearchFocus() {
    if (_searchFocus.hasFocus && _searchController.text.isNotEmpty) {
      getSuggestions(_searchController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchFocus.addListener(_onSearchFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onGeoLocation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Placemark> _setLocationByPosition(
      double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isEmpty) {
      return Future.error("Error while fetching location");
    }
    return placemarks[0];
  }

  Future<void> _onGeoLocation() async {
    try {
      Position position = await _geoService.fetchPosition();
      Placemark place =
          await _setLocationByPosition(position.latitude, position.longitude);
      final data =
          await _fetchWeatherByPosition(position.latitude, position.longitude);
      final currentTabIndex = _tabController.index;

      setState(() {
        _errorMessage = '';
        _searchController.text = '';
        _location = LocationData(
          city: place.locality ?? '',
          region: place.administrativeArea ?? '',
          country: place.country ?? '',
          latitude: position.latitude,
          longitude: position.longitude,
        );
        _currentWeatherData = currentTabIndex == 0 ? data : null;
        _todayWeatherData = currentTabIndex == 1 ? data : null;
        _weeklyWeatherData = currentTabIndex == 2 ? data : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _location = LocationData(city: '', region: '', country: '');
      });
    }
  }

  Future<void> getSuggestions(String keyword) async {
    try {
      final suggestions = await _openMeteoService.fetchSuggestions(
        keyword,
        _suggestions,
      );
      setState(() {
        _suggestions = suggestions;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _errorMessage = e.toString();
      });
    }
  }

  Future<dynamic> _fetchWeatherByPosition(
      double latitude, double longitude) async {
    final currentTabIndex = _tabController.index;

    try {
      switch (currentTabIndex) {
        case 0:
          return _openMeteoService.fetchCurrentWeather(latitude, longitude);
        case 1:
          return _openMeteoService.fetchTodayWeather(latitude, longitude);
        case 2:
          return _openMeteoService.fetchWeeklyWeather(latitude, longitude);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _onChangeTab(int index) async {
    try {
      final latitude = _location.latitude;
      final longitude = _location.longitude;
      if (latitude == null || longitude == null) {
        throw 'Could not find any result for the supplied address or coordinates';
      }

      final data = await _fetchWeatherByPosition(latitude, longitude);
      final currentTabIndex = index;

      setState(() {
        _errorMessage = '';
        _suggestions = [];
        _currentWeatherData = currentTabIndex == 0 ? data : null;
        _todayWeatherData = currentTabIndex == 1 ? data : null;
        _weeklyWeatherData = currentTabIndex == 2 ? data : null;
      });
    } catch (e) {
      return setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _onSubmit(dynamic place) async {
    if (_searchController.text.isNotEmpty && _suggestions.isEmpty) {
      return setState(() {
        _errorMessage =
            'Could not find any result for the supplied address or coordinates.';
        _location = LocationData(city: '', region: '', country: '');
      });
    }

    if (place == null) {
      return _onGeoLocation();
    }

    _searchController.text = '${place['name']}, ${place['country']}';
    _searchFocus.unfocus();
    try {
      final data =
          await _fetchWeatherByPosition(place['latitude'], place['longitude']);
      final currentTabIndex = _tabController.index;

      setState(() {
        _errorMessage = '';
        _suggestions = [];
        _currentWeatherData = currentTabIndex == 0 ? data : null;
        _todayWeatherData = currentTabIndex == 1 ? data : null;
        _weeklyWeatherData = currentTabIndex == 2 ? data : null;
        _location = LocationData(
          city: place['name'],
          region: place['admin1'] ?? '',
          country: place['country'],
          latitude: place['latitude'],
          longitude: place['longitude'],
        );
      });
    } catch (e) {
      return setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: TextField(
                cursorColor: Theme.of(context).colorScheme.onPrimary,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                onChanged: getSuggestions,
                onSubmitted: (String text) {
                  _onSubmit(_suggestions.isEmpty ? null : _suggestions[0]);
                },
                focusNode: _searchFocus,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            Container(
              width: 1,
              height: 35,
              color: Theme.of(context).colorScheme.onPrimary,
              margin: EdgeInsets.symmetric(horizontal: 8.0),
            ),
            Transform.rotate(
              angle: 45 * math.pi / 180,
              child: IconButton(
                icon: Icon(Icons.navigation),
                color: Theme.of(context).colorScheme.onPrimary,
                onPressed: () {
                  _onGeoLocation();
                },
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          if (_errorMessage.isEmpty)
            TabBarView(controller: _tabController, children: [
              CurrentWeatherSection(
                  location: _location, currentWeatherData: _currentWeatherData),
              TodayWeatherSection(
                  location: _location, todayWeatherData: _todayWeatherData),
              WeeklyWeatherSection(
                  location: _location, weeklyWeatherData: _weeklyWeatherData)
            ]),
          if (_errorMessage.isNotEmpty)
            ErrorSection(errorMessage: _errorMessage),
          // Positioned widget for full-width suggestion list below AppBar
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ]),
                child: ListView.builder(
                  itemCount: _suggestions.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${suggestion['name']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors
                                    .black, // Adjust color based on theme if necessary
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' ${suggestion['admin1'] ?? suggestion['admin2'] ?? ''}, ${suggestion['country']}',
                              style: TextStyle(
                                  color: Colors
                                      .black87), // Default style for rest of text
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _onSubmit(suggestion);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.all(0),
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.wb_sunny),
              text: 'Currently',
            ),
            Tab(
              icon: Icon(Icons.calendar_today),
              text: 'Today',
            ),
            Tab(
              icon: Icon(Icons.date_range),
              text: 'Weekly',
            ),
          ],
          onTap: (index) {
            _onChangeTab(index);
          },
        ),
      ),
    );
  }
}
