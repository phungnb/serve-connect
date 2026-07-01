import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../admin/presentation/admin_dashboard_screen.dart';
import '../../jobs/state/marketplace_controller.dart';
import '../../jobs/views/caterer_dashboard_screen.dart';
import '../../jobs/views/student_job_feed_screen.dart';
import '../models/app_user.dart';
import 'auth_screen.dart';
import '../../../core/widgets/loading_overlay.dart';
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(marketplaceControllerProvider);
    final user = state.user;

    if (state.isInitializing) {
      return const Scaffold(body: LoadingOverlay(message: 'Restoring your session'));
    }

    if (user == null) {
      return const AuthScreen();
    }

    switch (user.role) {
      case AppRole.student:
        return const StudentJobFeedScreen();

      case AppRole.caterer:
        return const CatererDashboardScreen();

      case AppRole.admin:
        return const AdminDashboardScreen();
    }
  }
}
