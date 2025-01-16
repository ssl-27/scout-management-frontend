import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/attendance_service.dart';

class PatrolManagementTab extends StatefulWidget {
  const PatrolManagementTab({super.key});

  @override
  State<PatrolManagementTab> createState() => _PatrolManagementTabState();
}

class _PatrolManagementTabState extends State<PatrolManagementTab> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _meetings = [];
  String? _selectedMeetingId;
  List<dynamic> _patrolAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  Future<void> _loadMeetings() async {
    try {
      setState(() => _isLoading = true);
      final meetings = await _attendanceService.getAllMeetings();
      setState(() {
        _meetings = meetings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load meetings');
    }
  }

  Future<void> _loadPatrolAttendance(String meetingId) async {
    try {
      setState(() => _isLoading = true);
      final userPatrol = context.read<AuthProvider>().userData?['patrol'];
      final attendance = await _attendanceService.findByMeetingAndPatrol(
        meetingId,
        userPatrol,
      );
      setState(() {
        _patrolAttendance = attendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load patrol attendance');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only show this tab for PL/APLs
    final userRole = context.read<AuthProvider>().userData?['rank'];
    if (userRole != 'PL' && userRole != 'APL') {
      return const Center(
        child: Text('Only Patrol Leaders and Assistant Patrol Leaders can access this page.'),
      );
    }

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
                    'Patrol Attendance Management',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildMeetingSelector(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildAttendanceTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildMeetingSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedMeetingId,
      decoration: const InputDecoration(
        labelText: 'Select Meeting',
        border: OutlineInputBorder(),
      ),
      items: _meetings.map((meeting) {
        return DropdownMenuItem<String>(
          value: meeting['id'],
          child: Text('${meeting['title']} - ${meeting['meetingDateStart']}'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedMeetingId = value);
        if (value != null) {
          _loadPatrolAttendance(value);
        }
      },
    );
  }

  Widget _buildAttendanceTable() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_selectedMeetingId == null) {
      return const Center(child: Text('Please select a meeting'));
    }

    return Card(
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Actions')),
          ],
          rows: _patrolAttendance.map((record) {
            return DataRow(
              cells: [
                DataCell(Text(record['scout']['id']['preferredName'] ?? '')),
                DataCell(Text(record['attendance'])),
                DataCell(
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Present',
                        child: Text('Mark Present'),
                      ),
                      const PopupMenuItem(
                        value: 'Absent',
                        child: Text('Mark Absent'),
                      ),
                      const PopupMenuItem(
                        value: 'Late',
                        child: Text('Mark Late'),
                      ),
                      const PopupMenuItem(
                        value: 'Excused',
                        child: Text('Mark Excused'),
                      ),
                    ],
                    onSelected: (status) async {
                      try {
                        await _attendanceService.markAttendance(
                          _selectedMeetingId!,
                          record['scout']['id'],
                          status,
                        );
                        _loadPatrolAttendance(_selectedMeetingId!);
                      } catch (e) {
                        _showError('Failed to update attendance');
                      }
                    },
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}