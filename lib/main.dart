import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:math_keyboard/math_keyboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

import 'history.dart';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'img/title_appbar.png',
                width: 200,
                height: 200,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF3498db),
              ),
              child: Center(
                child: Image.asset(
                  'img/logo_appbar.png',
                  width: 550,
                  height: 550,
                    fit: BoxFit.cover
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help center'),
              onTap: () {
                //
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About us'),
              onTap: () {},
            ),
            Spacer(),
            Divider(),
            ListTile(
              title: Text('© Copyright by SolveRift 2024'),
            ),
          ],
        ),
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
        onPressed: () async {
          _openCamera();
        },
        tooltip: 'Open Camera',
        child: Icon(Icons.camera_alt),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  double _evaluateMathExpression(String expression) {
    Parser p = Parser();
    Expression exp = p.parse(expression);
    double result = exp.evaluate(EvaluationType.REAL, ContextModel());

    if ((result - result.toInt()).abs() < 1e-12) {
      return result.toInt().toDouble();
    }

    return result;
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
      String formattedResult = _formatResult(result);

      String operation = '$expression = $formattedResult';

      setState(() {
        _resultController.text = 'Result: $formattedResult';
        operationsList.add(operation);
      });
    } catch (e) {
      setState(() {
        _resultController.text = 'Errors in calculation';
      });
    }
  }

  String _formatResult(double result) {
    if ((result - result.toInt()).abs() < 1e-12) {
      return result.toInt().toString();
    }

    return result.toStringAsFixed(5).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
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
              lockAspectRatio: false
          ),
          IOSUiSettings(
            title: 'Edit Photo',
          ),
        ],
      );

      setState(() {
        _image = croppedImage != null ? XFile(croppedImage.path) : null;
      });
    }
  }
}
