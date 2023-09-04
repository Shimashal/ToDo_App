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

  // Add a toJson method to serialize ToDo to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toDoText': toDoText,
      'isDone': isDone,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toString(),
    };
  }

  // Add a factory method to create a ToDo from JSON
  factory ToDo.fromJson(Map<String, dynamic> json) {
    return ToDo(
      id: json['id'],
      toDoText: json['toDoText'],
      isDone: json['isDone'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: Priority.values.firstWhere((e) => e.toString() == json['priority']),
    );
  }

  // Create an empty constructor for creating new tasks
   
}

// An enum representing the priority levels of ToDo items
enum Priority { Low, Medium, High }
