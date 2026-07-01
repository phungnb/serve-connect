import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/empty_state.dart';
import '../../profile/presentation/profile_screen.dart';
import '../models/job_application.dart';
import '../models/job_post.dart';
import '../state/marketplace_controller.dart';
import 'create_job_form_screen.dart';
import '../../../core/widgets/profile_shell.dart';
import 'view_applicants_screen.dart';

class CatererDashboardScreen extends ConsumerWidget {
  const CatererDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final jobs = state.myJobs;

    return ProfileShell(
      title: 'Caterer Dashboard',
      subtitle: 'Manage your active postings and review applicants',
      actionLabel: 'Profile',
      onAction: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
      onLogout: () => ref.read(marketplaceControllerProvider.notifier).logout(),
      fab: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CreateJobFormScreen())),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Job'),
      ),
      child: jobs.isEmpty
          ? const EmptyState(
              title: 'No jobs posted yet',
              subtitle: 'Create a job post to start receiving applicants.',
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) => _MyJobCard(job: jobs[index]),
            ),
    );
  }
}

class _MyJobCard extends ConsumerWidget {
  const _MyJobCard({required this.job});

  final JobPost job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicants = ref.watch(marketplaceControllerProvider).applicantsByJobId[job.id] ?? const <JobApplication>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(job.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(DateFormat.yMMMMd().format(job.eventDate), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                    ],
                  ),
                ),
                _StateBadge(label: job.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(job.location, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('${applicants.length} applicants', style: Theme.of(context).textTheme.labelLarge),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ViewApplicantsScreen(job: job)),
                    );
                  },
                  child: const Text('View Applicants'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800)),
    );
  }
}
