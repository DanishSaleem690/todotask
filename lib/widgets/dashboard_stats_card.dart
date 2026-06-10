import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Stat card used on the dashboard for task metrics.
class DashboardStatsCard extends StatelessWidget {
  const DashboardStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.2,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid layout for dashboard stat cards with responsive columns.
class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.total,
    required this.completed,
    required this.pending,
    required this.columns,
  });

  final int total;
  final int completed;
  final int pending;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final cards = [
      DashboardStatsCard(
        title: 'Total Tasks',
        value: '$total',
        icon: Icons.list_alt_rounded,
        color: colorScheme.primary,
      ),
      DashboardStatsCard(
        title: 'Completed',
        value: '$completed',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      DashboardStatsCard(
        title: 'Pending',
        value: '$pending',
        icon: Icons.pending_actions_outlined,
        color: Colors.orange,
      ),
    ];

    // On mobile, let each card size itself — fixed grid height caused overflow.
    if (columns == 1) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 88,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => AnimatedContainer(
        duration: AppConstants.animationDuration,
        child: cards[index],
      ),
    );
  }
}
