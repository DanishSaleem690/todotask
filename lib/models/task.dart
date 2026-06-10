import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'task_priority.dart';

/// Domain model representing a single todo task.
class Task {
  Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.dueDate,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String userId;
  String title;
  String description;
  TaskPriority priority;
  DateTime? dueDate;
  final DateTime createdAt;
  bool isCompleted;

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    bool clearDueDate = false,
  }) {
    return Task(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  factory Task.create({
    required String userId,
    required String title,
    String description = '',
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
    String? id,
  }) {
    return Task(
      id: id ?? const Uuid().v4(),
      userId: userId,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'title': title,
        'description': description,
        'priority': priority.index,
        'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'isCompleted': isCompleted,
      };

  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return Task(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      priority: TaskPriority.fromIndex(data['priority'] as int? ?? 1),
      dueDate: data['dueDate'] is Timestamp
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }
}
