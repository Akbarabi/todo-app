import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/widget/task_calendar.dart';

class CalenderScreen extends StatefulWidget {
  const CalenderScreen({super.key, required this.tasks});

  final List<Task> tasks;

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  List<Task> _getEventsForDay(DateTime day) {
    return widget.tasks.where((task) {
      return task.date != null &&
          task.date!.year == day.year &&
          task.date!.month == day.month &&
          task.date!.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2050, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ListView.builder(
              itemCount: _getEventsForDay(_focusedDay).length,
              itemBuilder: (context, index) {
                final task = _getEventsForDay(_focusedDay)[index];
                return TaskCalendar(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildTaskList() {
  //   final events = _getEventsForDay(_focusedDay);

  //   if (events.isEmpty) {
  //     return const Center(child: Text('No events found'));
  //   } else {
  //     return ListView.builder(
  //       itemCount: events.length,
  //       itemBuilder: (context, index) {
  //         final task = events[index];
  //         return Card(
  //           child: ListTile(
  //             title: Text(task.name),
  //             subtitle: Text(task.description),
  //           ),
  //         );
  //       },
  //     );
  //   }
  // }
}
