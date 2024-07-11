import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/widget/open_task.dart';

// A StatelessWidget that displays a task tile with a checkbox, title, and description.
class TaskTile extends StatefulWidget {
  // Constructor for the TaskTile widget.
  const TaskTile(
      {super.key,
      required this.task,
      required this.toggleCheckboxState,
      this.maxTitleLength = 20,
      this.maxDecsLength = 50});

  // The task to be displayed in the tile.
  final Task task;

  // A function to toggle the checkbox state.
  final void Function(bool?) toggleCheckboxState;

  // The maximum length for the title.
  final int maxTitleLength;

  // The maximum length for the description.
  final int maxDecsLength;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  // Builds the TaskTile widget.
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              // Adds a box shadow to the container.
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26,
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 4))
              ]),
          child: SizedBox(
            child: ListTile(
              // Displays the task title, limited to maxTitleLength characters.
              title: Text(
                limitText(widget.task.name, widget.maxTitleLength),
                style: TextStyle(
                  // Strikethrough the title if the task is done.
                  fontSize: 20,
                  decoration:
                      widget.task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              // Displays the task description, limited to maxDecsLength characters.
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    limitText(widget.task.description, widget.maxDecsLength),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy')
                        .format(widget.task.date ?? DateTime.now()),
                  ),
                ],
              ),
              // A checkbox to mark the task as done or not done.
              trailing: Checkbox(
                value: widget.task.isDone,
                onChanged: widget.toggleCheckboxState,
              ),
              // Navigates to the OpenTask page when the tile is tapped.
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenTask(task: widget.task),
                  ),
                );
              },
            ),
          ),
        ));
  }
}

// Limits a text to a specified length, appending '...' if it exceeds the length.
String limitText(String text, int limit) {
  if (text.length > limit) {
    return '${text.substring(0, limit)}...';
  } else {
    return text;
  }
}
