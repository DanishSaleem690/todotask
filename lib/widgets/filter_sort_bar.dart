import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/task_priority.dart';
import '../providers/task_provider.dart';
import '../repositories/task_repository.dart';

/// Search, filter, and sort controls for the task list.
class FilterSortBar extends ConsumerStatefulWidget {
  const FilterSortBar({super.key});

  @override
  ConsumerState<FilterSortBar> createState() => _FilterSortBarState();
}

class _FilterSortBarState extends ConsumerState<FilterSortBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters(TaskFilterState filters) {
    ref.read(taskListProvider.notifier).updateFilters(filters);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(taskFilterProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search tasks by title...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _updateFilters(filters.copyWith(searchQuery: ''));
                    },
                  )
                : null,
          ),
          onChanged: (value) =>
              _updateFilters(filters.copyWith(searchQuery: value)),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _FilterChip(
                label: 'All',
                selected: filters.statusFilter == TaskStatusFilter.all,
                onSelected: () => _updateFilters(
                  filters.copyWith(statusFilter: TaskStatusFilter.all),
                ),
              ),
              _FilterChip(
                label: 'Pending',
                selected: filters.statusFilter == TaskStatusFilter.pending,
                onSelected: () => _updateFilters(
                  filters.copyWith(statusFilter: TaskStatusFilter.pending),
                ),
              ),
              _FilterChip(
                label: 'Completed',
                selected: filters.statusFilter == TaskStatusFilter.completed,
                onSelected: () => _updateFilters(
                  filters.copyWith(statusFilter: TaskStatusFilter.completed),
                ),
              ),
              const SizedBox(width: 8),
              ...TaskPriority.values.map(
                (priority) => _FilterChip(
                  label: priority.label,
                  selected: filters.priorityFilter == priority,
                  onSelected: () {
                    final isSelected = filters.priorityFilter == priority;
                    _updateFilters(
                      filters.copyWith(
                        priorityFilter: isSelected ? null : priority,
                        clearPriority: isSelected,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.sort, size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Sort by:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(width: 8),
            DropdownButton<TaskSortOption>(
              value: filters.sortOption,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: TaskSortOption.dateCreated,
                  child: Text('Date Created'),
                ),
                DropdownMenuItem(
                  value: TaskSortOption.dueDate,
                  child: Text('Due Date'),
                ),
                DropdownMenuItem(
                  value: TaskSortOption.priority,
                  child: Text('Priority'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  _updateFilters(filters.copyWith(sortOption: value));
                }
              },
            ),
            const Spacer(),
            IconButton(
              tooltip: filters.ascending ? 'Ascending' : 'Descending',
              onPressed: () =>
                  _updateFilters(filters.copyWith(ascending: !filters.ascending)),
              icon: Icon(
                filters.ascending
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        showCheckmark: false,
      ),
    );
  }
}
