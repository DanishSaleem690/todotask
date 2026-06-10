import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../models/task_priority.dart';
import '../repositories/task_repository.dart';
import '../utils/firebase_error_mapper.dart';
import 'providers.dart';

/// UI-facing filter and sort configuration for tasks.
class TaskFilterState {
  const TaskFilterState({
    this.statusFilter = TaskStatusFilter.all,
    this.priorityFilter,
    this.searchQuery = '',
    this.sortOption = TaskSortOption.dateCreated,
    this.ascending = false,
  });

  final TaskStatusFilter statusFilter;
  final TaskPriority? priorityFilter;
  final String searchQuery;
  final TaskSortOption sortOption;
  final bool ascending;

  TaskFilterState copyWith({
    TaskStatusFilter? statusFilter,
    TaskPriority? priorityFilter,
    String? searchQuery,
    TaskSortOption? sortOption,
    bool? ascending,
    bool clearPriority = false,
  }) {
    return TaskFilterState(
      statusFilter: statusFilter ?? this.statusFilter,
      priorityFilter:
          clearPriority ? null : (priorityFilter ?? this.priorityFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      ascending: ascending ?? this.ascending,
    );
  }
}

/// Mutation state for task CRUD operations (list data comes from Firestore streams).
class TaskListState {
  const TaskListState({
    this.isSaving = false,
    this.error,
    this.lastDeletedTask,
  });

  final bool isSaving;
  final String? error;
  final Task? lastDeletedTask;

  TaskListState copyWith({
    bool? isSaving,
    String? error,
    Task? lastDeletedTask,
    bool clearError = false,
    bool clearDeleted = false,
  }) {
    return TaskListState(
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      lastDeletedTask:
          clearDeleted ? null : (lastDeletedTask ?? this.lastDeletedTask),
    );
  }
}

class TaskListNotifier extends StateNotifier<TaskListState> {
  TaskListNotifier(this._repository) : super(const TaskListState());

  final TaskRepository _repository;
  TaskFilterState _filters = const TaskFilterState();

  TaskFilterState get filters => _filters;

  List<Task> applyFilters(List<Task> tasks) {
    return _repository.filterAndSort(
      tasks: tasks,
      statusFilter: _filters.statusFilter,
      priorityFilter: _filters.priorityFilter,
      searchQuery: _filters.searchQuery,
      sortOption: _filters.sortOption,
      ascending: _filters.ascending,
    );
  }

  void updateFilters(TaskFilterState filters) {
    _filters = filters;
    state = state.copyWith();
  }

  Future<bool> addTask(Task task) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.saveTask(task);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: FirebaseErrorMapper.firestoreMessage(e),
      );
      return false;
    }
  }

  Future<bool> updateTask(Task task) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.saveTask(task);
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: FirebaseErrorMapper.firestoreMessage(e),
      );
      return false;
    }
  }

  Future<bool> toggleComplete(Task task) async {
    return updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<bool> deleteTask(Task task) async {
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      await _repository.deleteTask(task.userId, task.id);
      state = state.copyWith(
        isSaving: false,
        lastDeletedTask: task,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: FirebaseErrorMapper.firestoreMessage(e),
      );
      return false;
    }
  }

  Future<bool> undoDelete() async {
    final deleted = state.lastDeletedTask;
    if (deleted == null) return false;
    final restored = await addTask(deleted);
    if (restored) {
      state = state.copyWith(clearDeleted: true);
    }
    return restored;
  }

  void clear() {
    _filters = const TaskFilterState();
    state = const TaskListState();
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListNotifier, TaskListState>((ref) {
  return TaskListNotifier(ref.watch(taskRepositoryProvider));
});

final taskFilterProvider = Provider<TaskFilterState>((ref) {
  ref.watch(taskListProvider);
  return ref.read(taskListProvider.notifier).filters;
});
