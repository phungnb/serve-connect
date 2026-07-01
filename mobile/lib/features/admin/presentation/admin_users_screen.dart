import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/snackbar_service.dart';
import '../../../core/widgets/loading_card.dart';
import '../state/admin_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String? _role;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(adminUsersProvider((role: _role, search: _search)));
    return Scaffold(
      appBar: AppBar(title: const Text('Users Management')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Search users'),
                    onChanged: (value) => setState(() => _search = value.trim()),
                  ),
                ),
                const SizedBox(width: 12),
                DropdownButton<String?>(
                  value: _role,
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                    DropdownMenuItem(value: 'CATERER', child: Text('Caterer')),
                    DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => _role = value),
                ),
              ],
            ),
          ),
          Expanded(
            child: usersAsync.when(
              loading: () => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, __) => const LoadingCard(height: 88),
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemCount: 4,
              ),
              error: (error, _) => Center(child: Text(error.toString())),
              data: (users) => ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text('${user.email}\n${user.role}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await ref.read(adminRepositoryProvider).deleteUser(user.id);
                          ref.invalidate(adminUsersProvider((role: _role, search: _search)));
                          if (context.mounted) {
                            SnackbarService.show(context, 'User deleted');
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