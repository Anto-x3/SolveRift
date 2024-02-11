import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SolveRift Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SolveRift'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MathFieldEditingController _mathController = MathFieldEditingController();
  TextEditingController _resultController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3498db),
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => {},
            icon: const Icon(Icons.access_time),
          ),
        ],
        toolbarHeight: 160.0,
      ),
      backgroundColor: Color(0xFFecf0f1),
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: MathField(
                  controller: _mathController,
                  keyboardType: MathKeyboardType.expression,
                  variables: const ['x', 'y', 'z'],
                  decoration: const InputDecoration(),
                  onChanged: (String value) {
                    print('Input changed: $value');
                  },
                  onSubmitted: (String value) {
                    calculateResult(value);
                  },
                  autofocus: true,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Color(0xFFecf0f1),
              child: Center(
                child: Text(
                  _resultController.text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void calculateResult(String expression) {
    try {
      expression = expression.replaceAllMapped(
        RegExp(r'\\frac{([^{}]+)}{([^{}]+)}|\\cdot'),
            (Match match) {
          if (match.group(0) == r'\cdot') {
            return '*';
          } else if (match.group(0)!.startsWith(r'\frac')) {
            return '(${match.group(1)})/(${match.group(2)})';
          }
          return '';
        },
      );

      double result = _evaluateMathExpression(expression);

      setState(() {
        _resultController.text = 'Result: $result';
      });
    } catch (e) {

      setState(() {
        _resultController.text = 'Errors in calculation';
      });
    }
  }


  double _evaluateMathExpression(String expression) {
    Parser p = Parser();
    Expression exp = p.parse(expression);
    double result = exp.evaluate(EvaluationType.REAL, ContextModel());
    return result;
  }

}
