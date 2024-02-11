import 'package:flutter/material.dart';

class History extends StatelessWidget {
  final List<String> operations;

  const History({Key? key, required this.operations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3498db),
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: operations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(operations[index]),
          );
        },
      ),
    );
  }
}
