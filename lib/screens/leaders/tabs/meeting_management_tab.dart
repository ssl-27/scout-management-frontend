import 'package:flutter/material.dart';
import '../../../services/meeting_service.dart';
import 'package:intl/intl.dart';

import '../dialogs/create_meeting_dialog.dart';
import '../dialogs/edit_meeting_dialog.dart';
import '../dialogs/meeting_details_dialog.dart';

class MeetingManagementTab extends StatefulWidget {
  const MeetingManagementTab({super.key});

  @override
  State<MeetingManagementTab> createState() => _MeetingManagementTabState();
}

class _MeetingManagementTabState extends State<MeetingManagementTab> {
  final MeetingService _meetingService = MeetingService();
  List<dynamic> _meetings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    try {
      setState(() => _isLoading = true);
      final meetings = await _meetingService.getAllMeetings();
      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load meetings');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCreateMeetingDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateMeetingDialog(),
    ).then((created) {
      if (created == true) {
        _loadMeetings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Meeting Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: _showCreateMeetingDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Meeting'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMeetingList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingList() {
    if (_meetings.isEmpty) {
      return const Center(child: Text('No meetings scheduled'));
    }

    return ListView.builder(
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        final meeting = _meetings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(meeting['title']),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(meeting['meetingDateStart']))}',
                ),
                Text('Location: ${meeting['location']}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEditMeetingDialog(meeting),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDeleteMeeting(meeting),
                ),
              ],
            ),
            onTap: () => _showMeetingDetails(meeting),
          ),
        );
      },
    );
  }

  void _showEditMeetingDialog(dynamic meeting) {
    showDialog(
      context: context,
      builder: (context) => EditMeetingDialog(meeting: meeting),
    ).then((updated) {
      if (updated == true) {
        _loadMeetings();
      }
    });
  }

  Future<void> _confirmDeleteMeeting(dynamic meeting) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meeting'),
        content: Text('Are you sure you want to delete "${meeting['title']}"?'),
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

    if (confirmed == true) {
      try {
        await _meetingService.deleteMeeting(meeting['id']);
        _loadMeetings();
      } catch (e) {
        _showError('Failed to delete meeting');
      }
    }
  }

  void _showMeetingDetails(dynamic meeting) {
    showDialog(
      context: context,
      builder: (context) => MeetingDetailsDialog(meeting: meeting),
    );
  }
}