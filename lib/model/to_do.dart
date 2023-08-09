class ToDo {
  String? id;
  String? toDoText;
  bool isDone;
  DateTime? dueDate;
  Priority priority;

  ToDo({
    required this.id,
    required this.toDoText,
    this.isDone = false,
    this.dueDate,
    this.priority = Priority.Medium,
  });

  static List<ToDo> todoList() {
    return [
      ToDo(
        id: '1',
        toDoText: 'Daily Task Attendance - Internship ',
        isDone: true,
        dueDate: DateTime.now().add(Duration(days: 1)),
      ),
    ];
  }
}

// An enum representing the priority levels of ToDo items
enum Priority { Low, Medium, High }
