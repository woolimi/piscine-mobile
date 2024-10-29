import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CenteredToggleButton(),
      ),
    );
  }
}

class CenteredToggleButton extends StatefulWidget {
  @override
  State<CenteredToggleButton> createState() => _CenteredToggleButtonState();
}

class _CenteredToggleButtonState extends State<CenteredToggleButton> {
  String displayedText = 'A simple text';
  bool isHelloWorld = false;
  void _toggleText() {
    setState(() {
      isHelloWorld = !isHelloWorld;
      if (isHelloWorld) {
        displayedText = 'Hello World';
      } else {
        displayedText = 'A simple text';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayedText,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20), // Add some space between text and button
          ElevatedButton(
            onPressed: _toggleText,
            child: const Text('Click me'),
          ),
        ],
      ),
    );
  }
}
