import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/training_records_service.dart';

class ChildrenProgressTab extends StatefulWidget {
  const ChildrenProgressTab({super.key});

  @override
  State<ChildrenProgressTab> createState() => _ChildrenProgressTabState();
}

class _ChildrenProgressTabState extends State<ChildrenProgressTab> {
  final TrainingRecordsService _trainingRecordsService = TrainingRecordsService();
  List<dynamic> _childrenProgress = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      setState(() => _isLoading = true);
      final guardianId = context.read<AuthProvider>().userData?['sub'];
      final records = await _trainingRecordsService.getChildrenProgress(guardianId);
      setState(() {
        _childrenProgress = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load progress records')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_childrenProgress.isEmpty) {
      return const Center(child: Text('No children progress records found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children\'s Progress',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _childrenProgress.length,
              itemBuilder: (context, index) {
                final childRecord = _childrenProgress[index];
                return _buildChildProgressCard(childRecord);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildProgressCard(Map<String, dynamic> childRecord) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Child: ${childRecord['childName'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Current Rank: ${childRecord['rank'] ?? 'Unknown'}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Badges Earned:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: childRecord['badges']?.length ?? 0,
            itemBuilder: (context, index) {
              final badge = childRecord['badges'][index];
              return ListTile(
                title: Text(badge['title']),
                subtitle: Text('Earned: ${badge['dateCompleted']}'),
                leading: Icon(Icons.military_tech),
              );
            },
          ),
        ],
      ),
    );
  }
}