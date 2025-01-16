import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MeetingDetailsDialog extends StatelessWidget {
  final dynamic meeting;

  const MeetingDetailsDialog({
    super.key,
    required this.meeting,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
          maxHeight: 800,
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
                    meeting['title'],
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildInfoSection(context),
              const SizedBox(height: 24),
              _buildDescriptionSection(context),
              const SizedBox(height: 24),
              _buildTrainingItemsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final startDate = DateTime.parse(meeting['meetingDateStart']);
    final endDate = DateTime.parse(meeting['meetingDateEnd']);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              context,
              'Date',
              DateFormat('EEEE, MMMM d, yyyy').format(startDate),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Time',
              '${DateFormat('h:mm a').format(startDate)} - ${DateFormat('h:mm a').format(endDate)}',
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Location',
              meeting['location'],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Status',
              meeting['isMeetingCompleted'] ? 'Completed' : 'Pending',
              textColor: meeting['isMeetingCompleted']
                  ? Colors.green
                  : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              meeting['description'] ?? 'No description provided',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingItemsSection(BuildContext context) {
    final trainingItems = meeting['trainingItems'] as List? ?? [];

    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Training Items',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (trainingItems.isEmpty)
                const Center(
                  child: Text('No training items assigned'),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: trainingItems.length,
                    itemBuilder: (context, index) {
                      final item = trainingItems[index];
                      return ListTile(
                        title: Text(item['title']),
                        subtitle: Text(item['description'] ?? ''),
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

  Widget _buildInfoRow(BuildContext context, String label, String value, {Color? textColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}