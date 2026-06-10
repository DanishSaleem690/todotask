/// Priority levels for todo tasks.
enum TaskPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  /// Numeric weight used for sorting (higher = more urgent).
  int get sortWeight {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
    }
  }

  static TaskPriority fromIndex(int index) {
    return TaskPriority.values[index.clamp(0, TaskPriority.values.length - 1)];
  }
}
