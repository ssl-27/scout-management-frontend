import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/dashboard_card.dart';

class LeaderOverviewTab extends StatelessWidget {
  const LeaderOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${context.read<AuthProvider>().userData?['firstName'] ?? 'Leader'}',
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
          title: 'Total Members',
          value: '42',
          icon: Icons.people,
        ),
        DashboardCard(
          title: 'Today\'s Attendance',
          value: '38',
          icon: Icons.how_to_reg,
        ),
        DashboardCard(
          title: 'Pending Badges',
          value: '7',
          icon: Icons.military_tech,
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
            // This will be populated with actual data later
            const _ActivityItem(
              title: 'Weekly Meeting',
              subtitle: 'Attendance marked for 38 members',
              time: '2 hours ago',
            ),
            const _ActivityItem(
              title: 'Badge Assessment',
              subtitle: '3 members completed First Aid badge',
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