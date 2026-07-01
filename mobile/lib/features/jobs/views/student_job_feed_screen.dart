import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/empty_state.dart';
import '../../profile/presentation/profile_screen.dart';
import '../models/job_post.dart';
import '../state/marketplace_controller.dart';
import 'job_details_screen.dart';
import '../../../core/widgets/profile_shell.dart';

class StudentJobFeedScreen extends ConsumerStatefulWidget {
  const StudentJobFeedScreen({super.key});

  @override
  ConsumerState<StudentJobFeedScreen> createState() => _StudentJobFeedScreenState();
}

class _StudentJobFeedScreenState extends ConsumerState<StudentJobFeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketplaceControllerProvider.notifier).refreshDashboard());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final jobs = state.jobs;

    return ProfileShell(
      title: 'Job Feed',
      subtitle: 'Available catering shifts near you',
      actionLabel: 'Profile',
      onAction: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ProfileScreen())),
      onLogout: () => ref.read(marketplaceControllerProvider.notifier).logout(),
      child: jobs.isEmpty
          ? const EmptyState(
              title: 'No open jobs right now',
              subtitle: 'Check back soon. Caterers post new shifts throughout the week.',
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(marketplaceControllerProvider.notifier).refreshDashboard(),
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) => _JobCard(job: jobs[index]),
              ),
            ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  const _JobCard({required this.job});

  final JobPost job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final applied = ref.watch(marketplaceControllerProvider).appliedJobIds.contains(job.id);
    final applicationStatus = ref.watch(marketplaceControllerProvider).applicationStatusByJobId[job.id];
    final isAccepted = applicationStatus == 'ACCEPTED';
    final isPending = applicationStatus == 'PENDING';

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => JobDetailsScreen(job: job)),
        );
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(job.title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(job.catererName, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      ],
                    ),
                  ),
                  _StatusChip(label: isAccepted ? 'Accepted' : (applied ? 'Applied' : job.status), success: isAccepted),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: <Widget>[
                  _InfoChip(label: _formatDate(job.eventDate)),
                  _InfoChip(label: '\$${job.salaryAmount.toStringAsFixed(2)}/hr'),
                  _InfoChip(label: job.location),
                  _InfoChip(label: '${job.workersNeeded} workers needed'),
                  if (isAccepted)
                    const _StatusChip(label: 'Accepted', success: true)
                  else if (isPending)
                    const _StatusChip(label: 'Pending', success: false),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    return DateFormat.yMMMd().format(value);
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      backgroundColor: Colors.white,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, this.success = false});

  final String label;
  final bool success;

  @override
  Widget build(BuildContext context) {
    final isApplied = success || label.toLowerCase() == 'applied';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isApplied ? Colors.green.withOpacity(0.14) : Colors.black12,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: isApplied ? Colors.green : Colors.transparent),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: isApplied ? Colors.green.shade800 : null,
            ),
      ),
    );
  }
}
