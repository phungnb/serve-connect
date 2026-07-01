import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jobs/state/marketplace_controller.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../../core/widgets/loading_card.dart';
import '../../../core/widgets/profile_shell.dart';
import '../state/admin_provider.dart';
import 'admin_applications_screen.dart';
import 'admin_jobs_screen.dart';
import 'admin_users_screen.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return ProfileShell(
      title: 'Admin Dashboard',
      subtitle: 'Monitor platform activity and manage records',
      actionLabel: 'Profile',
      onAction: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
      onLogout: () => ref.read(marketplaceControllerProvider.notifier).logout(),
      child: statsAsync.when(
        loading: () => GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: const [
            LoadingCard(),
            LoadingCard(),
            LoadingCard(),
            LoadingCard(),
          ],
        ),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (stats) {
          return ListView(
            children: <Widget>[
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _card('Users', stats.totalUsers),
                  _card('Students', stats.students),
                  _card('Caterers', stats.caterers),
                  _card('Admins', stats.admins),
                  _card('Jobs', stats.jobs),
                  _card('Applications', stats.applications),
                ],
              ),
              const SizedBox(height: 20),
              _navCard(context, 'Users Management', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminUsersScreen()))),
              const SizedBox(height: 12),
              _navCard(context, 'Jobs Management', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminJobsScreen()))),
              const SizedBox(height: 12),
              _navCard(context, 'Applications Management', () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AdminApplicationsScreen()))),
            ],
          );
        },
      ),
    );
  }

  Widget _card(String title, int count) {
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _navCard(BuildContext context, String title, VoidCallback onTap) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}