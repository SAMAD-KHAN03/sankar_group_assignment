// lib/services/firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'tasks';

  /// Stream of all tasks for a given user, ordered by date descending
  Stream<List<TaskModel>> getTasksStream(String userId) {
    return _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TaskModel.fromDocument(doc)).toList());
  }

  /// Add a new task to Firestore
  Future<void> addTask(TaskModel task) async {
    await _db.collection(_collection).add(task.toMap());
  }

  /// Update an existing task in Firestore
  Future<void> updateTask(TaskModel task) async {
    if (task.id == null) return;
    await _db.collection(_collection).doc(task.id).update(task.toMap());
  }

  /// Delete a task from Firestore
  Future<void> deleteTask(String taskId) async {
    await _db.collection(_collection).doc(taskId).delete();
  }

  /// Toggle the completion status of a task
  Future<void> toggleTaskStatus(String taskId, bool currentStatus) async {
    await _db
        .collection(_collection)
        .doc(taskId)
        .update({'isCompleted': !currentStatus});
  }
}
