import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task.dart';
import '../providers/auth_provider.dart';
import '../providers/providers.dart';
import '../providers/task_provider.dart';
import '../utils/firebase_error_mapper.dart';
import 'loading_indicator.dart';

/// Real-time Firestore task stream wrapped in [StreamBuilder].
class TasksStreamBuilder extends ConsumerWidget {
  const TasksStreamBuilder({
    super.key,
    required this.builder,
    this.loadingMessage = 'Loading tasks...',
  });

  final Widget Function(BuildContext context, List<Task> tasks) builder;
  final String loadingMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authProvider).user?.id;

    if (userId == null) {
      return const LoadingIndicator(message: 'Loading tasks...');
    }

    final stream = ref.read(taskRepositoryProvider).watchTasksForUser(userId);

    return StreamBuilder<List<Task>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingIndicator(message: loadingMessage);
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 48,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    FirebaseErrorMapper.firestoreMessage(snapshot.error!),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          );
        }

        final tasks = snapshot.data ?? [];
        return builder(context, tasks);
      },
    );
  }
}

/// Applies current UI filters to a raw task list from Firestore.
List<Task> filteredTasksFromStream(WidgetRef ref, List<Task> tasks) {
  ref.watch(taskListProvider);
  ref.watch(taskFilterProvider);
  return ref.read(taskListProvider.notifier).applyFilters(tasks);
}
