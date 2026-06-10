import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task_priority.dart';

void main() {
  test('TaskPriority sort weight orders correctly', () {
    expect(TaskPriority.high.sortWeight > TaskPriority.medium.sortWeight, true);
    expect(TaskPriority.medium.sortWeight > TaskPriority.low.sortWeight, true);
  });
}
