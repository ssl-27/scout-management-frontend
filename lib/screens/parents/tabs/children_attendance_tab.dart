import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/attendance_service.dart';

class ChildrenAttendanceTab extends StatefulWidget {
  const ChildrenAttendanceTab({super.key});

  @override
  State<ChildrenAttendanceTab> createState() => _ChildrenAttendanceTabState();
}

class _ChildrenAttendanceTabState extends State<ChildrenAttendanceTab> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _childrenAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      setState(() => _isLoading = true);
      final guardianId = context.read<AuthProvider>().userData?['sub'];
      final records = await _attendanceService.findAllForGuardianChildren(guardianId);
      setState(() {
        _childrenAttendance = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load attendance records')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_childrenAttendance.isEmpty) {
      return const Center(child: Text('No children records found'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Children\'s Attendance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _childrenAttendance.length,
              itemBuilder: (context, index) {
                final childRecord = _childrenAttendance[index];
                return _buildChildAttendanceCard(childRecord);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildAttendanceCard(Map<String, dynamic> childRecord) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Child: ${childRecord['childName'] ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Relationship: ${childRecord['relationship'] ?? 'Unknown'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: childRecord['attendances'].length,
            itemBuilder: (context, index) {
              final attendance = childRecord['attendances'][index];
              return ListTile(
                title: Text(attendance['meetingEntity']['title']),
                subtitle: Text(
                  'Date: ${attendance['meetingDate']}\n'
                      'Status: ${attendance['attendance']}',
                ),
                trailing: Icon(
                  attendance['attendance'] == 'Present'
                      ? Icons.check_circle
                      : Icons.warning,
                  color: attendance['attendance'] == 'Present'
                      ? Colors.green
                      : Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}