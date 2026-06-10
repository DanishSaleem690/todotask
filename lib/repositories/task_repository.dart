import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/task.dart';
import '../models/task_priority.dart';

/// Sort options for task lists.
enum TaskSortOption {
  dateCreated,
  dueDate,
  priority,
}

/// Filter options for task completion status.
enum TaskStatusFilter {
  all,
  pending,
  completed,
}

/// Data layer for Firestore todo CRUD and queries.
class TaskRepository {
  TaskRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _todosCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('todos');
  }

  /// Real-time stream of todos for the authenticated user.
  Stream<List<Task>> watchTasksForUser(String userId) {
    return _todosCollection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Task.fromFirestore).toList(growable: false),
        );
  }

  Future<void> saveTask(Task task) async {
    await _todosCollection(task.userId).doc(task.id).set(task.toFirestore());
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _todosCollection(userId).doc(taskId).delete();
  }

  Future<Task?> getTaskById(String userId, String taskId) async {
    final doc = await _todosCollection(userId).doc(taskId).get();
    if (!doc.exists) return null;
    return Task.fromFirestore(doc);
  }

  List<Task> filterAndSort({
    required List<Task> tasks,
    TaskStatusFilter statusFilter = TaskStatusFilter.all,
    TaskPriority? priorityFilter,
    String searchQuery = '',
    TaskSortOption sortOption = TaskSortOption.dateCreated,
    bool ascending = false,
  }) {
    var result = List<Task>.from(tasks);

    switch (statusFilter) {
      case TaskStatusFilter.pending:
        result = result.where((t) => !t.isCompleted).toList();
      case TaskStatusFilter.completed:
        result = result.where((t) => t.isCompleted).toList();
      case TaskStatusFilter.all:
        break;
    }

    if (priorityFilter != null) {
      result = result.where((t) => t.priority == priorityFilter).toList();
    }

    final query = searchQuery.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result
          .where((t) => t.title.toLowerCase().contains(query))
          .toList();
    }

    result.sort((a, b) {
      int comparison;
      switch (sortOption) {
        case TaskSortOption.dateCreated:
          comparison = a.createdAt.compareTo(b.createdAt);
        case TaskSortOption.dueDate:
          comparison = _compareDueDates(a.dueDate, b.dueDate);
        case TaskSortOption.priority:
          comparison =
              a.priority.sortWeight.compareTo(b.priority.sortWeight);
      }
      return ascending ? comparison : -comparison;
    });

    return result;
  }

  int _compareDueDates(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }

  /// Seeds sample tasks for new users (runs once per user).
  Future<void> seedDummyData(String userId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    final snapshot = await userDoc.get();
    final seeded = snapshot.data()?['dummyDataSeeded'] as bool? ?? false;
    if (seeded) return;

    final now = DateTime.now();
    final dummyTasks = [
      Task.create(
        userId: userId,
        title: 'Welcome to Todo App',
        description: 'Explore the dashboard and create your first task!',
        priority: TaskPriority.medium,
        dueDate: now.add(const Duration(hours: 2)),
      ),
      Task.create(
        userId: userId,
        title: 'Review project requirements',
        description: 'Go through the feature checklist and plan your week.',
        priority: TaskPriority.high,
        dueDate: now,
      ),
      Task.create(
        userId: userId,
        title: 'Buy groceries',
        description: 'Milk, eggs, bread, and fruits.',
        priority: TaskPriority.low,
        dueDate: now.add(const Duration(days: 1)),
      ),
      Task.create(
        userId: userId,
        title: 'Morning workout',
        description: '30 minutes cardio and stretching.',
        priority: TaskPriority.medium,
        dueDate: now.subtract(const Duration(days: 1)),
      ),
      Task.create(
        userId: userId,
        title: 'Read Flutter documentation',
        description: 'Study Material 3 and state management patterns.',
        priority: TaskPriority.medium,
      ),
    ];

    final completed = dummyTasks[3].copyWith(isCompleted: true);
    final batch = _firestore.batch();

    for (final task in dummyTasks) {
      final toSave = task.id == completed.id ? completed : task;
      final ref = _todosCollection(userId).doc(toSave.id);
      batch.set(ref, toSave.toFirestore());
    }

    batch.set(
      userDoc,
      {'dummyDataSeeded': true},
      SetOptions(merge: true),
    );

    await batch.commit();
  }
}
