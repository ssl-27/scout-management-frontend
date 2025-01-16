import 'package:flutter/material.dart';
import '../../../services/training_records_service.dart';
import 'package:intl/intl.dart';

class TrainingRecordsTab extends StatefulWidget {
  const TrainingRecordsTab({super.key});

  @override
  State<TrainingRecordsTab> createState() => _TrainingRecordsTabState();
}

class _TrainingRecordsTabState extends State<TrainingRecordsTab> {
  final TrainingRecordsService _trainingRecordsService = TrainingRecordsService();
  List<dynamic> _scouts = [];
  String? _selectedScoutId;
  List<dynamic> _trainingRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScouts();
  }

  Future<void> _loadScouts() async {
    try {
      setState(() => _isLoading = true);
      final scouts = await _trainingRecordsService.getAllScouts();
      setState(() {
        _scouts = scouts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load scouts');
    }
  }

  Future<void> _loadTrainingRecords(String scoutId) async {
    try {
      setState(() => _isLoading = true);
      final records = await _trainingRecordsService.getScoutTrainingRecords(scoutId);
      setState(() {
        _trainingRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load training records');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Records',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildScoutSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTrainingRecordsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoutSelector() {
    if (_scouts.isEmpty && !_isLoading) {
      return const Text('No scouts found');
    }

    return DropdownButtonFormField<String>(
      value: _selectedScoutId,
      decoration: const InputDecoration(
        labelText: 'Select Scout',
        border: OutlineInputBorder(),
      ),
      items: _scouts.map((scout) {
        return DropdownMenuItem<String>(
          value: scout['id']['id']['id'],
          child: Text('${scout['id']['id']['preferredName']} (${scout['id']['section']})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedScoutId = value);
        if (value != null) {
          _loadTrainingRecords(value);
        }
      },
    );
  }

  Widget _buildTrainingRecordsView() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedScoutId == null) {
      return const Center(child: Text('Please select a scout'));
    }

    if (_trainingRecords.isEmpty) {
      return const Center(child: Text('No training records found'));
    }

    return Card(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrainingProgressSummary(),
            const SizedBox(height: 24),
            _buildTrainingRecordsTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingProgressSummary() {
    final totalItems = _trainingRecords.length;
    final completedItems = _trainingRecords
        .where((record) => record['dateCompleted'] != null)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Summary',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProgressCard(
                'Total Items',
                totalItems.toString(),
                Icons.assignment,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressCard(
                'Completed',
                completedItems.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProgressCard(
                'Pending',
                (totalItems - completedItems).toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, String value, IconData icon, [Color? color]) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingRecordsTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Training Items',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        DataTable(
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Badge')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Completed Date')),
          ],
          rows: _trainingRecords.map((record) {
            final isCompleted = record['dateCompleted'] != null;
            return DataRow(
              cells: [
                DataCell(Text(record['trainingItem']['title'])),
                DataCell(Text(record['trainingItem']['badge']['title'] ?? 'N/A')),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.pending,
                        color: isCompleted ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(isCompleted ? 'Completed' : 'Pending'),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    isCompleted
                        ? DateFormat('MMM dd, yyyy').format(
                      DateTime.parse(record['dateCompleted']),
                    )
                        : '-',
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}