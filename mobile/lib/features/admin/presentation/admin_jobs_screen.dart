import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/snackbar_service.dart';
import '../../../core/widgets/loading_card.dart';
import '../state/admin_provider.dart';

class AdminJobsScreen extends ConsumerStatefulWidget {
  const AdminJobsScreen({super.key});

  @override
  ConsumerState<AdminJobsScreen> createState() => _AdminJobsScreenState();
}

class _AdminJobsScreenState extends ConsumerState<AdminJobsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(adminJobsProvider(_search));
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs Management')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search jobs'),
              onChanged: (value) => setState(() => _search = value.trim()),
            ),
          ),
          Expanded(
            child: jobsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => const LoadingCard(height: 92),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 4,
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (jobs) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return Card(
                    child: ListTile(
                      title: Text(job.title),
                      subtitle: Text('${job.catererName} • ${job.locationString}\nApplications: ${job.applicationsCount}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref.read(adminRepositoryProvider).deleteJob(job.id);
                          ref.invalidate(adminJobsProvider(_search));
                          if (context.mounted) {
                            SnackbarService.show(context, 'Job deleted');
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}