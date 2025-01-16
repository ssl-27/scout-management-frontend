import 'package:flutter/material.dart';
import '../../../services/attendance_service.dart';

class AttendanceManagementTab extends StatefulWidget {
  const AttendanceManagementTab({super.key});

  @override
  State<AttendanceManagementTab> createState() => _AttendanceManagementTabState();
}

class _AttendanceManagementTabState extends State<AttendanceManagementTab> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _meetings = [];
  String? _selectedMeetingId;
  List<dynamic> _attendanceRecords = [];
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

  Future<void> _loadAttendance(String meetingId) async {
    try {
      setState(() => _isLoading = true);
      final attendance = await _attendanceService.getMeetingAttendance(meetingId);
      setState(() {
        _attendanceRecords = attendance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load attendance records');
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
                    'Attendance Management',
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
          _loadAttendance(value);
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
          rows: _attendanceRecords.map((record) {
            return DataRow(
              cells: [
                DataCell(Text(record['scout']['id']['id']['preferredName'] ?? '')),
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
                        _loadAttendance(_selectedMeetingId!);
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
