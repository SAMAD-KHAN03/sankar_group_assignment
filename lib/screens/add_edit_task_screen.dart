// lib/screens/add_edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddEditTaskScreen extends StatefulWidget {
  /// Pass an existing task to edit it; null means adding a new task
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isCompleted = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDate = widget.task!.date;
      _dateController.text =
          DateFormat('MMM dd, yyyy').format(widget.task!.date);
      _isCompleted = widget.task!.isCompleted;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = _authService.currentUser!.uid;

      final task = TaskModel(
        id: widget.task?.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _selectedDate!,
        isCompleted: _isCompleted,
        userId: userId,
      );

      if (_isEditing) {
        await _firestoreService.updateTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task updated successfully!'),
              backgroundColor: AppTheme.completedColor,
            ),
          );
        }
      } else {
        await _firestoreService.addTask(task);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task added successfully!'),
              backgroundColor: AppTheme.completedColor,
            ),
          );
        }
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Task' : 'Add Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              const Text(
                'Task Title *',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Enter task title',
                prefixIcon: const Icon(Icons.title_outlined),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Task title is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description field
              const Text(
                'Description',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter task description (optional)',
                prefixIcon: const Icon(Icons.description_outlined),
                maxLines: 3,
                validator: null,
              ),
              const SizedBox(height: 20),

              // Date picker
              const Text(
                'Due Date *',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _dateController,
                label: 'Date',
                hint: 'Select due date',
                prefixIcon: const Icon(Icons.calendar_today_outlined),
                readOnly: true,
                onTap: _pickDate,
                validator: (value) {
                  if (_selectedDate == null) {
                    return 'Please select a due date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Status toggle (only when editing)
              if (_isEditing) ...[
                const Text(
                  'Status',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: SwitchListTile(
                    title: const Text('Mark as Completed'),
                    subtitle: Text(
                      _isCompleted ? 'Completed' : 'Pending',
                      style: TextStyle(
                        color: _isCompleted
                            ? AppTheme.completedColor
                            : AppTheme.pendingColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    value: _isCompleted,
                    onChanged: (val) => setState(() => _isCompleted = val),
                    activeColor: AppTheme.completedColor,
                    secondary: Icon(
                      _isCompleted
                          ? Icons.check_circle_outline
                          : Icons.radio_button_unchecked,
                      color: _isCompleted
                          ? AppTheme.completedColor
                          : AppTheme.pendingColor,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 12),

              // Save button
              CustomButton(
                label: _isEditing ? 'Update Task' : 'Add Task',
                onPressed: _saveTask,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
