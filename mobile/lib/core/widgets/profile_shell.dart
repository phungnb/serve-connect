import 'package:flutter/material.dart';

class ProfileShell extends StatelessWidget {
  const ProfileShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onLogout,
    required this.onAction,
    required this.actionLabel,
    this.fab,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onLogout;
  final VoidCallback onAction;
  final String actionLabel;
  final Widget? fab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      ],
                    ),
                  ),
                  TextButton(onPressed: onAction, child: Text(actionLabel)),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
