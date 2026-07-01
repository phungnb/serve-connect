import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/job_post.dart';
import '../state/marketplace_controller.dart';

class CreateJobFormScreen extends ConsumerStatefulWidget {
  const CreateJobFormScreen({super.key});

  @override
  ConsumerState<CreateJobFormScreen> createState() => _CreateJobFormScreenState();
}

class _CreateJobFormScreenState extends ConsumerState<CreateJobFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _workersController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 22, minute: 0);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _workersController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final draft = CreateJobDraft(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      eventDate: _eventDate,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      salaryAmount: double.parse(_salaryController.text.trim()),
      workersNeeded: int.parse(_workersController.text.trim()),
      location: _locationController.text.trim(),
    );

    await ref.read(marketplaceControllerProvider.notifier).createJob(draft: draft);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Job created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceControllerProvider);
    final dateLabel = DateFormat.yMMMMd().format(_eventDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Job')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => (value == null || value.trim().length < 3) ? 'Enter a job title' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) => (value == null || value.trim().length < 10) ? 'Describe the job in detail' : null,
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event date'),
                  subtitle: Text(dateLabel),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _eventDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _eventDate = picked);
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Start time'),
                        subtitle: Text(_formatTime(_startTime)),
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _startTime);
                          if (picked != null) {
                            setState(() => _startTime = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('End time'),
                        subtitle: Text(_formatTime(_endTime)),
                        onTap: () async {
                          final picked = await showTimePicker(context: context, initialTime: _endTime);
                          if (picked != null) {
                            setState(() => _endTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _salaryController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Salary / hour'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid salary';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _workersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Workers needed'),
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a worker count';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter an event location' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isBusy ? null : _submit,
                  child: state.isBusy ? const CircularProgressIndicator() : const Text('Create Job'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
