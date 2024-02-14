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
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompleteOperationScreen(
                    completeOperation: operations[index],
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Text(
                  operations[index].split('=')[0].trim().replaceAll('*', '·'),
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CompleteOperationScreen extends StatelessWidget {
  final String completeOperation;

  const CompleteOperationScreen({Key? key, required this.completeOperation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF3498db),
        title: Text('Complete Operation'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Complete Operation:',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                completeOperation.replaceAll('*', '·'),
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 8.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Back'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
