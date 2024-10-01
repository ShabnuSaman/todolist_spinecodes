import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_list_app/model/task_model.dart';



class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasksFromFirestore(); 
  }

  Future<void> _fetchTasksFromFirestore() async {
    final snapshot = await _firestore.collection('tasks').get();
    setState(() {
      tasks = snapshot.docs.map((doc) {
        return Task(
          id: doc.id,
          name: doc['taskName'],
          isCompleted: doc['isCompleted'],
        );
      }).toList();
    });
  }

  Future<void> _addTaskToFirestore() async {
    if (_controller.text.isNotEmpty) {
      final docRef = await _firestore.collection('tasks').add({
        'taskName': _controller.text,
        'isCompleted': false,
      });
      setState(() {
        tasks.add(Task(id: docRef.id, name: _controller.text));
        _controller.clear();
      });
      _showSnackbar('Task added successfully!',backgroundColor: Colors.green);
    } else {
      _showSnackbar('Task name cannot be empty!',backgroundColor: Colors.red);
    }
  }

  Future<void> _updateTaskInFirestore(Task task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': task.isCompleted,
    });
    _showSnackbar('Task updated successfully!',backgroundColor: Colors.blueAccent);
  }

  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _updateTaskInFirestore(task); 
    });
  }

  void _showSnackbar(String message, {Color backgroundColor = Colors.blue}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter Task',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addTaskToFirestore,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: const Text(
                'Add Task',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return ListTile(
                    leading: Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) {
                        _toggleTaskCompletion(task);
                      },
                    ),
                    title: Text(
                      task.name,
                      style: TextStyle(
                        color: task.isCompleted ? Colors.black : const Color.fromARGB(255, 59, 53, 53),
                        decoration: task.isCompleted
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

