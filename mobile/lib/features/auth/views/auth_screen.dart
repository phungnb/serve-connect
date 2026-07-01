import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../jobs/state/marketplace_controller.dart';
import '../models/app_user.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginMode = true;
  AppRole _selectedRole = AppRole.student;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final controller = ref.read(marketplaceControllerProvider.notifier);
    try {
      if (_isLoginMode) {
        await controller.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );
      } else {
        await controller.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ref.read(marketplaceControllerProvider).errorMessage ?? 'Something went wrong'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(marketplaceControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[colorScheme.primaryContainer.withOpacity(0.72), Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('ServeConnect', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(
                        'Connect local caterers with flexible student servers in one streamlined marketplace.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.black87),
                      ),
                      const SizedBox(height: 24),
                      _ModeToggle(
                        isLoginMode: _isLoginMode,
                        onChanged: (bool value) => setState(() => _isLoginMode = value),
                      ),
                      const SizedBox(height: 16),
                      _RoleToggle(
                        selectedRole: _selectedRole,
                        onChanged: (AppRole role) => setState(() => _selectedRole = role),
                      ),
                      const SizedBox(height: 24),
                      if (!_isLoginMode) ...<Widget>[
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full name'),
                          validator: (value) {
                            if (value == null || value.trim().length < 2) {
                              return 'Enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                      ],
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email address'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: state.isBusy ? null : _submit,
                        child: state.isBusy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2.2),
                              )
                            : Text(_isLoginMode ? 'Sign In' : 'Create Account'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLoginMode
                            ? 'Demo logins: student@serveconnect.app / password123 or caterer@serveconnect.app / password123'
                            : 'Create a student or caterer profile and jump straight into the app.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isLoginMode, required this.onChanged});

  final bool isLoginMode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      segments: const <ButtonSegment<bool>>[
        ButtonSegment<bool>(value: true, label: Text('Login')),
        ButtonSegment<bool>(value: false, label: Text('Register')),
      ],
      selected: <bool>{isLoginMode},
      onSelectionChanged: (Set<bool> value) => onChanged(value.first),
    );
  }
}

class _RoleToggle extends StatelessWidget {
  const _RoleToggle({required this.selectedRole, required this.onChanged});

  final AppRole selectedRole;
  final ValueChanged<AppRole> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<AppRole>(
      segments: const <ButtonSegment<AppRole>>[
        ButtonSegment<AppRole>(
          value: AppRole.student,
          label: Text('Student'),
        ),
        ButtonSegment<AppRole>(
          value: AppRole.caterer,
          label: Text('Caterer'),
        ),
      ],
      selected: <AppRole>{selectedRole},
      onSelectionChanged: (Set<AppRole> value) => onChanged(value.first),
    );
  }
}
