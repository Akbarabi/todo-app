class Task {
  final String name;
  final String description;
  final DateTime? date;
  bool isDone;

  Task(
      {required this.name,
      required this.description,
      required this.date,
      this.isDone = false});

  void toggleDone() {
    isDone = !isDone;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      description: map['description'],
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      isDone: map['isDone'] ?? false,
    );
  }
}
