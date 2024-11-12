import 'package:flutter/material.dart';

class ErrorSection extends StatelessWidget {
  const ErrorSection({
    super.key,
    required String errorMessage,
  }) : _errorMessage = errorMessage;

  final String _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.red[500])),
            ),
          ],
        ));
  }
}
