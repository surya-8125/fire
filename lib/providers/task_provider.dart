
// task_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../utils/constants.dart';

class TaskProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Model for task (you can adjust this structure)
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => _tasks;

  String get _collectionPath => 'users/${Constants.username}/tasks';

  // Get all tasks
  Future<void> fetchTasks() async {
    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      _tasks = snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  // Add a new task
  Future<void> addTask(Map<String, dynamic> taskData) async {
    try {
      // Create a copy for Firestore
      final firestoreData = Map<String, dynamic>.from(taskData);
      // Add timestamp for Firestore (optional)
      firestoreData['createdAt'] = Timestamp.now();

      // Add to Firestore
      final docRef = await _firestore.collection(_collectionPath).add(firestoreData);

      // Also update our local list for immediate UI update
      final newTask = Map<String, dynamic>.from(taskData);
      newTask['id'] = docRef.id;
      newTask['createdAt'] = Timestamp.now();

      _tasks.add(newTask);
      notifyListeners(); // This triggers UI update
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection(_collectionPath).doc(taskId).delete();

      // Update local data
      _tasks.removeWhere((task) => task['id'] == taskId);
      notifyListeners(); // This triggers UI update
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  // Edit a task
  Future<void> editTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      // Create a copy for Firestore
      final firestoreData = Map<String, dynamic>.from(updatedData);
      // Add last updated timestamp (optional)
      firestoreData['lastUpdated'] = Timestamp.now();

      await _firestore.collection(_collectionPath).doc(taskId).update(firestoreData);

      // Update local data
      final index = _tasks.indexWhere((task) => task['id'] == taskId);
      if (index != -1) {
        // Create a new map with all existing and updated data
        _tasks[index] = {
          ..._tasks[index],
          ...updatedData,
          'lastUpdated': Timestamp.now()
        };
        notifyListeners(); // This triggers UI update
      }
    } catch (e) {
      print('Error editing task: $e');
    }
  }
}