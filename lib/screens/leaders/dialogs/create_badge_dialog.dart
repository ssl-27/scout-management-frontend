import 'package:flutter/material.dart';
import '../../../services/badge_service.dart';

class CreateBadgeDialog extends StatefulWidget {
  const CreateBadgeDialog({super.key});

  @override
  State<CreateBadgeDialog> createState() => _CreateBadgeDialogState();
}

class _CreateBadgeDialogState extends State<CreateBadgeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSection = 'SCOUT';
  bool _isLoading = false;

  final BadgeService _badgeService = BadgeService();

  Future<void> _createBadge() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _badgeService.createBadge({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'badgeSection': _selectedSection,
        'trainingItems': [],
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create badge')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Badge'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Badge Title',
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSection,
                decoration: const InputDecoration(
                  labelText: 'Section',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'SCOUT', child: Text('Scout')),
                  DropdownMenuItem(value: 'CUB', child: Text('Cub')),
                  DropdownMenuItem(value: 'VENTURE', child: Text('Venture')),
                  DropdownMenuItem(value: 'ROVER', child: Text('Rover')),
                ],
                onChanged: (value) {
                  setState(() => _selectedSection = value!);
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
          onPressed: _isLoading ? null : _createBadge,
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}