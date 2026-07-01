import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/job_post.dart';
import '../state/marketplace_controller.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  const JobDetailsScreen({super.key, required this.job});

  final JobPost job;

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketplaceControllerProvider.notifier).refreshDashboard());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final job = widget.job;
    final applied = state.appliedJobIds.contains(job.id);
    final applicationStatus = state.applicationStatusByJobId[job.id];
    final isBusy = state.isBusy;
    final isAccepted = applicationStatus == 'ACCEPTED';
    final isPending = applicationStatus == 'PENDING';

    return Scaffold(
      appBar: AppBar(title: const Text('Job Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(job.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(job.catererName, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.black54)),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: <Widget>[
                          _DetailChip(label: DateFormat.yMMMMd().format(job.eventDate)),
                          _DetailChip(label: '${job.startTime} - ${job.endTime}'),
                          _DetailChip(label: '\$${job.salaryAmount.toStringAsFixed(2)}/hr'),
                          _DetailChip(label: job.location),
                          _DetailChip(label: '${job.workersNeeded} workers needed'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(job.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (isAccepted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.verified_rounded, color: Colors.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Accepted by the caterer',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (isPending)
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.hourglass_top_rounded),
                  label: const Text('Application Pending'),
                )
              else
                FilledButton.icon(
                  onPressed: applied || isBusy
                      ? null
                      : () async {
                          await ref.read(marketplaceControllerProvider.notifier).applyToJob(job);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application submitted')));
                          }
                        },
                  icon: Icon(applied ? Icons.check_circle_rounded : Icons.send_rounded),
                  label: Text(applied ? 'Applied' : 'Apply Now'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.45),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    );
  }
}
