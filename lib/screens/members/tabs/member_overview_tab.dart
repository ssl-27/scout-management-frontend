import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/dashboard_card.dart';

class MemberOverviewTab extends StatelessWidget {
  const MemberOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${context.read<AuthProvider>().userData?['firstName'] ?? 'Scout'}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          const _DashboardGrid(),
          const SizedBox(height: 24),
          const _RecentActivities(),
        ],
      ),
    );
  }
}

class _DashboardGrid extends StatelessWidget {
  const _DashboardGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: const [
        DashboardCard(
          title: 'Total Attendance',
          value: '42',
          icon: Icons.check_circle,
        ),
        DashboardCard(
          title: 'Badges Earned',
          value: '7',
          icon: Icons.military_tech,
        ),
        DashboardCard(
          title: 'Next Meeting',
          value: 'Tomorrow',
          icon: Icons.event,
        ),
      ],
    );
  }
}

class _RecentActivities extends StatelessWidget {
  const _RecentActivities();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const _ActivityItem(
              title: 'Weekly Meeting',
              subtitle: 'Marked as present',
              time: '2 hours ago',
            ),
            const _ActivityItem(
              title: 'First Aid Badge',
              subtitle: 'Assessment completed',
              time: '1 day ago',
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;

  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}