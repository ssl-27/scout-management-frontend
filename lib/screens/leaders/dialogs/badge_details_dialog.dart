import 'package:flutter/material.dart';
import '../../../services/badge_service.dart';

class BadgeDetailsDialog extends StatefulWidget {
  final dynamic badge;
  final VoidCallback  onUpdate;

  const BadgeDetailsDialog({
    super.key,
    required this.badge,
    required this.onUpdate,
  });

  @override
  State<BadgeDetailsDialog> createState() => _BadgeDetailsDialogState();
}

class _BadgeDetailsDialogState extends State<BadgeDetailsDialog> {
  final BadgeService _badgeService = BadgeService();
  dynamic _currentBadge;
  // List<dynamic> _trainingItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentBadge = widget.badge;
    _loadTrainingItems();
  }

  Future<void> _loadTrainingItems() async {
    try {
      setState(() => _isLoading = true);
      final items = await _badgeService.getTrainingItems(widget.badge['id']);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load training items')),
        );
      }
    }
  }

  Future<void> _refreshBadgeDetails() async {
    try {
      setState(() => _isLoading = true);
      final updatedBadge = await _badgeService.getBadgeDetails(_currentBadge['id']);
      setState(() {
        _currentBadge = updatedBadge;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refresh badge details')),
        );
      }
    }
  }

  void _showAddTrainingItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTrainingItemDialog(badgeId: widget.badge['id']),
    ).then((added) {
      if (added == true) {
        _refreshBadgeDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final trainingItems = _currentBadge['trainingItems'] ?? [];

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.badge['title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.badge['description'] ?? 'No description',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Training Items',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddTrainingItemDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Training Item'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: trainingItems.isEmpty
                    ? const Center(child: Text('No training items yet'))
                    : ListView.separated(
                  itemCount: trainingItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = trainingItems[index];
                    return ListTile(
                      title: Text(item['title']),
                      subtitle: Text(item['description']),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDeleteTrainingItem(item),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTrainingItem(dynamic item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Training Item'),
        content: Text('Are you sure you want to delete "${item['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // if (confirmed == true) {
    //   // Implement delete functionality
    //   // await _badgeService.deleteTrainingItem(item['id']);
    //   _loadTrainingItems();
    // }
  }
}

class AddTrainingItemDialog extends StatefulWidget {
  final String badgeId;

  const AddTrainingItemDialog({
    super.key,
    required this.badgeId,
  });

  @override
  State<AddTrainingItemDialog> createState() => _AddTrainingItemDialogState();
}

class _AddTrainingItemDialogState extends State<AddTrainingItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  final BadgeService _badgeService = BadgeService();

  Future<void> _createTrainingItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _badgeService.createTrainingItem({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'badgeId': widget.badgeId,
      });

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create training item')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Training Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createTrainingItem,
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