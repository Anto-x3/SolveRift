import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import 'history.dart';
import 'keyboard/custom_keyboard_button.dart';

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
  TextEditingController _resultController = TextEditingController();
  MathFieldEditingController _mathController = MathFieldEditingController();
  List<String> operationsList = [];
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3498db),
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => History(operations: operationsList),
                ),
              );
            },
            icon: const Icon(Icons.access_time),
          ),
        ],
        toolbarHeight: 110.0,
      ),
      backgroundColor: Color(0xFFecf0f1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 16),
          if (_image != null) Image.file(File(_image!.path)),
          SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
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
                print('Input changed: $value');
              },
              autofocus: true,
            ),
          ),
          SizedBox(height: 90),
          Container(
            color: Color(0xFFecf0f1),
            child: Center(
              child: Math.tex(
                _resultController.text,
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openCamera();
        },
        tooltip: 'Open Camera',
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void calculateResult(String expression) {
    try {
      expression = expression.replaceAllMapped(
        RegExp(
          r'\\frac{([^{}]+)}{([^{}]+)}|\\cdot|\\sqrt{([^{}]+)}|\\sin^{-1}\(([^)]+)\)|\\cos\^{-1}\(([^)]+)\)|\\tan\^{-1}\(([^)]+)\)|\\sin\(([^)]+)\)|\\cos\(([^)]+)\)|\\tan\(([^)]+)\)|\\ln\(([^)]+)\)',
        ),
        (Match match) {
          if (match.group(0) == r'\cdot') {
            return '*';
          } else if (match.group(0)!.startsWith(r'\frac')) {
            return '(${match.group(1)})/(${match.group(2)})';
          } else if (match.group(0)!.startsWith(r'\sqrt')) {
            return 'sqrt(${match.group(3)})';
          } else if (match.group(0)!.startsWith(r'\sin^{-1}(')) {
            return 'asin(${match.group(4)})';
          } else if (match.group(0)!.startsWith(r'\cos^{-1}')) {
            return 'acos(${match.group(4)})';
          } else if (match.group(0)!.startsWith(r'\tan^{-1}')) {
            return 'atan(${match.group(4)})';
          } else if (match.group(0)!.startsWith(r'\sin')) {
            return 'sin(${match.group(7)})';
          } else if (match.group(0)!.startsWith(r'\cos')) {
            return 'cos(${match.group(8)})';
          } else if (match.group(0)!.startsWith(r'\tan')) {
            return 'tan(${match.group(9)})';
          } else if (match.group(0)!.startsWith(r'\ln')) {
            return 'log(e, ${match.group(10)})';
          }
          return '';
        },
      );

      double result = _evaluateMathExpression(expression);
      String operation = '$expression = $result';

      setState(() {
        _resultController.text = 'Result: $result';
        operationsList.add(operation);
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

  void _openCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      ImageCropper cropper = ImageCropper();
      final croppedImage = await cropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Edit Photo',
              toolbarColor: Color(0xFF3498db),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Edit Photor',
          ),
        ],
      );

      setState(() {
        _image = croppedImage != null ? XFile(croppedImage.path) : null;
      });
    }
  }
}
