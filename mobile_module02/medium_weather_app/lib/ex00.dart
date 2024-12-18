import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

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

  String locationMessage = '';
  String errorMessage = '';

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

  void _onSubmit(String text) {
    setState(() {
      locationMessage = text;
    });
  }

  Future<void> _onGeoLocation() async {
    try {
      Position position = await _getGeoPosition();
      setState(() {
        locationMessage = '${position.latitude} ${position.longitude}';
        errorMessage = '';
      });
    } catch (e) {
      setState(() {
        locationMessage = '';
        errorMessage = e.toString();
      });
    }
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
      print("here");
      return Future.error(
          'Geolocation is not available, please enable it in your App settings');
    }
    return await Geolocator.getCurrentPosition();
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
                onSubmitted: (text) {
                  _onSubmit(text);
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
                  _onGeoLocation();
                },
              ),
            )
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['Currently', 'Today', 'Weekly']
            .map((e) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (errorMessage.isEmpty)
                        Text(e,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 32, fontWeight: FontWeight.bold)),
                      if (errorMessage.isEmpty)
                        Text(locationMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                      if (errorMessage.isNotEmpty)
                        Text(errorMessage,
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
