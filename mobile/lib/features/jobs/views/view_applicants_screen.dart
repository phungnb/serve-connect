import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/job_application.dart';
import '../models/job_post.dart';
import '../state/marketplace_controller.dart';

class ViewApplicantsScreen extends ConsumerStatefulWidget {
  const ViewApplicantsScreen({super.key, required this.job});

  final JobPost job;

  @override
  ConsumerState<ViewApplicantsScreen> createState() => _ViewApplicantsScreenState();
}

class _ViewApplicantsScreenState extends ConsumerState<ViewApplicantsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(marketplaceControllerProvider.notifier).loadApplicants(widget.job.id));
  }

  @override
  Widget build(BuildContext context) {
    final applicants = ref.watch(marketplaceControllerProvider).applicantsByJobId[widget.job.id] ?? const <JobApplication>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Applicants')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: applicants.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final applicant = applicants[index];
            return _ApplicantRow(
              applicant: applicant,
              onAccept: () => ref.read(marketplaceControllerProvider.notifier).updateApplicationStatus(
                applicationId: applicant.id,
                status: 'ACCEPTED',
                jobId: widget.job.id,
              ),
              onReject: () => ref.read(marketplaceControllerProvider.notifier).updateApplicationStatus(
                applicationId: applicant.id,
                status: 'REJECTED',
                jobId: widget.job.id,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApplicantRow extends StatelessWidget {
  const _ApplicantRow({required this.applicant, required this.onAccept, required this.onReject});

  final JobApplication applicant;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final statusColor = applicant.status == 'ACCEPTED'
        ? Colors.green
        : applicant.status == 'REJECTED'
            ? Colors.red
            : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: <Widget>[
            CircleAvatar(child: Text(applicant.studentName.isNotEmpty ? applicant.studentName[0].toUpperCase() : '?')),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(applicant.studentName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(applicant.studentEmail, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  const SizedBox(height: 8),
                  Text(applicant.status, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: statusColor, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            Column(
              children: <Widget>[
                FilledButton.tonal(
                  onPressed: applicant.status == 'PENDING' ? onAccept : null,
                  child: const Text('Accept'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: applicant.status == 'PENDING' ? onReject : null,
                  child: const Text('Reject'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
