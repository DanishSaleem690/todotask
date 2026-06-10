import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/task.dart';
import '../../utils/date_formatter.dart';
import '../../utils/responsive.dart';
import '../../widgets/dashboard_stats_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/priority_chip.dart';
import '../../widgets/progress_chart.dart';
import '../../widgets/tasks_stream_builder.dart';

/// Dashboard with stats, progress chart, and today's tasks.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  List<Task> _todayTasks(List<Task> tasks) {
    return tasks.where((t) => t.isDueToday && !t.isCompleted).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columns = Responsive.gridColumns(context);
    final isCompact = Responsive.isMobile(context);

    return TasksStreamBuilder(
      loadingMessage: 'Loading dashboard...',
      builder: (context, tasks) {
        final total = tasks.length;
        final completed = tasks.where((t) => t.isCompleted).length;
        final pending = total - completed;
        final progress = total == 0 ? 0.0 : completed / total;
        final todayTasks = _todayTasks(tasks);

        return SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your productivity at a glance',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  DashboardStatsGrid(
                    total: total,
                    completed: completed,
                    pending: pending,
                    columns: columns.clamp(1, 3),
                  ),
                  const SizedBox(height: 24),
                  if (isCompact)
                    ProgressChartCompact(
                      progress: progress,
                      completed: completed,
                      total: total,
                    )
                  else
                    ProgressChart(
                      progress: progress,
                      completed: completed,
                      total: total,
                    ),
                  const SizedBox(height: 24),
                  Text(
                    "Today's Tasks",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (todayTasks.isEmpty)
                    const EmptyState(
                      title: 'No tasks due today',
                      subtitle: 'Enjoy your free day or add a new task!',
                      icon: Icons.wb_sunny_outlined,
                    )
                  else
                    ...todayTasks.map(
                      (task) => _TodayTaskTile(task: task),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TodayTaskTile extends StatelessWidget {
  const _TodayTaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.today,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          task.dueDate != null
              ? DateFormatter.formatTime(task.dueDate!)
              : 'No time set',
        ),
        trailing: PriorityChip(priority: task.priority, compact: true),
      ),
    );
  }
}
