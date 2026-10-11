import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_task_manager/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/task_model.dart';
import 'add_task_screen.dart';
import '../widgets/filter_chip.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final dbref = FirebaseFirestore.instance.collection('task');

  final List<TaskModel> _tasks = [];
  final Set<String> _updatingTaskIds = {};

  bool _isLoading = true;
  String? _loadError;

  Future<void> _loadTasksFromFirestore() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      final snapshot = await dbref.get();
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data();
        final dueDate = data['dueDate'];
        return TaskModel(
          id: doc.id,
          title: data['title'] as String? ?? '',
          notes: data['notes'] as String? ?? '',
          dueDate: dueDate is Timestamp
              ? dueDate.toDate()
              : DateTime.tryParse(dueDate?.toString() ?? '') ?? DateTime.now(),
          priority: _parsePriority(data['priority']),
          isDone: data['isDone'] as bool? ?? false,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _tasks
          ..clear()
          ..addAll(tasks);
        _loadError = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load tasks. Check your connection and retry.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TaskPriority _parsePriority(Object? value) {
    if (value is String) {
      return TaskPriority.values.firstWhere(
        (priority) => priority.name == value,
        orElse: () => TaskPriority.medium,
      );
    }
    if (value is int && value >= 0 && value < TaskPriority.values.length) {
      return TaskPriority.values[value];
    }
    return TaskPriority.medium;
  }

  TaskFilter _selectedFilter = TaskFilter.all;

  List<TaskModel> get _filteredTasks {
    switch (_selectedFilter) {
      case TaskFilter.all:
        return _tasks;
      case TaskFilter.pending:
        return _tasks.where((task) => !task.isDone).toList();
      case TaskFilter.completed:
        return _tasks.where((task) => task.isDone).toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadTasksFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C2433),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8EDF5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_tasks.length} TOTAL',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF46536A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      color: Color(0xFF1C2433),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF1C2433),
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Today • ${DateFormat('EEEE, MMM d').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6A7382),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1E5EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedFilter = TaskFilter.all),
                        child: FiltersChip(
                          label: 'All',
                          selected: _selectedFilter == TaskFilter.all,
                          count: _tasks.length,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedFilter = TaskFilter.pending,
                        ),
                        child: FiltersChip(
                          label: 'Pending',
                          selected: _selectedFilter == TaskFilter.pending,
                          count: _tasks.where((task) => !task.isDone).length,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _selectedFilter = TaskFilter.completed,
                        ),
                        child: FiltersChip(
                          label: 'Completed',
                          selected: _selectedFilter == TaskFilter.completed,
                          count: _tasks.where((task) => task.isDone).length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _loadError != null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _loadError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF6A7382)),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _loadTasksFromFirestore,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredTasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No tasks to display',
                          style: TextStyle(color: Color(0xFF6A7382)),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: _filteredTasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final task = _filteredTasks[index];
                          final priorityColor = taskPriorityColor(
                            task.priority,
                          );
                          final priorityBg = taskPriorityBg(task.priority);
                          final completed = task.isDone;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: completed
                                  ? const Color(0xFFFBFCFE)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: completed
                                    ? const Color(0xFFEDF1F6)
                                    : const Color(0xFFDDE3EC),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => _toggleTask(task),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: task.isDone
                                              ? const Color(0xFF7F8793)
                                              : const Color(0xFF8F98A7),
                                          width: 2,
                                        ),
                                        color: task.isDone
                                            ? const Color(0xFF7F8793)
                                            : Colors.transparent,
                                      ),
                                      child: task.isDone
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: completed
                                                  ? const Color(0xFFF2F5F9)
                                                  : priorityBg,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '• ${task.priorityLabel}',
                                              style: TextStyle(
                                                color: completed
                                                    ? const Color(0xFFAAB7C9)
                                                    : priorityColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          if (completed) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEAF8F2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'Done',
                                                style: TextStyle(
                                                  color: Color(0xFF70C5A2),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () =>
                                                _openAddTaskScreen(task),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            color: completed
                                                ? const Color(0xFFD1D9E4)
                                                : const Color(0xFF6F7A8E),
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                          const SizedBox(width: 4),
                                          IconButton(
                                            onPressed: () => _deleteTask(task),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                            ),
                                            color: completed
                                                ? const Color(0xFFD1D9E4)
                                                : const Color(0xFF6F7A8E),
                                            iconSize: 22,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: completed
                                              ? const Color(0xFFB7C3D5)
                                              : const Color(0xFF1C2433),
                                          decoration: completed
                                              ? TextDecoration.lineThrough
                                              : TextDecoration.none,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        task.notes,
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: completed
                                              ? const Color(0xFFB7C3D5)
                                              : const Color(0xFF666F82),
                                          height: 1.4,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: completed
                                                ? const Color(0xFFB7C3D5)
                                                : const Color(0xFF7A8393),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Due ${_formatTaskDate(task.dueDate)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: completed
                                                  ? const Color(0xFFB7C3D5)
                                                  : const Color(0xFF7A8393),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: completed
                                                ? const Color(0xFFB7C3D5)
                                                : const Color(0xFF7A8393),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            task.isDone ? 'Done' : 'Pending',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: completed
                                                  ? const Color(0xFFB7C3D5)
                                                  : const Color(0xFF7A8393),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openAddTaskScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E2431),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    icon: const Icon(Icons.add, size: 26, color: Colors.white),
                    label: const Text(
                      'New Task',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTaskDate(DateTime date) {
    const monthNames = <int, String>{
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'May',
      6: 'Jun',
      7: 'Jul',
      8: 'Aug',
      9: 'Sep',
      10: 'Oct',
      11: 'Nov',
      12: 'Dec',
    };
    return '${monthNames[date.month]} ${date.day}';
  }

  Future<void> _openAddTaskScreen([TaskModel? task]) async {
    final result = await Navigator.of(context).push<TaskModel>(
      MaterialPageRoute(builder: (_) => AddTaskScreen(task: task)),
    );

    if (!mounted || result == null) return;

    setState(() {
      final index = _tasks.indexWhere((item) => item.id == result.id);
      if (index >= 0) {
        _tasks[index] = result;
      } else {
        _tasks.insert(0, result);
      }
    });
  }

  Future<void> _toggleTask(TaskModel task) async {
    if (_updatingTaskIds.contains(task.id)) return;

    final updatedTask = task.copyWith(isDone: !task.isDone);
    setState(() {
      _updatingTaskIds.add(task.id);
      final index = _tasks.indexWhere((item) => item.id == task.id);
      if (index >= 0) {
        _tasks[index] = updatedTask;
      }
    });

    try {
      await dbref.doc(task.id).update({'isDone': updatedTask.isDone});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        final index = _tasks.indexWhere((item) => item.id == task.id);
        if (index >= 0) _tasks[index] = task;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update task status. Please retry.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingTaskIds.remove(task.id));
      }
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEE5A5A),
                  size: 28,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Delete Task?',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D2433),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Are you sure you want to remove this task?\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6F7885),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FA),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'CS 304',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDECEC),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '• ${task.priorityLabel} Priority',
                        style: const TextStyle(
                          color: Color(0xFFEE5A5A),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D2433),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: Color(0xFF7D8594),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due ${_formatTaskDate(task.dueDate)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF7D8594),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE5A5A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Delete Task',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF1D2433),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldDelete != true) return;

    try {
      await dbref.doc(task.id).delete();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete task. Please retry.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      _tasks.removeWhere((item) => item.id == task.id);
    });
  }
}
