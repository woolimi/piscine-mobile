import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

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
  final TextEditingController _controller = TextEditingController();

  String _locationMessage = '';
  String _errorMessage = '';
  List<dynamic> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onGeoLocation();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _onGeoLocation() async {
    try {
      Position position = await _getGeoPosition();
      String cityName =
          await _getCityName(position.latitude, position.longitude);

      setState(() {
        _locationMessage = cityName;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _locationMessage = '';
        _errorMessage = e.toString();
      });
    }
  }

  Future<String> _getCityName(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isEmpty) {
      return Future.error("Error while fetching city name");
    }
    Placemark place = placemarks[0];
    String cityName = place.locality ?? '';
    if (cityName.isEmpty) {
      return Future.error("Error while getting city name");
    }
    return cityName;
  }

  Future<Position> _getGeoPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error(
          'Geolocation is not available, please enable it in your App settings');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(
            'Geolocation is not available, please enable it in your App settings');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Geolocation is not available, please enable it in your App settings');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }
    if (_suggestions.isNotEmpty) {
      final firstSuggestion = _suggestions[0];
      if (query ==
          '${firstSuggestion['name']}, ${firstSuggestion['country']}') {
        return;
      }
    }

    final response = await http.get(Uri.parse(
        'https://geocoding-api.open-meteo.com/v1/search?name=$query'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _suggestions = (data['results'] ?? []).take(6).toList();
      });
    } else {
      setState(() {
        _suggestions = [];
        _errorMessage =
            "The service connection is lost, please check your internet connection or try again later";
      });
    }
  }

  Future<dynamic> _fetchWeatherByPosition(
      double latitude, double longitude) async {
    print("fetchWeather");
    // TODO: Fetch weather data from Open Meteo API
    return "done";
  }

  void _onSubmit(dynamic place) async {
    if (_controller.text.isNotEmpty && _suggestions.isEmpty) {
      return setState(() {
        _locationMessage = '';
        _errorMessage =
            'Could not find any result for the supplied address or coordinates.';
      });
    }
    if (place == null) {
      return _onGeoLocation();
    }
    _controller.text = '${place['name']}, ${place['country']}';
    final response =
        await _fetchWeatherByPosition(place['latitude'], place['longitude']);

    // TODO: Show result on screen
    setState(() {
      _locationMessage = place['name'];
      _errorMessage = '';
      _suggestions = [];
    });
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
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Search location...',
                  hintStyle: TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                ),
                onChanged: _fetchSuggestions,
                onSubmitted: (String text) {
                  _onSubmit(_suggestions.isEmpty ? null : _suggestions[0]);
                },
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
                  _onSubmit(_suggestions.isEmpty ? null : _suggestions[0]);
                },
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: ['Currently', 'Today', 'Weekly']
                .map((e) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_errorMessage.isEmpty)
                            Text(e,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 32, fontWeight: FontWeight.bold)),
                          if (_errorMessage.isEmpty)
                            Text(_locationMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                )),
                          if (_errorMessage.isNotEmpty)
                            Text(_errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                ))
                        ],
                      ),
                    ))
                .toList(),
          ),
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
        ),
      ),
    );
  }
}
