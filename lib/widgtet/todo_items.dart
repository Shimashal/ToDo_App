import 'package:flutter/material.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:intl/intl.dart';

import '../model/to_do.dart';

class ToDoItems extends StatelessWidget {
  final ToDo todo;
  final Function(ToDo) onToDoChange;
  final Function(String) onDelete;
  final Function(ToDo, String, DateTime) onEdit;
  final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
  final List<DropdownMenuItem<Priority>> priorityItems;

  ToDoItems({
    Key? key,
    required this.todo,
    required this.onToDoChange,
    required this.onDelete,
    required this.onEdit,
  }) : priorityItems = Priority.values
            .map((priority) => DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toString().split('.').last),
                ))
            .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ListTile(
        onTap: () {
          print('Change was Made');
          // Handle completion status change
          onToDoChange(todo);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        tileColor: Colors.white,
        leading: Icon(
          todo.isDone
              ? Icons.check_box
              : Icons.check_box_outline_blank_outlined,
          color: amberLight,
        ),
        title: Text(
          todo.toDoText!,
          style: TextStyle(
            fontSize: 16,
            color: blacks,
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display due date and priority
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 5),
                Text(
                  dateFormat.format(todo.dueDate ?? DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2), // Add some spacing
            Container(
              constraints: const BoxConstraints(
                maxWidth: 170, // Adjust the maximum width as needed
              ),
              child: Text(
                _getPriorityText(todo.priority), // Display the priority text
                style: TextStyle(
                  fontSize: 12,
                  color: _getPriorityColor(
                      todo.priority), // Set text color based on priority
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Edit and delete buttons
            Container(
              height: 35,
              width: 35,
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: deepOrange,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: blacks,
                iconSize: 18,
                icon: const Icon(Icons.edit),
                onPressed: () {
                  print('Editing ToDo Done');
                  _showEditDialog(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Container(
              height: 30,
              width: 35,
              padding: const EdgeInsets.all(0),
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: deepOrange,
                borderRadius: BorderRadius.circular(5),
              ),
              child: IconButton(
                color: blacks,
                icon: const Icon(Icons.delete),
                iconSize: 18,
                onPressed: () {
                  print('Delete Done');
                  onDelete(todo.id!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Map priority to corresponding icon
  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.Low:
        return 'Low Priority';
      case Priority.Medium:
        return 'Medium Priority';
      case Priority.High:
        return 'High Priority';
    }
  }

  // Map priority to corresponding color
  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.Low:
        return Colors.green;
      case Priority.Medium:
        return accentOrange;
      case Priority.High:
        return Colors.red;
    }
  }

  // Edit the ToDo item AlertDialog
  void _showEditDialog(BuildContext context) {
    String newToDoText = todo.toDoText!;
    DateTime newDueDate = todo.dueDate ?? DateTime.now();
    Priority selectedPriority = todo.priority; // Initialize selectedPriority

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: accentOrange,
          title: const Text(
            'Edit ToDo Item',
            style: TextStyle(color: blacks, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  newToDoText = value;
                },
                controller: TextEditingController(text: todo.toDoText),
                decoration: const InputDecoration(labelText: 'ToDo Text'),
              ),
              const SizedBox(height: 10),
              Text('Due Date: ${dateFormat.format(newDueDate)}'),
              ElevatedButton(
                onPressed: () async {
                  final picked = await _selectDate(context, newDueDate);
                  if (picked != null) {
                    newDueDate = picked;
                  }
                },
                child: const Text(
                  'Pick a Due Date',
                  style: TextStyle(color: blacks),
                ),
              ),
              // Priority dropdown selection
              const SizedBox(height: 10),
              DropdownButtonFormField<Priority>(
                value: selectedPriority,
                items: priorityItems,
                onChanged: (Priority? priority) {
                  if (priority != null) {
                    selectedPriority = priority;
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onEdit(todo, newToDoText, newDueDate);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  // Show a date picker dialog for selecting due date
  Future<DateTime?> _selectDate(
      BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    return picked;
  }
}
