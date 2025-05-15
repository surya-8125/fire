import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load tasks when page initializes
    _loadTasks();
  }

  // Load tasks and update loading state
  Future<void> _loadTasks() async {
    await Provider.of<TaskProvider>(context, listen: false).fetchTasks();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTaskDialog({Map<String, dynamic>? task}) {
    final titleController = TextEditingController(text: task?['title']);
    final descController = TextEditingController(text: task?['description']);
    final isEdit = task != null;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEdit ? 'Edit Task' : 'Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final taskData = {
                'title': titleController.text.trim(),
                'description': descController.text.trim(),
              };

              final taskProvider = Provider.of<TaskProvider>(context, listen: false);
              if (isEdit) {
                taskProvider.editTask(task['id'], taskData);
              } else {
                taskProvider.addTask(taskData);
              }

              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          final tasks = taskProvider.tasks;

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task['title'] ?? ''),
                subtitle: Text(task['description'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showTaskDialog(task: task),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Provider.of<TaskProvider>(context, listen: false)
                            .deleteTask(task['id']);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}