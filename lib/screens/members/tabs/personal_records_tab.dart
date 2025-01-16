import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/training_records_service.dart';

class PersonalRecordsTab extends StatefulWidget {
  const PersonalRecordsTab({super.key});

  @override
  State<PersonalRecordsTab> createState() => _PersonalRecordsTabState();
}

class _PersonalRecordsTabState extends State<PersonalRecordsTab> {
  final TrainingRecordsService _trainingRecordsService = TrainingRecordsService();
  List<dynamic> _trainingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    try {
      setState(() => _isLoading = true);
      final userId = context.read<AuthProvider>().userData?['sub'];
      final records = await _trainingRecordsService.findAllByScoutId(userId);
      setState(() {
        _trainingRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load training records')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Training Records',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: _trainingRecords.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = _trainingRecords[index];
                  return ListTile(
                    title: Text(record['trainingItem']['title']),
                    subtitle: Text(
                      'Badge: ${record['trainingItem']['badge']['title']}\n'
                          'Completed: ${record['dateCompleted']}',
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}