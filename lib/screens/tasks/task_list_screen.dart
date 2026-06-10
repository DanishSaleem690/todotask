import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../utils/router.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_sort_bar.dart';
import '../../widgets/task_card.dart';
import '../../widgets/tasks_stream_builder.dart';

/// Task list with search, filters, sort, and undo-delete snackbar.
class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  Future<void> _confirmAndDelete(
    BuildContext context,
    WidgetRef ref,
    Task task,
  ) async {
    final confirmed = await ConfirmationDialog.show(
      context,
      title: 'Delete Task',
      message: 'Are you sure you want to delete "${task.title}"?',
    );

    if (confirmed && context.mounted) {
      final deleted = await ref.read(taskListProvider.notifier).deleteTask(task);
      if (deleted && context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${task.title}" deleted'),
            duration: AppConstants.snackBarDuration,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () =>
                  ref.read(taskListProvider.notifier).undoDelete(),
            ),
          ),
        );
      } else if (context.mounted) {
        final error = ref.read(taskListProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mutationState = ref.watch(taskListProvider);

    return Column(
      children: [
        Padding(
          padding: Responsive.pagePadding(context).copyWith(bottom: 0),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: const FilterSortBar(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TasksStreamBuilder(
            builder: (context, allTasks) {
              final tasks = filteredTasksFromStream(ref, allTasks);

              if (tasks.isEmpty) {
                return EmptyState(
                  title: 'No tasks found',
                  subtitle: allTasks.isEmpty
                      ? 'Tap + to create your first task'
                      : 'Try adjusting your filters or search',
                  icon: Icons.inbox_outlined,
                  actionLabel: allTasks.isEmpty ? 'Add Task' : null,
                  onAction: allTasks.isEmpty
                      ? () => context.push(AppRoutes.addTask)
                      : null,
                );
              }

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.contentMaxWidth(context),
                  ),
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: Responsive.pagePadding(context),
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return AnimatedSwitcher(
                            duration: AppConstants.animationDuration,
                            child: Padding(
                              key: ValueKey(task.id),
                              padding: const EdgeInsets.only(bottom: 12),
                              child: TaskCard(
                                task: task,
                                onToggle: () => ref
                                    .read(taskListProvider.notifier)
                                    .toggleComplete(task),
                                onTap: () => context.push(
                                  '${AppRoutes.editTask}/${task.id}',
                                  extra: task,
                                ),
                                onDelete: () =>
                                    _confirmAndDelete(context, ref, task),
                              ),
                            ),
                          );
                        },
                      ),
                      if (mutationState.isSaving)
                        const Positioned(
                          top: 8,
                          right: 16,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
