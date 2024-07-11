import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/calender_screen.dart';
import 'package:todo_app/widget/task_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final List<Task> tasks = [];
  DateTime? selectedDate;
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Task> filteredTasks = [];
  final Map<int, bool?> _selectedTask = {};
  TextEditingController searchController = TextEditingController();
  late SharedPreferences prefs;

  void _addTask(String taskTitle, String taskDescription, DateTime date) {
    setState(() {
      tasks
          .add(Task(name: taskTitle, description: taskDescription, date: date));
      _filterTasks(searchController.text);
    });
  }
  void _removeSelectedTasks() {
    setState(() {
      tasks.removeWhere((task) => _selectedTask[tasks.indexOf(task)] ?? false);
      _selectedTask.clear();
      _filterTasks(searchController.text);
    });
  }

  void showDeletedTasksDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select Tasks to Delete'),
            content: SingleChildScrollView(
              child: Column(
                children: tasks.asMap().entries.map((entry) {
                  int index = entry.key;
                  Task task = entry.value;
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return CheckboxListTile(
                        title: Text(task.name),
                        value: _selectedTask[index] ?? false,
                        onChanged: (value) {
                          setState(() {
                            _selectedTask[index] = value;
                          });
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    _removeSelectedTasks();
                    Navigator.pop(context);
                  },
                  child: const Text('Delete')),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
        _controller.forward();
      }
    });

    searchController.addListener(() {
      _filterTasks(searchController.text);
    });

    _loadFromPrefs();
  }

  @override
  void dispose() {
    super.dispose();

    // Dispose the animation controller
    _controller.dispose();

    // Dispose the search controller
    searchController.dispose();

    _saveToPrefs();
  }

  void _filterTasks(String searchText) {
    setState(() {
      if (searchText.isEmpty) {
        filteredTasks = List.from(tasks);
      } else {
        filteredTasks = tasks
            .where((task) =>
                task.name.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
      }
    });
  }
  void _saveToPrefs() async {
    try {
      prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
          'tasks', tasks.map((task) => task.toString()).toList());
    } catch (e) {
      // Handle the error, e.g., log it or show a user-friendly message
      if (kDebugMode) {
        print('Error saving tasks to SharedPreferences: $e');
      } // or log('Error saving tasks to SharedPreferences: $e');
    }
  }

  void _loadFromPrefs() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? savedTasks = prefs.getStringList('tasks');
    if (savedTasks != null) {
      setState(() {
        tasks.addAll(savedTasks.map((task) => Task.fromMap(jsonDecode(task))));
        _filterTasks(searchController.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: showDeletedTasksDialog,
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(
              child: searchBar(),
            ),
            Expanded(child: buildTaskScreen()),
          ],
        );
      }),
      floatingActionButton: bottomAppBar()[0],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: bottomAppBar()[1],
    );
  }

  Widget buildTaskScreen() {
    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return TaskTile(
          task: filteredTasks[index],
          toggleCheckboxState: (bool? checkboxState) {
            setState(() {
              filteredTasks[index].toggleDone();
            });
          },
        );
      },
    );
  }

  List bottomAppBar() {
    return [
      FloatingActionButton(
        backgroundColor: Colors.blue.shade100,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0))),
        onPressed: () {
          _controller.forward();
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController taskTileController =
                  TextEditingController();
              TextEditingController taskDescriptionController =
                  TextEditingController();

              return AlertDialog(
                title: const Text('Add Task'),
                content: SizedBox(
                  height: 200,
                  width: 50,
                  child: Column(
                    children: [
                      TextField(
                        controller: taskTileController,
                        autofocus: true,
                        decoration: const InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: taskDescriptionController,
                        decoration:
                            const InputDecoration(labelText: 'Description'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            selectedDate = await showDatePicker(
                                context: context,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100));
                          },
                          child: const Text('Select Date')),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _addTask(
                          taskTileController.text,
                          taskDescriptionController.text,
                          selectedDate ?? DateTime.now());
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  )
                ],
              );
            },
          );
        },
        child: AnimatedIcon(
          icon: AnimatedIcons.add_event,
          progress: _animation,
        ),
      ),
      SizedBox(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: BottomAppBar(
            color: Colors.blue.shade100,
            shape: const CircularNotchedRectangle(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.home_rounded,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ));
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.event_available_rounded,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CalenderScreen(
                            tasks: [],
                          ),
                        ));
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  Widget searchBar() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: TextField(
        autofocus: false,
        enableSuggestions: true,
        controller: searchController,
        decoration: const InputDecoration(
          labelText: 'Search Tasks',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 15),
        ),
        onChanged: (value) => _filterTasks(value),
      ),
    );
  }
}
