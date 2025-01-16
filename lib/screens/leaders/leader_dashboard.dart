import 'package:flutter/material.dart';
import 'package:scout_management_frontend/screens/leaders/tabs/attendance_tab.dart';
import 'package:scout_management_frontend/screens/leaders/tabs/badge_management_tab.dart';
import 'package:scout_management_frontend/screens/leaders/tabs/meeting_management_tab.dart';
import 'package:scout_management_frontend/screens/leaders/tabs/overview_tab.dart';
import 'package:scout_management_frontend/screens/leaders/tabs/training_records_tab.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LeaderDashboard extends StatefulWidget {
  const LeaderDashboard({super.key});

  @override
  State<LeaderDashboard> createState() => _LeaderDashboardState();
}

class _LeaderDashboardState extends State<LeaderDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leader Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      drawer: NavigationDrawer(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close drawer
        },
        children: const [
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Overview'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.people),
            label: Text('Attendance'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.badge),
            label: Text('Badges'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.event),
            label: Text('Meetings'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.assessment),
            label: Text('Training Records'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const LeaderOverviewTab();
      case 1:
        return const AttendanceManagementTab();
      case 2:
        return const BadgeManagementTab();
      case 3:
        return const MeetingManagementTab();
      case 4:
        return const TrainingRecordsTab();
      default:
        return const LeaderOverviewTab();
    }
  }
}