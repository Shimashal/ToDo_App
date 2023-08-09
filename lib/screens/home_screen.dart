import 'package:flutter/material.dart';
import 'package:todo_app/constants/colors.dart';
import 'package:intl/intl.dart';

import '../model/to_do.dart';
import '../widgtet/todo_items.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final todoList = ToDo.todoList();
  List<ToDo> findSearch = [];
  final todoController = TextEditingController();
  final dateFormat = DateFormat('MMM dd, yyyy');
  DateTime? selectedDate;
  @override
  void initState() {
    findSearch = todoList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 240, 240),
      appBar: AppBar_buildAppBar(),
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                searchBox(),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 50, bottom: 20),
                        child: const Text(
                          'All ToDos',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      for (ToDo toDo in findSearch)
                        ToDoItems(
                          todo: toDo,
                          onToDoChange: handleToDoChanging,
                          onDelete: deleteItem,
                          onEdit: editItem,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      right: 20,
                      left: 20,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: orangelight,
                      boxShadow: const [
                        BoxShadow(
                          color: amberLight,
                          offset: Offset(0.0, 0.0),
                          spreadRadius: 0.0,
                          blurRadius: 10.0,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: todoController,
                      decoration: const InputDecoration(
                        hintText: 'Add a new Todo Item',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedDate = null;
                        });
                      },
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    right: 20,
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      print('added');
                      addNewItem(todoController.text, selectedDate);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      minimumSize: Size(screenWidth * 0.12, screenWidth * 0.12),
                      elevation: 10,
                    ),
                    child: const Text(
                      '+',
                      style: TextStyle(
                        fontSize: 40,
                        color: blacks,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 void addNewItem(String toDo, DateTime? dueDate) async {
  if (toDo.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cannot add an empty ToDo item.'),
      ),
    );
    return;
  }

  if (dueDate == null) {
    dueDate = await _selectDate(context);
    if (dueDate == null) {
      // User canceled date selection
      return;
    }
  }

  // Show the priority selection dialog
  final selectedPriority = await _selectPriority(context);

  if (selectedPriority == null) {
    // User canceled priority selection
    return;
  }

  setState(() {
    todoList.add(
      ToDo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        toDoText: toDo,
        dueDate: dueDate,
        priority: selectedPriority,
      ),
    );
  });
  todoController.clear();
}

Future<Priority?> _selectPriority(BuildContext context) async {
  return await showDialog<Priority>(
    context: context,
    builder: (context) {
      Priority selectedPriority = Priority.Medium; // Default priority

      return AlertDialog(
        title: const Text('Select Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Priority>(
              value: selectedPriority,
              items: Priority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toString().split('.').last),
                );
              }).toList(),
              onChanged: (Priority? priority) {
                if (priority != null) {
                  selectedPriority = priority;
                }
              },
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(selectedPriority);
            },
            child: const Text('Done'),
          ),
        ],
      );
    },
  );
}


  Future<DateTime?> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    return picked;
  }

  void searchFilter(String enteredKeyword) {
    List<ToDo> results = [];
    if (enteredKeyword.isEmpty) {
      results = todoList;
    } else {
      results = todoList
          .where((item) => item.toDoText!
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
    setState(() {
      findSearch= results;
    });
  }

  void handleToDoChanging(ToDo toDo) {
    setState(() {
      toDo.isDone = !toDo.isDone;
    });
  }

  void deleteItem(String id) {
    setState(() {
      todoList.removeWhere((item) => item.id == id);
    });
  }

 void editItem(
 ToDo toDo, String newToDoText, DateTime newDueDate) {
  setState(() {
    toDo.toDoText = newToDoText;
    toDo.dueDate = newDueDate;
  });
}


  Widget searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child:  TextField(
        onChanged: (value) => searchFilter(value) ,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(0),
          prefixIcon: Icon(
            Icons.search,
            color: blacks,
            size: 20,
          ),
          prefixIconConstraints: BoxConstraints(
            maxHeight: 20,
            minWidth: 40,
          ),
          border: InputBorder.none,
          hintText: 'Search',
        ),
      ),
    );
  }

  AppBar_buildAppBar() {
    return AppBar(
      backgroundColor: accentOrange,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Task 01',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w400,
          fontFamily: 'Arial',
        ),
      ),
    );
  }
}
