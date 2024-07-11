import 'package:flutter/material.dart';
// import 'package:todo_app/screens/home_screen.dart';
import 'package:todo_app/models/task.dart';

class OpenTask extends StatelessWidget {
  const OpenTask({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: [
        //   IconButton(
        //       onPressed: () => Navigator.pop(context,
        //           MaterialPageRoute(builder: (context) => const HomeScreen())),
        //       icon: const Icon(Icons.arrow_back)),
        // ],
        centerTitle: true,
        title: const Text('Open Task'),
      ),
      body: Column(
        children: [
          const Divider(
            color: Colors.black,
            height: 1,
            thickness: 1,
          ),
          Text('Task Name: ${task.name}'),
          const Divider(
            color: Colors.black,
            height: 1,
            thickness: 1,
          ),
          Text('Description: ${task.description}'),
        ],
      ),
    );
  }
}
