import 'package:flutter/material.dart';
import '../../../services/badge_service.dart';
import '../dialogs/badge_details_dialog.dart';
import '../dialogs/create_badge_dialog.dart';

class BadgeManagementTab extends StatefulWidget {
  const BadgeManagementTab({super.key});

  @override
  State<BadgeManagementTab> createState() => _BadgeManagementTabState();
}

class _BadgeManagementTabState extends State<BadgeManagementTab> {
  final BadgeService _badgeService = BadgeService();
  List<dynamic> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      setState(() => _isLoading = true);
      final badges = await _badgeService.getAllBadges();
      setState(() {
        _badges = badges;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load badges');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCreateBadgeDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateBadgeDialog(),
    ).then((created) {
      if (created == true) {
        _loadBadges();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Badge Management',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: _showCreateBadgeDialog,
                icon: const Icon(Icons.add),
                label: const Text('Create Badge'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildBadgeGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3/2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _badges.length,
      itemBuilder: (context, index) {
        final badge = _badges[index];
        return BadgeCard(
          badge: badge,
          onTap: () => _showBadgeDetails(badge),
        );
      },
    );
  }

  void _showBadgeDetails(dynamic badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeDetailsDialog(badge: badge, onUpdate: () => _loadBadges),
    );
  }
}


class BadgeCard extends StatelessWidget {
  final dynamic badge;
  final VoidCallback onTap;

  const BadgeCard({
    super.key,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge['title'],
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                badge['description'] ?? 'No description',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                'Section: ${badge['badgeSection']}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}