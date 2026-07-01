import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/snackbar_service.dart';
import '../../../core/widgets/loading_card.dart';
import '../state/admin_provider.dart';

class AdminApplicationsScreen extends ConsumerStatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  ConsumerState<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends ConsumerState<AdminApplicationsScreen> {
  String? _status;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(adminApplicationsProvider((search: _search, status: _status)));
    return Scaffold(
      appBar: AppBar(title: const Text('Applications Management')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Search applications'),
                    onChanged: (value) => setState(() => _search = value.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'PENDING', child: Text('Pending')),
                    DropdownMenuItem(value: 'ACCEPTED', child: Text('Accepted')),
                    DropdownMenuItem(value: 'REJECTED', child: Text('Rejected')),
                  ],
                  onChanged: (value) => setState(() => _status = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: applicationsAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => const LoadingCard(height: 88),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 4,
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (applications) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final app = applications[index];
                  return Card(
                    child: ListTile(
                      title: Text(app.studentName),
                      subtitle: Text('${app.jobTitle}\n${app.studentEmail}\n${app.status}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref.read(adminRepositoryProvider).deleteApplication(app.id);
                          ref.invalidate(adminApplicationsProvider((search: _search, status: _status)));
                          if (context.mounted) {
                            SnackbarService.show(context, 'Application deleted');
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