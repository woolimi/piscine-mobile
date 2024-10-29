import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Calculator', style: TextStyle(color: Colors.white)),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: CalculatorBody(),
      ),
    );
  }
}

class CalculatorBody extends StatefulWidget {
  @override
  _CalculatorBodyState createState() => _CalculatorBodyState();
}

class _CalculatorBodyState extends State<CalculatorBody> {
  final TextEditingController expressionController =
      TextEditingController(text: '0');
  final TextEditingController resultController =
      TextEditingController(text: '0');

  String expression = '';

  void onButtonPressed(String text) {
    setState(() {
      if (text == 'C') {
        // Clear the last character
        if (expression.isNotEmpty) {
          expression = expression.substring(0, expression.length - 1);
        }
      } else if (text == 'AC') {
        // Clear all
        expression = '';
        resultController.text = '0';
      } else if (text == '=') {
        // Calculate result
        try {
          final parser = Parser();
          final exp = parser.parse(expression);
          final evaluator = ContextModel();
          final result = exp.evaluate(EvaluationType.REAL, evaluator);
          resultController.text = result.toString();
        } catch (e) {
          resultController.text = 'Invalid expression';
        }
      } else {
        // Append the button text to the expression
        expression += text;
      }

      // Update the expression controller text
      expressionController.text = expression.isEmpty ? '0' : expression;
    });
  }

  Color getColorForText(String text, context) {
    if (['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '.', '00']
        .contains(text)) {
      return Theme.of(context).primaryColor;
    } else if (text == 'C' || text == 'AC') {
      return Colors.red;
    } else {
      return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxButtonSectionHeight =
        screenHeight * 0.5; // Limit button section to 50% of screen height

    return Column(
      children: [
        // Expanded section for expression and result
        Expanded(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextField(
                    controller: expressionController,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: resultController,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                    ),
                    readOnly: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors
              .grey[200], // Optional: background color for the button section
          constraints: BoxConstraints(
            maxHeight: maxButtonSectionHeight, // Limit the maximum height
          ),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              constraints: BoxConstraints(
                maxHeight: maxButtonSectionHeight, // Limit the maximum height
                maxWidth: double.infinity, // Full width of the screen
              ),
              child: Table(
                defaultColumnWidth:
                    FlexColumnWidth(), // Evenly distribute columns
                children: [
                  ['7', '8', '9', 'C', 'AC'],
                  ['4', '5', '6', '+', '-'],
                  ['1', '2', '3', '*', '/'],
                  ['0', '.', '00', '=', '']
                ].map((row) {
                  return TableRow(
                    children: row.map((text) {
                      return text == ''
                          ? Container()
                          : Container(
                              height: maxButtonSectionHeight /
                                  5, // Adjusts the height for each row
                              child: TextButton(
                                style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    )),
                                onPressed: () => onButtonPressed(text),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: getColorForText(text, context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
