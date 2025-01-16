import 'package:flutter/material.dart';
import '../../../services/meeting_service.dart';

class EditMeetingDialog extends StatefulWidget {
  final dynamic meeting;

  const EditMeetingDialog({
    super.key,
    required this.meeting,
  });

  @override
  State<EditMeetingDialog> createState() => _EditMeetingDialogState();
}

class _EditMeetingDialogState extends State<EditMeetingDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  late bool _isMeetingCompleted;
  bool _isLoading = false;

  final MeetingService _meetingService = MeetingService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.meeting['title']);
    _locationController = TextEditingController(text: widget.meeting['location']);
    _descriptionController = TextEditingController(text: widget.meeting['description']);
    _startDate = DateTime.parse(widget.meeting['meetingDateStart']);
    _endDate = DateTime.parse(widget.meeting['meetingDateEnd']);
    _isMeetingCompleted = widget.meeting['isMeetingCompleted'] ?? false;
  }

  Future<void> _updateMeeting() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _meetingService.updateMeeting(
        widget.meeting['id'],
        {
          'title': _titleController.text,
          'location': _locationController.text,
          'description': _descriptionController.text,
          'meetingDateStart': _startDate.toIso8601String(),
          'meetingDateEnd': _endDate.toIso8601String(),
          'isMeetingCompleted': _isMeetingCompleted,
          'trainingItemIds': widget.meeting['trainingItemIds'] ?? [],
        },
      );

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update meeting')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(picked)) {
          _endDate = picked.add(const Duration(hours: 2));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 1)),
    );

    if (picked != null && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Meeting'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Meeting Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Start Date & Time'),
                subtitle: Text(
                  _startDate.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectStartDate,
              ),
              ListTile(
                title: const Text('End Date & Time'),
                subtitle: Text(
                  _endDate.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectEndDate,
              ),
              SwitchListTile(
                title: const Text('Mark as Completed'),
                value: _isMeetingCompleted,
                onChanged: (value) {
                  setState(() {
                    _isMeetingCompleted = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateMeeting,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}