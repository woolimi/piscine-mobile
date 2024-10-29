import 'package:flutter/material.dart';
import 'dart:math' as math;

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

  String searchText = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onSubmit(String text) {
    setState(() {
      searchText = text;
    });
  }

  void _onGeoLocationPressed(String text) {
    setState(() {
      if (text.isEmpty) {
        searchText = 'Geolocation';
      } else {
        searchText = text;
      }
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
                  _onGeoLocationPressed(_controller.text);
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
                      Text(e,
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
                      Text(searchText,
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold)),
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
