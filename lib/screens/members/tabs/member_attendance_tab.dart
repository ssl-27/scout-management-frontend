import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/attendance_service.dart';

class MemberAttendanceTab extends StatefulWidget {
  const MemberAttendanceTab({super.key});

  @override
  State<MemberAttendanceTab> createState() => _MemberAttendanceTabState();
}

class _MemberAttendanceTabState extends State<MemberAttendanceTab> {
  final AttendanceService _attendanceService = AttendanceService();
  List<dynamic> _attendanceRecords = [];
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
      print(context.read<AuthProvider>().userData);
      final userId = context.read<AuthProvider>().userData?['sub'];
      print(userId);
      final records = await _attendanceService.findAllForMember(userId);
      setState(() {
        _attendanceRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load attendance records')),
          );
        });
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
            'My Attendance Records',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: ListView.separated(
                itemCount: _attendanceRecords.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final record = _attendanceRecords[index];
                  return ListTile(
                    title: Text(record['meetingEntity']['title']),
                    subtitle: Text(
                      'Date: ${record['meetingDate']}\nStatus: ${record['attendance']}',
                    ),
                    trailing: Icon(
                      record['attendance'] == 'Present'
                          ? Icons.check_circle
                          : Icons.warning,
                      color: record['attendance'] == 'Present'
                          ? Colors.green
                          : Colors.orange,
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