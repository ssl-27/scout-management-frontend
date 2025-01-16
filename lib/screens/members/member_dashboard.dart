import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scout_management_frontend/screens/members/tabs/member_attendance_tab.dart';
import 'package:scout_management_frontend/screens/members/tabs/member_overview_tab.dart';
import 'package:scout_management_frontend/screens/members/tabs/patrol_management_tab.dart';
import '../../providers/auth_provider.dart';
import 'tabs/personal_records_tab.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Dashboard'),
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
        children: [
          NavigationDrawerDestination(
            icon: Icon(Icons.dashboard),
            label: Text('Overview'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.assignment),
            label: Text('Attendance'),
          ),
          NavigationDrawerDestination(
            icon: Icon(Icons.person),
            label: Text('Personal Records'),
          ),
          if (context.read<AuthProvider>().userData?['rank'] == 'PL' ||
              context.read<AuthProvider>().userData?['rank'] == 'APL')
            NavigationDrawerDestination(
              icon: Icon(Icons.group),
              label: Text('Patrol Management'),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final userRole = context.read<AuthProvider>().userData?['rank'];

    switch (_selectedIndex) {
      case 0:
        return const MemberOverviewTab();
      case 1:
        return const MemberAttendanceTab();
      case 2:
        return const PersonalRecordsTab();
      case 3:
        if (userRole == 'PL' || userRole == 'APL') {
          return const PatrolManagementTab();
        }
        return const MemberOverviewTab();
      default:
        return const MemberOverviewTab();
    }
  }
}