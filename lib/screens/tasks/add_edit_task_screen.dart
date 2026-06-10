import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/task.dart';
import '../../models/task_priority.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../utils/date_formatter.dart';
import '../../utils/responsive.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

/// Screen for creating or editing a task with priority and due date.
class AddEditTaskScreen extends ConsumerStatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  bool get isEditing => task != null;

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _priority = widget.task?.priority ?? TaskPriority.medium;
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueDate ?? now),
    );
    if (time == null || !mounted) return;

    setState(() {
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = ref.read(authProvider).user?.id;
    if (userId == null) return;

    final notifier = ref.read(taskListProvider.notifier);
    bool success;

    if (widget.isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
      );
      success = await notifier.updateTask(updated);
    } else {
      final task = Task.create(
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
      success = await notifier.addTask(task);
    }

    if (!mounted) return;

    if (success) {
      context.pop();
    } else {
      final error = ref.read(taskListProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to save task.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: Responsive.pagePadding(context),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: Responsive.contentMaxWidth(context) * 0.7,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _titleController,
                    label: 'Title',
                    hint: 'What needs to be done?',
                    prefixIcon: Icons.title,
                    textInputAction: TextInputAction.next,
                    validator: Validators.validateTaskTitle,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Add more details (optional)',
                    prefixIcon: Icons.notes,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Priority',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: TaskPriority.values.map((priority) {
                      final selected = _priority == priority;
                      return FilterChip(
                        label: Text(priority.label),
                        selected: selected,
                        onSelected: (_) =>
                            setState(() => _priority = priority),
                        showCheckmark: true,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Due Date & Time',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickDueDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _dueDate != null
                          ? DateFormatter.formatDateTime(_dueDate!)
                          : 'Set due date',
                    ),
                  ),
                  if (_dueDate != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () => setState(() => _dueDate = null),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear due date'),
                    ),
                  ],
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _saveTask,
                    icon: Icon(
                      widget.isEditing ? Icons.save : Icons.add_task,
                    ),
                    label: Text(widget.isEditing ? 'Update Task' : 'Create Task'),
                  ),
                  if (widget.isEditing) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(taskListProvider.notifier)
                            .toggleComplete(widget.task!);
                        context.pop();
                      },
                      icon: Icon(
                        widget.task!.isCompleted
                            ? Icons.undo
                            : Icons.check_circle,
                      ),
                      label: Text(
                        widget.task!.isCompleted
                            ? 'Mark as Pending'
                            : 'Mark as Completed',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
